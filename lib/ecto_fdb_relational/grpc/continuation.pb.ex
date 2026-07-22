defmodule Grpc.Relational.Jdbc.V1.RpcContinuationReason do
  @moduledoc false

  use Protobuf,
    enum: true,
    full_name: "grpc.relational.jdbc.v1.RpcContinuationReason",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.EnumDescriptorProto{
      name: "RpcContinuationReason",
      value: [
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "TRANSACTION_LIMIT_REACHED",
          number: 0,
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "QUERY_EXECUTION_LIMIT_REACHED",
          number: 1,
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "CURSOR_AFTER_LAST",
          number: 2,
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      options: nil,
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:TRANSACTION_LIMIT_REACHED, 0)
  field(:QUERY_EXECUTION_LIMIT_REACHED, 1)
  field(:CURSOR_AFTER_LAST, 2)
end

defmodule Grpc.Relational.Jdbc.V1.RpcContinuation do
  @moduledoc false

  use Protobuf,
    full_name: "grpc.relational.jdbc.v1.RpcContinuation",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "RpcContinuation",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "version",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT32,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "version",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "internal_state",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_BYTES,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "internalState",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "reason",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_ENUM,
          type_name: ".grpc.relational.jdbc.v1.RpcContinuationReason",
          default_value: nil,
          options: nil,
          oneof_index: 1,
          json_name: "reason",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "atBeginning",
          extendee: nil,
          number: 4,
          label: :LABEL_OPTIONAL,
          type: :TYPE_BOOL,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "atBeginning",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "atEnd",
          extendee: nil,
          number: 5,
          label: :LABEL_OPTIONAL,
          type: :TYPE_BOOL,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "atEnd",
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
      oneof_decl: [
        %Google.Protobuf.OneofDescriptorProto{
          name: "_internal_state",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_reason",
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

  field(:version, 1, type: :int32)
  field(:internal_state, 2, proto3_optional: true, type: :bytes, json_name: "internalState")

  field(:reason, 3,
    proto3_optional: true,
    type: Grpc.Relational.Jdbc.V1.RpcContinuationReason,
    enum: true
  )

  field(:atBeginning, 4, type: :bool)
  field(:atEnd, 5, type: :bool)
end
