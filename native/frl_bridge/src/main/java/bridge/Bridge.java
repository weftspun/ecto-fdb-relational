package bridge;

import com.apple.foundationdb.relational.api.Options;
import com.apple.foundationdb.relational.jdbc.grpc.v1.Parameter;
import com.apple.foundationdb.relational.jdbc.grpc.v1.StatementRequest;
import com.apple.foundationdb.relational.jdbc.grpc.v1.StatementResponse;
import com.apple.foundationdb.relational.server.FRL;

import java.util.List;

/**
 * The only class the Rust NIF (native/ecto_fdb_relational_nif) calls into via JNI.
 *
 * FRL (the same class fdb-relational-server's own JDBCService calls into -- see ADR
 * 0002/0003) already speaks the vendored `grpc.relational.jdbc.v1` protobuf messages as
 * its request/response shape (FRL.execute takes a List&lt;Parameter&gt; and FRL.Response
 * wraps a ResultSet message), even though no gRPC service is involved here. So this
 * bridge does no marshalling of its own: it deserializes the StatementRequest bytes
 * Elixir already builds (EctoFdbRelational.Protocol, same code path the old gRPC
 * transport used), calls FRL directly, and reserializes a StatementResponse -- the exact
 * wire shapes EctoFdbRelational.Protocol.decode_response/1 already knows how to read.
 * Only connection lifetime (connect/close) and exception-to-message flattening are new.
 */
public final class Bridge {
    private Bridge() {}

    public static Object connect(String clusterFile) throws Exception {
        return new FRL(Options.NONE, clusterFile);
    }

    public static void close(Object frl) throws Exception {
        ((FRL) frl).close();
    }

    public static byte[] execute(Object frlObj, byte[] requestBytes) throws Exception {
        FRL frl = (FRL) frlObj;
        StatementRequest request = StatementRequest.parseFrom(requestBytes);

        List<Parameter> parameters = request.getParameters().getParameterList();

        FRL.Response response = frl.execute(
                request.getDatabase(),
                request.getSchema(),
                request.getSql(),
                parameters.isEmpty() ? null : parameters,
                Options.NONE);

        StatementResponse.Builder builder =
                StatementResponse.newBuilder().setRowCount(response.getRowCount());
        if (response.isQuery()) {
            builder.setResultSet(response.getResultSet());
        }
        return builder.build().toByteArray();
    }
}
