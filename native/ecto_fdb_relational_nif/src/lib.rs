//! Rustler NIF embedding a JVM (via `jni`'s invocation API) that runs FRL
//! in-process, so no separately-managed `fdb-relational-server` + gRPC is
//! needed. See ADR 0003 for why, and `native/frl_bridge` for the one Java
//! class this calls into.
//!
//! ## Design
//!
//! This crate does no protobuf/SQL-shape logic of its own. Elixir
//! (`EctoFdbRelational.Protocol`) builds the exact same
//! `grpc.relational.jdbc.v1.StatementRequest` protobuf bytes it built for the
//! old gRPC transport; this crate hands those bytes to `bridge.Bridge.execute`
//! over JNI and returns the `StatementResponse` bytes it gets back, unparsed.
//! `EctoFdbRelational.Protocol`/`Types` decode the response exactly as before.
//!
//! ## Threading
//!
//! Every NIF here is scheduled on Rustler's `DirtyIo` scheduler: an FDB call
//! is a blocking, potentially slow network round-trip, and dirty schedulers
//! (unlike the normal BEAM schedulers) are meant to tolerate that. This is a
//! deliberate simplification versus ADR 0002's originally-sketched fully
//! async "enqueue on a dedicated thread, deliver the result via
//! `OwnedEnv::send`" design -- simpler to get right first, at the cost of
//! tying up a dirty scheduler thread for the duration of each call. See
//! ADR 0003's "Consequences" for the tradeoff being accepted here.
//!
//! A JVM can only be created once per OS process (`JNI_CreateJavaVM` a second
//! time is an error), so it's created exactly once, eagerly, when this NIF loads
//! (see `on_load` below) -- not lazily on the first `connect/1` call -- and shared
//! by every connection for the life of the BEAM node.

use jni::objects::{JObject, JValue};
use jni::{InitArgsBuilder, JNIEnv, JNIVersion, JavaVM};
use once_cell::sync::OnceCell;
use rustler::{Binary, Env, Error as RustlerError, OwnedBinary, ResourceArc};
use std::sync::Mutex;

static JVM: OnceCell<JavaVM> = OnceCell::new();

struct FrlConnection {
    // A GlobalRef to the Java `FRL` instance `bridge.Bridge.connect/1` returned.
    // None after `close/1`; every other call takes the lock and bails out
    // with a clear error instead of touching a freed handle.
    frl: Mutex<Option<jni::objects::GlobalRef>>,
}

impl rustler::Resource for FrlConnection {}

fn err_term(msg: String) -> RustlerError {
    RustlerError::Term(Box::new(msg))
}

// The JVM is created exactly once, in on_load below -- not lazily on the first
// connect/1 call. A JVM (and its classpath) can only be created once per OS process
// (JNI_CreateJavaVM a second time is an error), so there is no sane "classpath" to
// accept from a later caller anyway; on_load either succeeds once, at NIF load time,
// or the NIF fails to load at all (see on_load's comment).
fn jvm() -> Result<&'static JavaVM, String> {
    JVM.get()
        .ok_or_else(|| "the embedded JVM failed to start when this NIF loaded".to_string())
}

fn create_jvm(classpath: &str) -> Result<JavaVM, String> {
    let classpath_option = format!("-Djava.class.path={classpath}");
    let args = InitArgsBuilder::new()
        .version(JNIVersion::V8)
        .option(&classpath_option)
        .build()
        .map_err(|e| format!("building JVM init args failed: {e}"))?;

    JavaVM::new(args).map_err(|e| format!("JNI_CreateJavaVM failed: {e}"))
}

/// Turns a pending Java exception (if any) into a plain error message, and
/// clears it so the JVM isn't left in a state where the next JNI call is
/// itself rejected for "exception pending".
fn describe_pending_exception(env: &mut JNIEnv) -> String {
    match env.exception_check() {
        Ok(true) => {}
        _ => return "native call failed with no pending Java exception".to_string(),
    }

    let throwable = match env.exception_occurred() {
        Ok(t) => t,
        Err(_) => {
            let _ = env.exception_clear();
            return "a Java exception occurred but could not be retrieved".to_string();
        }
    };
    let _ = env.exception_clear();

    let message = env
        .call_method(&throwable, "toString", "()Ljava/lang/String;", &[])
        .ok()
        .and_then(|v| v.l().ok())
        .map(jni::objects::JString::from);

    match message {
        Some(jstr) => match env.get_string(&jstr) {
            Ok(s) => s.to_string_lossy().into_owned(),
            Err(_) => "a Java exception occurred but its message could not be read".into(),
        },
        None => "a Java exception occurred but its message could not be read".into(),
    }
}

