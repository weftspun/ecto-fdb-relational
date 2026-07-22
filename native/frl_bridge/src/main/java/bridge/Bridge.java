package bridge;

import com.apple.foundationdb.relational.api.Options;
import com.apple.foundationdb.relational.api.RelationalConnection;
import com.apple.foundationdb.relational.api.RelationalDriver;
import com.apple.foundationdb.relational.api.RelationalPreparedStatement;
import com.apple.foundationdb.relational.api.RelationalStatement;
import com.apple.foundationdb.relational.jdbc.grpc.v1.Parameter;
import com.apple.foundationdb.relational.jdbc.grpc.v1.ResultSetMetadata;
import com.apple.foundationdb.relational.jdbc.grpc.v1.StatementRequest;
import com.apple.foundationdb.relational.jdbc.grpc.v1.StatementResponse;
import com.apple.foundationdb.relational.jdbc.grpc.v1.column.Column;
import com.apple.foundationdb.relational.jdbc.grpc.v1.column.ColumnMetadata;
import com.apple.foundationdb.relational.jdbc.grpc.v1.column.ListColumn;
import com.apple.foundationdb.relational.jdbc.grpc.v1.column.ListColumnMetadata;
import com.apple.foundationdb.relational.jdbc.grpc.v1.column.Struct;
import com.apple.foundationdb.relational.server.FRL;
import com.google.protobuf.ByteString;

import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.net.URI;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.Types;
import java.util.List;

