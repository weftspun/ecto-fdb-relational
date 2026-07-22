defmodule Grpc.Relational.Jdbc.V1.ResultSet do
  @moduledoc false

  use Protobuf,
    full_name: "grpc.relational.jdbc.v1.ResultSet",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "ResultSet",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "metadata",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".grpc.relational.jdbc.v1.ResultSetMetadata",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "metadata",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "row",
          extendee: nil,
          number: 2,
          label: :LABEL_REPEATED,
          type: :TYPE_MESSAGE,
          type_name: ".grpc.relational.jdbc.v1.Struct",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "row",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "continuation",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".grpc.relational.jdbc.v1.RpcContinuation",
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "continuation",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [
        %Google.Protobuf.OneofDescriptorProto{
          name: "_continuation",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:metadata, 1, type: Grpc.Relational.Jdbc.V1.ResultSetMetadata)
  field(:row, 2, repeated: true, type: Grpc.Relational.Jdbc.V1.Struct)
  field(:continuation, 3, proto3_optional: true, type: Grpc.Relational.Jdbc.V1.RpcContinuation)
end

defmodule Grpc.Relational.Jdbc.V1.ResultSetMetadata do
  @moduledoc false

  use Protobuf,
    full_name: "grpc.relational.jdbc.v1.ResultSetMetadata",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "ResultSetMetadata",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "columnMetadata",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".grpc.relational.jdbc.v1.StructMetadata",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "columnMetadata",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:columnMetadata, 1, type: Grpc.Relational.Jdbc.V1.StructMetadata)
end