#[rustler::nif(schedule = "DirtyIo")]
fn connect(cluster_file: String) -> Result<ResourceArc<FrlConnection>, RustlerError> {
    let vm = jvm().map_err(err_term)?;
    let mut env = vm
        .attach_current_thread()
        .map_err(|e| err_term(format!("attaching to the JVM failed: {e}")))?;

    let jcluster_file = env
        .new_string(&cluster_file)
        .map_err(|e| err_term(format!("building the cluster-file argument failed: {e}")))?;

    let result = env.call_static_method(
        "bridge/Bridge",
        "connect",
        "(Ljava/lang/String;)Ljava/lang/Object;",
        &[JValue::Object(&jcluster_file)],
    );

    let obj = match result {
        Ok(v) => v
            .l()
            .map_err(|e| err_term(format!("unexpected connect/1 return value: {e}")))?,
        Err(_) => return Err(err_term(describe_pending_exception(&mut env))),
    };

    let global = env
        .new_global_ref(obj)
        .map_err(|e| err_term(format!("holding onto the FRL connection failed: {e}")))?;

    Ok(ResourceArc::new(FrlConnection {
        frl: Mutex::new(Some(global)),
    }))
}

#[rustler::nif(schedule = "DirtyIo")]
fn execute<'a>(
    env: Env<'a>,
    conn: ResourceArc<FrlConnection>,
    request: Binary<'a>,
) -> Result<Binary<'a>, RustlerError> {
    let vm = jvm().map_err(err_term)?;
    let mut jenv = vm
        .attach_current_thread()
        .map_err(|e| err_term(format!("attaching to the JVM failed: {e}")))?;

    let guard = conn.frl.lock().unwrap();
    let frl_ref = guard
        .as_ref()
        .ok_or_else(|| err_term("this connection is already closed".to_string()))?;

    let jrequest = jenv
        .byte_array_from_slice(request.as_slice())
        .map_err(|e| err_term(format!("copying the request bytes failed: {e}")))?;

    let result = jenv.call_static_method(
        "bridge/Bridge",
        "execute",
        "(Ljava/lang/Object;[B)[B",
        &[
            JValue::Object(frl_ref.as_obj()),
            JValue::Object(&JObject::from(jrequest)),
        ],
    );

    let response_obj = match result {
        Ok(v) => v
            .l()
            .map_err(|e| err_term(format!("unexpected execute/1 return value: {e}")))?,
        Err(_) => return Err(err_term(describe_pending_exception(&mut jenv))),
    };

    let response_bytes = jenv
        .convert_byte_array(jni::objects::JByteArray::from(response_obj))
        .map_err(|e| err_term(format!("reading the response bytes failed: {e}")))?;

    let mut owned = OwnedBinary::new(response_bytes.len())
        .ok_or_else(|| err_term("allocating the response binary failed".to_string()))?;
    owned.as_mut_slice().copy_from_slice(&response_bytes);
    Ok(owned.release(env))
}

#[rustler::nif(schedule = "DirtyIo")]
fn close(conn: ResourceArc<FrlConnection>) -> Result<rustler::Atom, RustlerError> {
    let vm = jvm().map_err(err_term)?;
    let mut env = vm
        .attach_current_thread()
        .map_err(|e| err_term(format!("attaching to the JVM failed: {e}")))?;

    let mut guard = conn.frl.lock().unwrap();
    let Some(global) = guard.take() else {
        // Already closed (e.g. DBConnection called disconnect/2 twice) -- a
        // no-op, not an error, matching the old gRPC transport's disconnect/2.
        return Ok(rustler::types::atom::ok());
    };

    let result = env.call_static_method(
        "bridge/Bridge",
        "close",
        "(Ljava/lang/Object;)V",
        &[JValue::Object(global.as_obj())],
    );

    match result {
        Ok(_) => Ok(rustler::types::atom::ok()),
        Err(_) => Err(err_term(describe_pending_exception(&mut env))),
    }
}

// Creates the JVM exactly once, at NIF load time, using the classpath Elixir computed
// via EctoFdbRelational.Native's `load_data_fun` (env classpath ++ this app's own
// priv/java -- see that module's moduledoc). Deliberately not lazy: a JVM can only be
// created once per OS process (JNI_CreateJavaVM a second time is an error), so
// "create it on whatever connect/1 call happens to run first" made the classpath
// argument on every later call meaningless and silently ignored. Here, if the JVM
// can't be created (bad classpath, no libfdb_c, ...) or -- in principle -- on_load
// somehow runs twice, this NIF fails to load loudly (returning `false` fails
// `use Rustler`'s `@on_load`) instead of deferring the failure to whatever the first
// `connect/1` call happens to be.
fn on_load(env: Env, info: rustler::Term) -> bool {
    if env.register::<FrlConnection>().is_err() {
        return false;
    }

    let classpath: String = match info.decode() {
        Ok(classpath) => classpath,
        Err(_) => {
            eprintln!("ecto_fdb_relational_nif: on_load's info was not a classpath string");
            return false;
        }
    };

    match create_jvm(&classpath) {
        Ok(vm) => match JVM.set(vm) {
            Ok(()) => true,
            Err(_) => {
                eprintln!(
                    "ecto_fdb_relational_nif: the embedded JVM was already created (on_load ran \
                     twice?) -- aborting rather than silently reusing or recreating it"
                );
                false
            }
        },
        Err(e) => {
            eprintln!("ecto_fdb_relational_nif: failed to create the embedded JVM: {e}");
            false
        }
    }
}

rustler::init!("Elixir.EctoFdbRelational.Native", load = on_load);