/**
 * The only class the Rust NIF (native/ecto_fdb_relational_nif) calls into via JNI.
 *
 * FRL (the same class fdb-relational-server's own JDBCService calls into -- see ADR
 * 0002/0003) already speaks the vendored `grpc.relational.jdbc.v1` protobuf messages as
 * its request/response shape (FRL.execute takes a List&lt;Parameter&gt; and FRL.Response
 * wraps a ResultSet message), even though no gRPC service is involved here. So the
 * autocommit-per-call path below ({@link #execute}) does no marshalling of its own: it
 * deserializes the StatementRequest bytes Elixir already builds
 * (EctoFdbRelational.Protocol, same code path the old gRPC transport used), calls FRL
 * directly, and reserializes a StatementResponse -- the exact wire shapes
 * EctoFdbRelational.Protocol.decode_response/1 already knows how to read.
 *
 * <h2>Real transactions ({@link #beginTransaction}/{@link #executeInTransaction}/
 * {@link #commit}/{@link #rollback})</h2>
 *
 * {@code FRL.execute} always opens a fresh connection, runs one statement, and closes
 * it -- one FDB transaction commit per call, no way to batch several statements into
 * one (see EctoFdbRelational.Protocol's moduledoc "Transactions" section for the
 * measured cost of that: ~3x slower than batching for a bulk-write workload). FRL's own
 * `RelationalConnection` (what backs the documented {@code jdbc:embed:} driver) is a
 * plain {@code java.sql.Connection} underneath, so {@code setAutoCommit(false)} +
 * {@code commit()}/{@code rollback()} work exactly as JDBC promises -- the transaction
 * methods below get one of these directly (via {@code FRL}'s own private
 * {@code driver} field, reflectively; only that field is private, `driver.connect(URI,
 * Options)` itself is public API) instead of going through {@code FRL.execute}'s
 * always-autocommit convenience wrapper.
 *
 * <p>Unlike {@link #execute}, {@link #executeInTransaction} builds its own
 * {@code StatementResponse} (see {@link #buildQueryResponse}) rather than reusing
 * {@code FRL.Response} -- {@code FRL.execute}'s internal `RelationalResultSet` &rarr;
 * `grpc.relational.jdbc.v1.ResultSet` marshalling is not exposed as a method we can
 * call with a `ResultSet` we obtained ourselves, and there's no other public converter
 * for it anywhere in fdb-relational-api/-core/-jdbc/-grpc (checked). The marshalling
 * here supports exactly {@code EctoFdbRelational.Types}' documented v0.1 scalar scope
 * (long/string/boolean/double/binary/null) and has been verified byte-for-byte
 * equivalent (through the real `Types.decode_column/1`, not just "doesn't throw") to
 * what {@code FRL.execute}'s own marshalling produces for the same query.
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

    /**
     * Opens a real, explicit (autocommit-disabled) transaction against {@code database}/
     * {@code schema}, bound to the same FDB cluster {@code frlObj} already connected to.
     * See the class doc for how -- {@code frlObj} must be the object {@link #connect}
     * returned.
     */
    public static Object beginTransaction(Object frlObj, String database, String schema)
            throws Exception {
        FRL frl = (FRL) frlObj;

        Field driverField = FRL.class.getDeclaredField("driver");
        driverField.setAccessible(true);
        RelationalDriver driver = (RelationalDriver) driverField.get(frl);

        Method createUri =
                FRL.class.getDeclaredMethod("createEmbeddedJDBCURI", String.class, String.class);
        createUri.setAccessible(true);
        URI uri = URI.create((String) createUri.invoke(null, database, schema));

        RelationalConnection conn = driver.connect(uri, Options.NONE);
        conn.setAutoCommit(false);
        return conn;
    }

    /**
     * Runs one statement against the still-open transaction {@link #beginTransaction}
     * returned -- not yet committed, and not visible to any other connection (including
     * this same JVM's other, non-transactional {@link #execute} calls) until
     * {@link #commit} runs.
     */
    public static byte[] executeInTransaction(Object connObj, byte[] requestBytes)
            throws Exception {
        RelationalConnection conn = (RelationalConnection) connObj;
        StatementRequest request = StatementRequest.parseFrom(requestBytes);
        List<Parameter> parameters = request.getParameters().getParameterList();
        String sql = request.getSql();

        StatementResponse response;
        if (parameters.isEmpty()) {
            try (RelationalStatement stmt = conn.createStatement()) {
                response = runAndBuildResponse(stmt, stmt.execute(sql));
            }
        } else {
            try (RelationalPreparedStatement stmt = conn.prepareStatement(sql)) {
                bindParameters(stmt, parameters);
                response = runAndBuildResponse(stmt, stmt.execute());
            }
        }
        return response.toByteArray();
    }

    // Each transaction's RelationalConnection is one-shot (opened fresh by
    // beginTransaction, never pooled/reused across transactions -- unlike the
    // long-lived FRL instance connect/1 returns), so commit/rollback close it too:
    // there's no separate "return it to a pool" step for the Rust side to do after.
    public static void commit(Object connObj) throws Exception {
        RelationalConnection conn = (RelationalConnection) connObj;
        conn.commit();
        conn.close();
    }

    public static void rollback(Object connObj) throws Exception {
        RelationalConnection conn = (RelationalConnection) connObj;
        conn.rollback();
        conn.close();
    }

    private static StatementResponse runAndBuildResponse(java.sql.Statement stmt, boolean isQuery)
            throws Exception {
        return isQuery
                ? buildQueryResponse(stmt.getResultSet())
                : StatementResponse.newBuilder().setRowCount(stmt.getUpdateCount()).build();
    }

    // See the class doc's "Real transactions" section for why this exists instead of
    // reusing FRL.Response/FRL.execute's own marshalling.
    private static StatementResponse buildQueryResponse(ResultSet rs) throws Exception {
        ResultSetMetaData meta = rs.getMetaData();
        int columnCount = meta.getColumnCount();

        ListColumnMetadata.Builder metadataBuilder = ListColumnMetadata.newBuilder();
        for (int i = 1; i <= columnCount; i++) {
            metadataBuilder.addColumnMetadata(
                    ColumnMetadata.newBuilder()
                            .setName(meta.getColumnName(i))
                            .setNullable(meta.isNullable(i))
                            .build());
        }

        com.apple.foundationdb.relational.jdbc.grpc.v1.ResultSet.Builder resultSetBuilder =
                com.apple.foundationdb.relational.jdbc.grpc.v1.ResultSet.newBuilder()
                        .setMetadata(ResultSetMetadata.newBuilder().setColumnMetadata(metadataBuilder));

        int rowCount = 0;
        while (rs.next()) {
            rowCount++;
            ListColumn.Builder row = ListColumn.newBuilder();
            for (int i = 1; i <= columnCount; i++) {
                row.addColumn(toColumn(rs, meta, i));
            }
            resultSetBuilder.addRow(Struct.newBuilder().setColumns(row));
        }

        return StatementResponse.newBuilder()
                .setRowCount(rowCount)
                .setResultSet(resultSetBuilder)
                .build();
    }

    // Mirrors EctoFdbRelational.Types.encode_param/1's exact scalar scope
    // (long/string/boolean/double/binary/null) -- the same closed set this adapter
    // already documents and decodes on the Elixir side (Types.decode_column/1).
    private static Column toColumn(ResultSet rs, ResultSetMetaData meta, int i) throws Exception {
        int sqlType = meta.getColumnType(i);
        Object value = rs.getObject(i);

        if (value == null) {
            return Column.newBuilder().setNullType(0).build();
        }

        switch (sqlType) {
            case Types.BIGINT:
            case Types.INTEGER:
            case Types.SMALLINT:
            case Types.TINYINT:
                return Column.newBuilder().setLong(rs.getLong(i)).build();
            case Types.DOUBLE:
            case Types.FLOAT:
            case Types.REAL:
            case Types.NUMERIC:
            case Types.DECIMAL:
                return Column.newBuilder().setDouble(rs.getDouble(i)).build();
            case Types.BOOLEAN:
            case Types.BIT:
                return Column.newBuilder().setBoolean(rs.getBoolean(i)).build();
            case Types.VARCHAR:
            case Types.CHAR:
            case Types.LONGVARCHAR:
                return Column.newBuilder().setString(rs.getString(i)).build();
            case Types.BINARY:
            case Types.VARBINARY:
            case Types.LONGVARBINARY:
                return Column.newBuilder().setBinary(ByteString.copyFrom(rs.getBytes(i))).build();
            default:
                throw new UnsupportedOperationException(
                        "column " + i + " has unsupported java.sql.Types code " + sqlType
                                + " (EctoFdbRelational's v0.1 scalar scope is long/string/boolean/"
                                + "double/binary/null -- see EctoFdbRelational.Types' moduledoc)");
        }
    }

    // Binds via plain positional java.sql.PreparedStatement setters against the Column
    // oneof kind -- not FRL's own internal addPreparedStatementParameter (private,
    // switches on the deprecated java_sql_types_code field instead; irrelevant here
    // since this goes through public JDBC API, not FRL's internal binding path).
    private static void bindParameters(RelationalPreparedStatement stmt, List<Parameter> parameters)
            throws Exception {
        for (int i = 0; i < parameters.size(); i++) {
            int index = i + 1;
            Column column = parameters.get(i).getParameter();

            switch (column.getKindCase()) {
                case LONG:
                    stmt.setLong(index, column.getLong());
                    break;
                case DOUBLE:
                    stmt.setDouble(index, column.getDouble());
                    break;
                case BOOLEAN:
                    stmt.setBoolean(index, column.getBoolean());
                    break;
                case STRING:
                    stmt.setString(index, column.getString());
                    break;
                case BINARY:
                    stmt.setBytes(index, column.getBinary().toByteArray());
                    break;
                case NULLTYPE:
                case NULL:
                case KIND_NOT_SET:
                    stmt.setNull(index, Types.NULL);
                    break;
                default:
                    throw new UnsupportedOperationException(
                            "parameter " + index + " has unsupported Column kind "
                                    + column.getKindCase()
                                    + " (EctoFdbRelational's v0.1 scalar scope is long/string/"
                                    + "boolean/double/binary/null -- see EctoFdbRelational.Types' "
                                    + "moduledoc)");
            }
        }
    }
}
