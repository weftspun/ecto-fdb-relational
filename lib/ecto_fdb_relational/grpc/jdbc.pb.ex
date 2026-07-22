defmodule Grpc.Relational.Jdbc.V1.Options.IndexFetchMethod do
  @moduledoc false

  use Protobuf,
    enum: true,
    full_name: "grpc.relational.jdbc.v1.Options.IndexFetchMethod",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.EnumDescriptorProto{
      name: "IndexFetchMethod",
      value: [
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "SCAN_AND_FETCH",
          number: 0,
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "USE_REMOTE_FETCH",
          number: 1,
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "USE_REMOTE_FETCH_WITH_FALLBACK",
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

  field(:SCAN_AND_FETCH, 0)
  field(:USE_REMOTE_FETCH, 1)
  field(:USE_REMOTE_FETCH_WITH_FALLBACK, 2)
end

defmodule Grpc.Relational.Jdbc.V1.KeySetValue do
  @moduledoc false

  use Protobuf,
    full_name: "grpc.relational.jdbc.v1.KeySetValue",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "KeySetValue",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "string_value",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "stringValue",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "long_value",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT64,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "longValue",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "bytes_value",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_BYTES,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "bytesValue",
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
          name: "values",
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

  oneof(:values, 0)

  field(:string_value, 1, type: :string, json_name: "stringValue", oneof: 0)
  field(:long_value, 2, type: :int64, json_name: "longValue", oneof: 0)
  field(:bytes_value, 3, type: :bytes, json_name: "bytesValue", oneof: 0)
end

defmodule Grpc.Relational.Jdbc.V1.KeySet.FieldsEntry do
  @moduledoc false

  use Protobuf,
    full_name: "grpc.relational.jdbc.v1.KeySet.FieldsEntry",
    map: true,
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "FieldsEntry",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "key",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "key",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "value",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".grpc.relational.jdbc.v1.KeySetValue",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "value",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: %Google.Protobuf.MessageOptions{
        message_set_wire_format: false,
        no_standard_descriptor_accessor: false,
        deprecated: false,
        map_entry: true,
        deprecated_legacy_json_field_conflicts: nil,
        features: nil,
        uninterpreted_option: [],
        __pb_extensions__: %{},
        __unknown_fields__: [],
        __protobuf__: true
      },
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:key, 1, type: :string)
  field(:value, 2, type: Grpc.Relational.Jdbc.V1.KeySetValue)
end

defmodule Grpc.Relational.Jdbc.V1.KeySet do
  @moduledoc false

  use Protobuf,
    full_name: "grpc.relational.jdbc.v1.KeySet",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "KeySet",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "fields",
          extendee: nil,
          number: 1,
          label: :LABEL_REPEATED,
          type: :TYPE_MESSAGE,
          type_name: ".grpc.relational.jdbc.v1.KeySet.FieldsEntry",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "fields",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [
        %Google.Protobuf.DescriptorProto{
          name: "FieldsEntry",
          field: [
            %Google.Protobuf.FieldDescriptorProto{
              name: "key",
              extendee: nil,
              number: 1,
              label: :LABEL_OPTIONAL,
              type: :TYPE_STRING,
              type_name: nil,
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "key",
              proto3_optional: nil,
              __unknown_fields__: [],
              __protobuf__: true
            },
            %Google.Protobuf.FieldDescriptorProto{
              name: "value",
              extendee: nil,
              number: 2,
              label: :LABEL_OPTIONAL,
              type: :TYPE_MESSAGE,
              type_name: ".grpc.relational.jdbc.v1.KeySetValue",
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "value",
              proto3_optional: nil,
              __unknown_fields__: [],
              __protobuf__: true
            }
          ],
          nested_type: [],
          enum_type: [],
          extension_range: [],
          extension: [],
          options: %Google.Protobuf.MessageOptions{
            message_set_wire_format: false,
            no_standard_descriptor_accessor: false,
            deprecated: false,
            map_entry: true,
            deprecated_legacy_json_field_conflicts: nil,
            features: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [],
            __protobuf__: true
          },
          oneof_decl: [],
          reserved_range: [],
          reserved_name: [],
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
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

  field(:fields, 1, repeated: true, type: Grpc.Relational.Jdbc.V1.KeySet.FieldsEntry, map: true)
end

defmodule Grpc.Relational.Jdbc.V1.ScanRequest do
  @moduledoc false

  use Protobuf,
    full_name: "grpc.relational.jdbc.v1.ScanRequest",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "ScanRequest",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "key_set",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".grpc.relational.jdbc.v1.KeySet",
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "keySet",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "database",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 1,
          json_name: "database",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "schema",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 2,
          json_name: "schema",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "table_name",
          extendee: nil,
          number: 4,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 3,
          json_name: "tableName",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "options",
          extendee: nil,
          number: 5,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".grpc.relational.jdbc.v1.Options",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "options",
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
          name: "_key_set",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_database",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_schema",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_table_name",
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

  field(:key_set, 1,
    proto3_optional: true,
    type: Grpc.Relational.Jdbc.V1.KeySet,
    json_name: "keySet"
  )

  field(:database, 2, proto3_optional: true, type: :string)
  field(:schema, 3, proto3_optional: true, type: :string)
  field(:table_name, 4, proto3_optional: true, type: :string, json_name: "tableName")
  field(:options, 5, type: Grpc.Relational.Jdbc.V1.Options)
end

defmodule Grpc.Relational.Jdbc.V1.ScanResponse do
  @moduledoc false

  use Protobuf,
    full_name: "grpc.relational.jdbc.v1.ScanResponse",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "ScanResponse",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "result_set",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".grpc.relational.jdbc.v1.ResultSet",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "resultSet",
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

  field(:result_set, 1, type: Grpc.Relational.Jdbc.V1.ResultSet, json_name: "resultSet")
end

defmodule Grpc.Relational.Jdbc.V1.GetRequest do
  @moduledoc false

  use Protobuf,
    full_name: "grpc.relational.jdbc.v1.GetRequest",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "GetRequest",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "key_set",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".grpc.relational.jdbc.v1.KeySet",
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "keySet",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "database",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 1,
          json_name: "database",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "schema",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 2,
          json_name: "schema",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "table_name",
          extendee: nil,
          number: 4,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 3,
          json_name: "tableName",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "options",
          extendee: nil,
          number: 5,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".grpc.relational.jdbc.v1.Options",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "options",
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
          name: "_key_set",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_database",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_schema",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_table_name",
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

  field(:key_set, 1,
    proto3_optional: true,
    type: Grpc.Relational.Jdbc.V1.KeySet,
    json_name: "keySet"
  )

  field(:database, 2, proto3_optional: true, type: :string)
  field(:schema, 3, proto3_optional: true, type: :string)
  field(:table_name, 4, proto3_optional: true, type: :string, json_name: "tableName")
  field(:options, 5, type: Grpc.Relational.Jdbc.V1.Options)
end

defmodule Grpc.Relational.Jdbc.V1.GetResponse do
  @moduledoc false

  use Protobuf,
    full_name: "grpc.relational.jdbc.v1.GetResponse",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "GetResponse",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "result_set",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".grpc.relational.jdbc.v1.ResultSet",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "resultSet",
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

  field(:result_set, 1, type: Grpc.Relational.Jdbc.V1.ResultSet, json_name: "resultSet")
end

defmodule Grpc.Relational.Jdbc.V1.InsertRequest do
  @moduledoc false

  use Protobuf,
    full_name: "grpc.relational.jdbc.v1.InsertRequest",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "InsertRequest",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "dataResultSet",
          extendee: nil,
          number: 5,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".grpc.relational.jdbc.v1.ResultSet",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "dataResultSet",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "database",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "database",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "schema",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 1,
          json_name: "schema",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "table_name",
          extendee: nil,
          number: 4,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 2,
          json_name: "tableName",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "options",
          extendee: nil,
          number: 6,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".grpc.relational.jdbc.v1.Options",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "options",
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
          name: "_database",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_schema",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_table_name",
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

  field(:dataResultSet, 5, type: Grpc.Relational.Jdbc.V1.ResultSet)
  field(:database, 2, proto3_optional: true, type: :string)
  field(:schema, 3, proto3_optional: true, type: :string)
  field(:table_name, 4, proto3_optional: true, type: :string, json_name: "tableName")
  field(:options, 6, type: Grpc.Relational.Jdbc.V1.Options)
end

defmodule Grpc.Relational.Jdbc.V1.ListBytes do
  @moduledoc false

  use Protobuf,
    full_name: "grpc.relational.jdbc.v1.ListBytes",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "ListBytes",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "bytes",
          extendee: nil,
          number: 1,
          label: :LABEL_REPEATED,
          type: :TYPE_BYTES,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "bytes",
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

  field(:bytes, 1, repeated: true, type: :bytes)
end

defmodule Grpc.Relational.Jdbc.V1.InsertResponse do
  @moduledoc false

  use Protobuf,
    full_name: "grpc.relational.jdbc.v1.InsertResponse",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "InsertResponse",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "row_count",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT32,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "rowCount",
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

  field(:row_count, 1, type: :int32, json_name: "rowCount")
end

defmodule Grpc.Relational.Jdbc.V1.Parameters do
  @moduledoc false

  use Protobuf,
    full_name: "grpc.relational.jdbc.v1.Parameters",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "Parameters",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "parameter",
          extendee: nil,
          number: 1,
          label: :LABEL_REPEATED,
          type: :TYPE_MESSAGE,
          type_name: ".grpc.relational.jdbc.v1.Parameter",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "parameter",
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

  field(:parameter, 1, repeated: true, type: Grpc.Relational.Jdbc.V1.Parameter)
end

defmodule Grpc.Relational.Jdbc.V1.Parameter do
  @moduledoc false

  use Protobuf,
    full_name: "grpc.relational.jdbc.v1.Parameter",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "Parameter",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "java_sql_types_code",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT32,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: true,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "javaSqlTypesCode",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "parameter",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".grpc.relational.jdbc.v1.Column",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "parameter",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "type",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_ENUM,
          type_name: ".grpc.relational.jdbc.v1.Type",
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: true,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "type",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "metadata",
          extendee: nil,
          number: 4,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".grpc.relational.jdbc.v1.ParameterMetadata",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "metadata",
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

  field(:java_sql_types_code, 1, type: :int32, json_name: "javaSqlTypesCode", deprecated: true)
  field(:parameter, 2, type: Grpc.Relational.Jdbc.V1.Column)
  field(:type, 3, type: Grpc.Relational.Jdbc.V1.Type, enum: true, deprecated: true)
  field(:metadata, 4, type: Grpc.Relational.Jdbc.V1.ParameterMetadata)
end

defmodule Grpc.Relational.Jdbc.V1.ParameterMetadata do
  @moduledoc false

  use Protobuf,
    full_name: "grpc.relational.jdbc.v1.ParameterMetadata",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "ParameterMetadata",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "java_sql_types_code",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT32,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: true,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "javaSqlTypesCode",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "type",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_ENUM,
          type_name: ".grpc.relational.jdbc.v1.Type",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "type",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "structMetadata",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".grpc.relational.jdbc.v1.StructMetadata",
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "structMetadata",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "arrayMetadata",
          extendee: nil,
          number: 4,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".grpc.relational.jdbc.v1.ColumnMetadata",
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "arrayMetadata",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "enumMetadata",
          extendee: nil,
          number: 5,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".grpc.relational.jdbc.v1.EnumMetadata",
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "enumMetadata",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "vectorMetadata",
          extendee: nil,
          number: 6,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".grpc.relational.jdbc.v1.VectorMetadata",
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "vectorMetadata",
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
          name: "metadata",
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

  oneof(:metadata, 0)

  field(:java_sql_types_code, 1, type: :int32, json_name: "javaSqlTypesCode", deprecated: true)
  field(:type, 2, type: Grpc.Relational.Jdbc.V1.Type, enum: true)
  field(:structMetadata, 3, type: Grpc.Relational.Jdbc.V1.StructMetadata, oneof: 0)
  field(:arrayMetadata, 4, type: Grpc.Relational.Jdbc.V1.ColumnMetadata, oneof: 0)
  field(:enumMetadata, 5, type: Grpc.Relational.Jdbc.V1.EnumMetadata, oneof: 0)
  field(:vectorMetadata, 6, type: Grpc.Relational.Jdbc.V1.VectorMetadata, oneof: 0)
end

defmodule Grpc.Relational.Jdbc.V1.Options do
  @moduledoc false

  use Protobuf,
    full_name: "grpc.relational.jdbc.v1.Options",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "Options",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "max_rows",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT32,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "maxRows",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "continuation",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_BYTES,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 1,
          json_name: "continuation",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "index_hint",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 2,
          json_name: "indexHint",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "required_metadata_table_version",
          extendee: nil,
          number: 4,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT32,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 3,
          json_name: "requiredMetadataTableVersion",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "transaction_timeout",
          extendee: nil,
          number: 5,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT64,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 4,
          json_name: "transactionTimeout",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "replace_on_duplicate_pk",
          extendee: nil,
          number: 6,
          label: :LABEL_OPTIONAL,
          type: :TYPE_BOOL,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 5,
          json_name: "replaceOnDuplicatePk",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "plan_cache_primary_max_entries",
          extendee: nil,
          number: 7,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT32,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 6,
          json_name: "planCachePrimaryMaxEntries",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "plan_cache_secondary_max_entries",
          extendee: nil,
          number: 8,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT32,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 7,
          json_name: "planCacheSecondaryMaxEntries",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "plan_cache_tertiary_max_entries",
          extendee: nil,
          number: 9,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT32,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 8,
          json_name: "planCacheTertiaryMaxEntries",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "plan_cache_primary_time_to_live_millis",
          extendee: nil,
          number: 10,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT64,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 9,
          json_name: "planCachePrimaryTimeToLiveMillis",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "plan_cache_secondary_time_to_live_millis",
          extendee: nil,
          number: 11,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT64,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 10,
          json_name: "planCacheSecondaryTimeToLiveMillis",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "plan_cache_tertiary_time_to_live_millis",
          extendee: nil,
          number: 12,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT64,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 11,
          json_name: "planCacheTertiaryTimeToLiveMillis",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "index_fetch_method",
          extendee: nil,
          number: 13,
          label: :LABEL_OPTIONAL,
          type: :TYPE_ENUM,
          type_name: ".grpc.relational.jdbc.v1.Options.IndexFetchMethod",
          default_value: nil,
          options: nil,
          oneof_index: 12,
          json_name: "indexFetchMethod",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "disabled_planner_rules",
          extendee: nil,
          number: 14,
          label: :LABEL_REPEATED,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "disabledPlannerRules",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "disable_planner_rewriting",
          extendee: nil,
          number: 15,
          label: :LABEL_OPTIONAL,
          type: :TYPE_BOOL,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 13,
          json_name: "disablePlannerRewriting",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "log_query",
          extendee: nil,
          number: 16,
          label: :LABEL_OPTIONAL,
          type: :TYPE_BOOL,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 14,
          json_name: "logQuery",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "log_slow_query_threshold_micros",
          extendee: nil,
          number: 17,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT64,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 15,
          json_name: "logSlowQueryThresholdMicros",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "execution_time_limit",
          extendee: nil,
          number: 18,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT64,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 16,
          json_name: "executionTimeLimit",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "execution_scanned_bytes_limit",
          extendee: nil,
          number: 19,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT64,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 17,
          json_name: "executionScannedBytesLimit",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "execution_scanned_rows_limit",
          extendee: nil,
          number: 20,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT32,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 18,
          json_name: "executionScannedRowsLimit",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "dry_run",
          extendee: nil,
          number: 21,
          label: :LABEL_OPTIONAL,
          type: :TYPE_BOOL,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 19,
          json_name: "dryRun",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "case_sensitive_identifiers",
          extendee: nil,
          number: 22,
          label: :LABEL_OPTIONAL,
          type: :TYPE_BOOL,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 20,
          json_name: "caseSensitiveIdentifiers",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "current_plan_hash_mode",
          extendee: nil,
          number: 23,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 21,
          json_name: "currentPlanHashMode",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "valid_plan_hash_modes",
          extendee: nil,
          number: 24,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 22,
          json_name: "validPlanHashModes",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "async_operations_timeout_millis",
          extendee: nil,
          number: 26,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT64,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 23,
          json_name: "asyncOperationsTimeoutMillis",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "encrypt_when_serializing",
          extendee: nil,
          number: 27,
          label: :LABEL_OPTIONAL,
          type: :TYPE_BOOL,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 24,
          json_name: "encryptWhenSerializing",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "encryption_key_store",
          extendee: nil,
          number: 28,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 25,
          json_name: "encryptionKeyStore",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "encryption_key_entry",
          extendee: nil,
          number: 29,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 26,
          json_name: "encryptionKeyEntry",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "encryption_key_password",
          extendee: nil,
          number: 30,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 27,
          json_name: "encryptionKeyPassword",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "compress_when_serializing",
          extendee: nil,
          number: 31,
          label: :LABEL_OPTIONAL,
          type: :TYPE_BOOL,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 28,
          json_name: "compressWhenSerializing",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "encryption_key_entry_list",
          extendee: nil,
          number: 32,
          label: :LABEL_REPEATED,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "encryptionKeyEntryList",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "plan_right_deep",
          extendee: nil,
          number: 33,
          label: :LABEL_OPTIONAL,
          type: :TYPE_BOOL,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 29,
          json_name: "planRightDeep",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [
        %Google.Protobuf.EnumDescriptorProto{
          name: "IndexFetchMethod",
          value: [
            %Google.Protobuf.EnumValueDescriptorProto{
              name: "SCAN_AND_FETCH",
              number: 0,
              options: nil,
              __unknown_fields__: [],
              __protobuf__: true
            },
            %Google.Protobuf.EnumValueDescriptorProto{
              name: "USE_REMOTE_FETCH",
              number: 1,
              options: nil,
              __unknown_fields__: [],
              __protobuf__: true
            },
            %Google.Protobuf.EnumValueDescriptorProto{
              name: "USE_REMOTE_FETCH_WITH_FALLBACK",
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
      ],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [
        %Google.Protobuf.OneofDescriptorProto{
          name: "_max_rows",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_continuation",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_index_hint",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_required_metadata_table_version",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_transaction_timeout",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_replace_on_duplicate_pk",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_plan_cache_primary_max_entries",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_plan_cache_secondary_max_entries",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_plan_cache_tertiary_max_entries",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_plan_cache_primary_time_to_live_millis",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_plan_cache_secondary_time_to_live_millis",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_plan_cache_tertiary_time_to_live_millis",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_index_fetch_method",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_disable_planner_rewriting",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_log_query",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_log_slow_query_threshold_micros",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_execution_time_limit",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_execution_scanned_bytes_limit",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_execution_scanned_rows_limit",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_dry_run",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_case_sensitive_identifiers",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_current_plan_hash_mode",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_valid_plan_hash_modes",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_async_operations_timeout_millis",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_encrypt_when_serializing",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_encryption_key_store",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_encryption_key_entry",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_encryption_key_password",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_compress_when_serializing",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_plan_right_deep",
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

  field(:max_rows, 1, proto3_optional: true, type: :int32, json_name: "maxRows")
  field(:continuation, 2, proto3_optional: true, type: :bytes)
  field(:index_hint, 3, proto3_optional: true, type: :string, json_name: "indexHint")

  field(:required_metadata_table_version, 4,
    proto3_optional: true,
    type: :int32,
    json_name: "requiredMetadataTableVersion"
  )

  field(:transaction_timeout, 5,
    proto3_optional: true,
    type: :int64,
    json_name: "transactionTimeout"
  )

  field(:replace_on_duplicate_pk, 6,
    proto3_optional: true,
    type: :bool,
    json_name: "replaceOnDuplicatePk"
  )

  field(:plan_cache_primary_max_entries, 7,
    proto3_optional: true,
    type: :int32,
    json_name: "planCachePrimaryMaxEntries"
  )

  field(:plan_cache_secondary_max_entries, 8,
    proto3_optional: true,
    type: :int32,
    json_name: "planCacheSecondaryMaxEntries"
  )

  field(:plan_cache_tertiary_max_entries, 9,
    proto3_optional: true,
    type: :int32,
    json_name: "planCacheTertiaryMaxEntries"
  )

  field(:plan_cache_primary_time_to_live_millis, 10,
    proto3_optional: true,
    type: :int64,
    json_name: "planCachePrimaryTimeToLiveMillis"
  )

  field(:plan_cache_secondary_time_to_live_millis, 11,
    proto3_optional: true,
    type: :int64,
    json_name: "planCacheSecondaryTimeToLiveMillis"
  )

  field(:plan_cache_tertiary_time_to_live_millis, 12,
    proto3_optional: true,
    type: :int64,
    json_name: "planCacheTertiaryTimeToLiveMillis"
  )

  field(:index_fetch_method, 13,
    proto3_optional: true,
    type: Grpc.Relational.Jdbc.V1.Options.IndexFetchMethod,
    json_name: "indexFetchMethod",
    enum: true
  )

  field(:disabled_planner_rules, 14,
    repeated: true,
    type: :string,
    json_name: "disabledPlannerRules"
  )

  field(:disable_planner_rewriting, 15,
    proto3_optional: true,
    type: :bool,
    json_name: "disablePlannerRewriting"
  )

  field(:log_query, 16, proto3_optional: true, type: :bool, json_name: "logQuery")

  field(:log_slow_query_threshold_micros, 17,
    proto3_optional: true,
    type: :int64,
    json_name: "logSlowQueryThresholdMicros"
  )

  field(:execution_time_limit, 18,
    proto3_optional: true,
    type: :int64,
    json_name: "executionTimeLimit"
  )

  field(:execution_scanned_bytes_limit, 19,
    proto3_optional: true,
    type: :int64,
    json_name: "executionScannedBytesLimit"
  )

  field(:execution_scanned_rows_limit, 20,
    proto3_optional: true,
    type: :int32,
    json_name: "executionScannedRowsLimit"
  )

  field(:dry_run, 21, proto3_optional: true, type: :bool, json_name: "dryRun")

  field(:case_sensitive_identifiers, 22,
    proto3_optional: true,
    type: :bool,
    json_name: "caseSensitiveIdentifiers"
  )

  field(:current_plan_hash_mode, 23,
    proto3_optional: true,
    type: :string,
    json_name: "currentPlanHashMode"
  )

  field(:valid_plan_hash_modes, 24,
    proto3_optional: true,
    type: :string,
    json_name: "validPlanHashModes"
  )

  field(:async_operations_timeout_millis, 26,
    proto3_optional: true,
    type: :int64,
    json_name: "asyncOperationsTimeoutMillis"
  )

  field(:encrypt_when_serializing, 27,
    proto3_optional: true,
    type: :bool,
    json_name: "encryptWhenSerializing"
  )

  field(:encryption_key_store, 28,
    proto3_optional: true,
    type: :string,
    json_name: "encryptionKeyStore"
  )

  field(:encryption_key_entry, 29,
    proto3_optional: true,
    type: :string,
    json_name: "encryptionKeyEntry"
  )

  field(:encryption_key_password, 30,
    proto3_optional: true,
    type: :string,
    json_name: "encryptionKeyPassword"
  )

  field(:compress_when_serializing, 31,
    proto3_optional: true,
    type: :bool,
    json_name: "compressWhenSerializing"
  )

  field(:encryption_key_entry_list, 32,
    repeated: true,
    type: :string,
    json_name: "encryptionKeyEntryList"
  )

  field(:plan_right_deep, 33, proto3_optional: true, type: :bool, json_name: "planRightDeep")
end

defmodule Grpc.Relational.Jdbc.V1.TransactionalRequest do
  @moduledoc false

  use Protobuf,
    full_name: "grpc.relational.jdbc.v1.TransactionalRequest",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "TransactionalRequest",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "executeRequest",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".grpc.relational.jdbc.v1.StatementRequest",
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "executeRequest",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "insertRequest",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".grpc.relational.jdbc.v1.InsertRequest",
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "insertRequest",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "commitRequest",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".grpc.relational.jdbc.v1.CommitRequest",
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "commitRequest",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "rollbackRequest",
          extendee: nil,
          number: 4,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".grpc.relational.jdbc.v1.RollbackRequest",
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "rollbackRequest",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "enableAutoCommitRequest",
          extendee: nil,
          number: 5,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".grpc.relational.jdbc.v1.EnableAutoCommitRequest",
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "enableAutoCommitRequest",
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
          name: "TransactionalMessage",
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

  oneof(:TransactionalMessage, 0)

  field(:executeRequest, 1, type: Grpc.Relational.Jdbc.V1.StatementRequest, oneof: 0)
  field(:insertRequest, 2, type: Grpc.Relational.Jdbc.V1.InsertRequest, oneof: 0)
  field(:commitRequest, 3, type: Grpc.Relational.Jdbc.V1.CommitRequest, oneof: 0)
  field(:rollbackRequest, 4, type: Grpc.Relational.Jdbc.V1.RollbackRequest, oneof: 0)

  field(:enableAutoCommitRequest, 5,
    type: Grpc.Relational.Jdbc.V1.EnableAutoCommitRequest,
    oneof: 0
  )
end

defmodule Grpc.Relational.Jdbc.V1.TransactionalResponse do
  @moduledoc false

  use Protobuf,
    full_name: "grpc.relational.jdbc.v1.TransactionalResponse",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "TransactionalResponse",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "executeResponse",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".grpc.relational.jdbc.v1.StatementResponse",
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "executeResponse",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "insertResponse",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".grpc.relational.jdbc.v1.InsertResponse",
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "insertResponse",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "commitResponse",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".grpc.relational.jdbc.v1.CommitResponse",
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "commitResponse",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "rollbackResponse",
          extendee: nil,
          number: 4,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".grpc.relational.jdbc.v1.RollbackResponse",
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "rollbackResponse",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "errorResponse",
          extendee: nil,
          number: 5,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".google.protobuf.Any",
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "errorResponse",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "enableAutoCommitResponse",
          extendee: nil,
          number: 6,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".grpc.relational.jdbc.v1.EnableAutoCommitResponse",
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "enableAutoCommitResponse",
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
          name: "TransactionalMessage",
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

  oneof(:TransactionalMessage, 0)

  field(:executeResponse, 1, type: Grpc.Relational.Jdbc.V1.StatementResponse, oneof: 0)
  field(:insertResponse, 2, type: Grpc.Relational.Jdbc.V1.InsertResponse, oneof: 0)
  field(:commitResponse, 3, type: Grpc.Relational.Jdbc.V1.CommitResponse, oneof: 0)
  field(:rollbackResponse, 4, type: Grpc.Relational.Jdbc.V1.RollbackResponse, oneof: 0)
  field(:errorResponse, 5, type: Google.Protobuf.Any, oneof: 0)

  field(:enableAutoCommitResponse, 6,
    type: Grpc.Relational.Jdbc.V1.EnableAutoCommitResponse,
    oneof: 0
  )
end

defmodule Grpc.Relational.Jdbc.V1.StatementRequest do
  @moduledoc false

  use Protobuf,
    full_name: "grpc.relational.jdbc.v1.StatementRequest",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "StatementRequest",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "sql",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "sql",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "database",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 1,
          json_name: "database",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "schema",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 2,
          json_name: "schema",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "parameters",
          extendee: nil,
          number: 4,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".grpc.relational.jdbc.v1.Parameters",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "parameters",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "options",
          extendee: nil,
          number: 5,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".grpc.relational.jdbc.v1.Options",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "options",
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
          name: "_sql",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_database",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_schema",
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

  field(:sql, 1, proto3_optional: true, type: :string)
  field(:database, 2, proto3_optional: true, type: :string)
  field(:schema, 3, proto3_optional: true, type: :string)
  field(:parameters, 4, type: Grpc.Relational.Jdbc.V1.Parameters)
  field(:options, 5, type: Grpc.Relational.Jdbc.V1.Options)
end

defmodule Grpc.Relational.Jdbc.V1.StatementResponse do
  @moduledoc false

  use Protobuf,
    full_name: "grpc.relational.jdbc.v1.StatementResponse",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "StatementResponse",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "row_count",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT32,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "rowCount",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "result_set",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".grpc.relational.jdbc.v1.ResultSet",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "resultSet",
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

  field(:row_count, 1, type: :int32, json_name: "rowCount")
  field(:result_set, 2, type: Grpc.Relational.Jdbc.V1.ResultSet, json_name: "resultSet")
end

defmodule Grpc.Relational.Jdbc.V1.CommitRequest do
  @moduledoc false

  use Protobuf,
    full_name: "grpc.relational.jdbc.v1.CommitRequest",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "CommitRequest",
      field: [],
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
end

defmodule Grpc.Relational.Jdbc.V1.CommitResponse do
  @moduledoc false

  use Protobuf,
    full_name: "grpc.relational.jdbc.v1.CommitResponse",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "CommitResponse",
      field: [],
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
end

defmodule Grpc.Relational.Jdbc.V1.RollbackRequest do
  @moduledoc false

  use Protobuf,
    full_name: "grpc.relational.jdbc.v1.RollbackRequest",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "RollbackRequest",
      field: [],
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
end

defmodule Grpc.Relational.Jdbc.V1.RollbackResponse do
  @moduledoc false

  use Protobuf,
    full_name: "grpc.relational.jdbc.v1.RollbackResponse",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "RollbackResponse",
      field: [],
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
end

defmodule Grpc.Relational.Jdbc.V1.EnableAutoCommitRequest do
  @moduledoc false

  use Protobuf,
    full_name: "grpc.relational.jdbc.v1.EnableAutoCommitRequest",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "EnableAutoCommitRequest",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "options",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".grpc.relational.jdbc.v1.Options",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "options",
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

  field(:options, 1, type: Grpc.Relational.Jdbc.V1.Options)
end

defmodule Grpc.Relational.Jdbc.V1.EnableAutoCommitResponse do
  @moduledoc false

  use Protobuf,
    full_name: "grpc.relational.jdbc.v1.EnableAutoCommitResponse",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "EnableAutoCommitResponse",
      field: [],
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
end

defmodule Grpc.Relational.Jdbc.V1.DatabaseMetaDataRequest do
  @moduledoc false

  use Protobuf,
    full_name: "grpc.relational.jdbc.v1.DatabaseMetaDataRequest",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "DatabaseMetaDataRequest",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "options",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".grpc.relational.jdbc.v1.Options",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "options",
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

  field(:options, 1, type: Grpc.Relational.Jdbc.V1.Options)
end

defmodule Grpc.Relational.Jdbc.V1.DatabaseMetaDataResponse do
  @moduledoc false

  use Protobuf,
    full_name: "grpc.relational.jdbc.v1.DatabaseMetaDataResponse",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "DatabaseMetaDataResponse",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "url",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "url",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "database_product_version",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "databaseProductVersion",
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

  field(:url, 1, type: :string)
  field(:database_product_version, 2, type: :string, json_name: "databaseProductVersion")
end

defmodule Grpc.Relational.Jdbc.V1.JDBCService.Service do
  @moduledoc false

  use GRPC.Service,
    name: "grpc.relational.jdbc.v1.JDBCService",
    protoc_gen_elixir_version: "0.17.0"

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.ServiceDescriptorProto{
      name: "JDBCService",
      method: [
        %Google.Protobuf.MethodDescriptorProto{
          name: "getMetaData",
          input_type: ".grpc.relational.jdbc.v1.DatabaseMetaDataRequest",
          output_type: ".grpc.relational.jdbc.v1.DatabaseMetaDataResponse",
          options: %Google.Protobuf.MethodOptions{
            deprecated: false,
            idempotency_level: :IDEMPOTENCY_UNKNOWN,
            features: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [],
            __protobuf__: true
          },
          client_streaming: false,
          server_streaming: false,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.MethodDescriptorProto{
          name: "execute",
          input_type: ".grpc.relational.jdbc.v1.StatementRequest",
          output_type: ".grpc.relational.jdbc.v1.StatementResponse",
          options: %Google.Protobuf.MethodOptions{
            deprecated: false,
            idempotency_level: :IDEMPOTENCY_UNKNOWN,
            features: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [],
            __protobuf__: true
          },
          client_streaming: false,
          server_streaming: false,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.MethodDescriptorProto{
          name: "handleAutoCommitOff",
          input_type: ".grpc.relational.jdbc.v1.TransactionalRequest",
          output_type: ".grpc.relational.jdbc.v1.TransactionalResponse",
          options: %Google.Protobuf.MethodOptions{
            deprecated: false,
            idempotency_level: :IDEMPOTENCY_UNKNOWN,
            features: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [],
            __protobuf__: true
          },
          client_streaming: true,
          server_streaming: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.MethodDescriptorProto{
          name: "update",
          input_type: ".grpc.relational.jdbc.v1.StatementRequest",
          output_type: ".grpc.relational.jdbc.v1.StatementResponse",
          options: %Google.Protobuf.MethodOptions{
            deprecated: false,
            idempotency_level: :IDEMPOTENCY_UNKNOWN,
            features: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [],
            __protobuf__: true
          },
          client_streaming: false,
          server_streaming: false,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.MethodDescriptorProto{
          name: "insert",
          input_type: ".grpc.relational.jdbc.v1.InsertRequest",
          output_type: ".grpc.relational.jdbc.v1.InsertResponse",
          options: %Google.Protobuf.MethodOptions{
            deprecated: false,
            idempotency_level: :IDEMPOTENCY_UNKNOWN,
            features: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [],
            __protobuf__: true
          },
          client_streaming: false,
          server_streaming: false,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.MethodDescriptorProto{
          name: "get",
          input_type: ".grpc.relational.jdbc.v1.GetRequest",
          output_type: ".grpc.relational.jdbc.v1.GetResponse",
          options: %Google.Protobuf.MethodOptions{
            deprecated: false,
            idempotency_level: :IDEMPOTENCY_UNKNOWN,
            features: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [],
            __protobuf__: true
          },
          client_streaming: false,
          server_streaming: false,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.MethodDescriptorProto{
          name: "scan",
          input_type: ".grpc.relational.jdbc.v1.ScanRequest",
          output_type: ".grpc.relational.jdbc.v1.ScanResponse",
          options: %Google.Protobuf.MethodOptions{
            deprecated: false,
            idempotency_level: :IDEMPOTENCY_UNKNOWN,
            features: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [],
            __protobuf__: true
          },
          client_streaming: false,
          server_streaming: false,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      options: nil,
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  rpc(
    :getMetaData,
    Grpc.Relational.Jdbc.V1.DatabaseMetaDataRequest,
    Grpc.Relational.Jdbc.V1.DatabaseMetaDataResponse
  )

  rpc(
    :execute,
    Grpc.Relational.Jdbc.V1.StatementRequest,
    Grpc.Relational.Jdbc.V1.StatementResponse
  )

  rpc(
    :handleAutoCommitOff,
    stream(Grpc.Relational.Jdbc.V1.TransactionalRequest),
    stream(Grpc.Relational.Jdbc.V1.TransactionalResponse)
  )

  rpc(
    :update,
    Grpc.Relational.Jdbc.V1.StatementRequest,
    Grpc.Relational.Jdbc.V1.StatementResponse
  )

  rpc(:insert, Grpc.Relational.Jdbc.V1.InsertRequest, Grpc.Relational.Jdbc.V1.InsertResponse)

  rpc(:get, Grpc.Relational.Jdbc.V1.GetRequest, Grpc.Relational.Jdbc.V1.GetResponse)

  rpc(:scan, Grpc.Relational.Jdbc.V1.ScanRequest, Grpc.Relational.Jdbc.V1.ScanResponse)
end

defmodule Grpc.Relational.Jdbc.V1.JDBCService.Stub do
  @moduledoc false

  use GRPC.Stub, service: Grpc.Relational.Jdbc.V1.JDBCService.Service
end
