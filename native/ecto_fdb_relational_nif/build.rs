use std::path::Path;
use std::process::Command;

// Links this NIF against the active JDK's `libjvm` so `jni`'s "invocation" API
// (JNI_CreateJavaVM) resolves at link time, instead of requiring callers to
// pre-link a JVM into the host process (there is none -- the host is the BEAM).
//
// Requires `JAVA_HOME` (or a `java` on PATH `java-locator` can follow back to a
// JDK) to be set wherever this crate is *compiled*. See ADR 0003 and the
// README: this is an accepted, documented prerequisite of the embedded
// transport, same as fdb-relational-server itself needing a JDK to run.
fn main() {
    let jvm_lib_dir =
        java_locator::locate_jvm_dyn_library().expect(
            "ecto_fdb_relational_nif: could not locate libjvm (the JDK's lib/server directory). \
             Set JAVA_HOME to a JDK (not just a JRE) that includes libjvm.so/jvm.dll.",
        );

    println!("cargo:rustc-link-search=native={jvm_lib_dir}");
    println!("cargo:rustc-link-lib=dylib=jvm");

    // Best-effort convenience so the compiled .so can find libjvm at runtime
    // without the caller also having to set LD_LIBRARY_PATH -- harmless no-op
    // on platforms/linkers that don't support rpath.
    #[cfg(target_os = "linux")]
    println!("cargo:rustc-link-arg=-Wl,-rpath,{jvm_lib_dir}");
    #[cfg(target_os = "macos")]
    println!("cargo:rustc-link-arg=-Wl,-rpath,{jvm_lib_dir}");

    println!("cargo:rerun-if-env-changed=JAVA_HOME");

    compile_bridge();
}

// Compiles native/frl_bridge's one Java class into priv/java/ -- deliberately done
// here, as part of `cargo build`, rather than as a separate Mix compiler
// (lib/mix/tasks/compile.frl_bridge.ex used to do this, ordered after Mix.compilers()).
// That ordering was a real bug: EctoFdbRelational.Native's `use Rustler` starts the
// embedded JVM in Rustler's `@on_load` hook the moment :elixir compiles/loads that
// module (mid-`mix compile`, not at some later "actually run the app" point), with a
// classpath that includes priv/java -- so on a truly clean build, on_load fired
// before a Mix compiler ordered *after* :elixir had ever produced
// priv/java/bridge/Bridge.class, starting the JVM with an incomplete classpath for the
// rest of that OS process's lifetime (confirmed: this broke CI's `integration` job
// with `NoClassDefFoundError: bridge/Bridge` -- see git history). Doing it here instead
// guarantees priv/java is ready *before* cargo produces the .so that on_load loads,
// regardless of Mix's compiler ordering, because there's only one relevant build step.
fn compile_bridge() {
    let classpath = std::env::var("ECTO_FDB_RELATIONAL_CLASSPATH").expect(
        "ECTO_FDB_RELATIONAL_CLASSPATH is not set. It must list the FRL jars \
         (org.foundationdb:fdb-relational-server:<version>:all is enough on its own), \
         colon-separated. See the README.",
    );

    let manifest_dir = std::env::var("CARGO_MANIFEST_DIR").unwrap();
    let crate_root = Path::new(&manifest_dir);
    // native/ecto_fdb_relational_nif -> native -> native/frl_bridge
    let bridge_source = crate_root
        .join("..")
        .join("frl_bridge/src/main/java/bridge/Bridge.java");
    // native/ecto_fdb_relational_nif -> native -> <app root> -> priv/java
    let priv_java = crate_root.join("../../priv/java");

    println!("cargo:rerun-if-changed={}", bridge_source.display());

    std::fs::create_dir_all(&priv_java).expect("creating priv/java failed");

    let status = Command::new("javac")
        .arg("-cp")
        .arg(&classpath)
        .arg("-d")
        .arg(&priv_java)
        .arg(&bridge_source)
        .status()
        .expect(
            "javac not found on PATH -- EctoFdbRelational.Native's Java bridge \
             (native/frl_bridge) cannot be compiled. Install a JDK (see the README).",
        );

    assert!(
        status.success(),
        "javac failed to compile {} (see output above)",
        bridge_source.display()
    );
}
