defmodule Grpc.Relational.Jdbc.V1.Type do
  @moduledoc false

  use Protobuf,
    enum: true,
    full_name: "grpc.relational.jdbc.v1.Type",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.EnumDescriptorProto{
      name: "Type",
      value: [
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "UNKNOWN",
          number: 0,
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "INTEGER",
          number: 1,
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "LONG",
          number: 2,
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "FLOAT",
          number: 3,
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "DOUBLE",
          number: 4,
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "STRING",
          number: 5,
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "BOOLEAN",
          number: 6,
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "BYTES",
          number: 7,
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "UUID",
          number: 8,
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "ENUM",
          number: 9,
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "VERSION",
          number: 10,
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "STRUCT",
          number: 11,
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "ARRAY",
          number: 12,
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "NULL",
          number: 13,
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "VECTOR",
          number: 14,
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

  field(:UNKNOWN, 0)
  field(:INTEGER, 1)
  field(:LONG, 2)
  field(:FLOAT, 3)
  field(:DOUBLE, 4)
  field(:STRING, 5)
  field(:BOOLEAN, 6)
  field(:BYTES, 7)
  field(:UUID, 8)
  field(:ENUM, 9)
  field(:VERSION, 10)
  field(:STRUCT, 11)
  field(:ARRAY, 12)
  field(:NULL, 13)
  field(:VECTOR, 14)
end

defmodule Grpc.Relational.Jdbc.V1.NullColumn do
  @moduledoc false

  use Protobuf,
    enum: true,
    full_name: "grpc.relational.jdbc.v1.NullColumn",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.EnumDescriptorProto{
      name: "NullColumn",
      value: [
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "NULL_COLUMN",
          number: 0,
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

  field(:NULL_COLUMN, 0)
end

defmodule Grpc.Relational.Jdbc.V1.ColumnMetadata do
  @moduledoc false

  use Protobuf,
    full_name: "grpc.relational.jdbc.v1.ColumnMetadata",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "ColumnMetadata",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "name",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "name",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "label",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "label",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "java_sql_types_code",
          extendee: nil,
          number: 3,
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
          name: "nullable",
          extendee: nil,
          number: 4,
          label: :LABEL_OPTIONAL,
          type: :TYPE_BOOL,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "nullable",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "phantom",
          extendee: nil,
          number: 5,
          label: :LABEL_OPTIONAL,
          type: :TYPE_BOOL,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "phantom",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "structMetadata",
          extendee: nil,
          number: 6,
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
          number: 7,
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
          number: 8,
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
          number: 10,
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
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "type",
          extendee: nil,
          number: 9,
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

  field(:name, 1, type: :string)
  field(:label, 2, type: :string)
  field(:java_sql_types_code, 3, type: :int32, json_name: "javaSqlTypesCode", deprecated: true)
  field(:nullable, 4, type: :bool)
  field(:phantom, 5, type: :bool)
  field(:structMetadata, 6, type: Grpc.Relational.Jdbc.V1.StructMetadata, oneof: 0)
  field(:arrayMetadata, 7, type: Grpc.Relational.Jdbc.V1.ColumnMetadata, oneof: 0)
  field(:enumMetadata, 8, type: Grpc.Relational.Jdbc.V1.EnumMetadata, oneof: 0)
  field(:vectorMetadata, 10, type: Grpc.Relational.Jdbc.V1.VectorMetadata, oneof: 0)
  field(:type, 9, type: Grpc.Relational.Jdbc.V1.Type, enum: true)
end

defmodule Grpc.Relational.Jdbc.V1.Struct do
  @moduledoc false

  use Protobuf,
    full_name: "grpc.relational.jdbc.v1.Struct",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "Struct",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "columns",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".grpc.relational.jdbc.v1.ListColumn",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "columns",
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

  field(:columns, 1, type: Grpc.Relational.Jdbc.V1.ListColumn)
end

defmodule Grpc.Relational.Jdbc.V1.Array do
  @moduledoc false

  use Protobuf,
    full_name: "grpc.relational.jdbc.v1.Array",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "Array",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "element",
          extendee: nil,
          number: 1,
          label: :LABEL_REPEATED,
          type: :TYPE_MESSAGE,
          type_name: ".grpc.relational.jdbc.v1.Column",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "element",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "elementType",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT32,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "elementType",
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

  field(:element, 1, repeated: true, type: Grpc.Relational.Jdbc.V1.Column)
  field(:elementType, 2, type: :int32)
end

defmodule Grpc.Relational.Jdbc.V1.Column do
  @moduledoc false

  use Protobuf,
    full_name: "grpc.relational.jdbc.v1.Column",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "Column",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "null",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_ENUM,
          type_name: ".grpc.relational.jdbc.v1.NullColumn",
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "null",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "double",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_DOUBLE,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "double",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "integer",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT32,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "integer",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "long",
          extendee: nil,
          number: 4,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT64,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "long",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "string",
          extendee: nil,
          number: 5,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "string",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "boolean",
          extendee: nil,
          number: 6,
          label: :LABEL_OPTIONAL,
          type: :TYPE_BOOL,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "boolean",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "struct",
          extendee: nil,
          number: 7,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".grpc.relational.jdbc.v1.Struct",
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "struct",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "array",
          extendee: nil,
          number: 8,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".grpc.relational.jdbc.v1.Array",
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "array",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "binary",
          extendee: nil,
          number: 9,
          label: :LABEL_OPTIONAL,
          type: :TYPE_BYTES,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "binary",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "float",
          extendee: nil,
          number: 10,
          label: :LABEL_OPTIONAL,
          type: :TYPE_FLOAT,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "float",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "nullType",
          extendee: nil,
          number: 11,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT32,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "nullType",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "uuid",
          extendee: nil,
          number: 12,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".grpc.relational.jdbc.v1.Uuid",
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "uuid",
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
          name: "kind",
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

  oneof(:kind, 0)

  field(:null, 1, type: Grpc.Relational.Jdbc.V1.NullColumn, enum: true, oneof: 0)
  field(:double, 2, type: :double, oneof: 0)
  field(:integer, 3, type: :int32, oneof: 0)
  field(:long, 4, type: :int64, oneof: 0)
  field(:string, 5, type: :string, oneof: 0)
  field(:boolean, 6, type: :bool, oneof: 0)
  field(:struct, 7, type: Grpc.Relational.Jdbc.V1.Struct, oneof: 0)
  field(:array, 8, type: Grpc.Relational.Jdbc.V1.Array, oneof: 0)
  field(:binary, 9, type: :bytes, oneof: 0)
  field(:float, 10, type: :float, oneof: 0)
  field(:nullType, 11, type: :int32, oneof: 0)
  field(:uuid, 12, type: Grpc.Relational.Jdbc.V1.Uuid, oneof: 0)
end

defmodule Grpc.Relational.Jdbc.V1.Uuid do
  @moduledoc false

  use Protobuf,
    full_name: "grpc.relational.jdbc.v1.Uuid",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "Uuid",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "most_significant_bits",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT64,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "mostSignificantBits",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "least_significant_bits",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT64,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "leastSignificantBits",
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

  field(:most_significant_bits, 1, type: :int64, json_name: "mostSignificantBits")
  field(:least_significant_bits, 2, type: :int64, json_name: "leastSignificantBits")
end

defmodule Grpc.Relational.Jdbc.V1.ListColumn do
  @moduledoc false

  use Protobuf,
    full_name: "grpc.relational.jdbc.v1.ListColumn",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "ListColumn",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "column",
          extendee: nil,
          number: 1,
          label: :LABEL_REPEATED,
          type: :TYPE_MESSAGE,
          type_name: ".grpc.relational.jdbc.v1.Column",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "column",
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

  field(:column, 1, repeated: true, type: Grpc.Relational.Jdbc.V1.Column)
end

defmodule Grpc.Relational.Jdbc.V1.StructMetadata do
  @moduledoc false

  use Protobuf,
    full_name: "grpc.relational.jdbc.v1.StructMetadata",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "StructMetadata",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "columnMetadata",
          extendee: nil,
          number: 1,
          label: :LABEL_REPEATED,
          type: :TYPE_MESSAGE,
          type_name: ".grpc.relational.jdbc.v1.ColumnMetadata",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "columnMetadata",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "typeName",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "typeName",
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
          name: "_typeName",
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

  field(:columnMetadata, 1, repeated: true, type: Grpc.Relational.Jdbc.V1.ColumnMetadata)
  field(:typeName, 2, proto3_optional: true, type: :string)
end

defmodule Grpc.Relational.Jdbc.V1.EnumMetadata do
  @moduledoc false

  use Protobuf,
    full_name: "grpc.relational.jdbc.v1.EnumMetadata",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "EnumMetadata",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "name",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "name",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "values",
          extendee: nil,
          number: 2,
          label: :LABEL_REPEATED,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "values",
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

  field(:name, 1, type: :string)
  field(:values, 2, repeated: true, type: :string)
end

defmodule Grpc.Relational.Jdbc.V1.VectorMetadata do
  @moduledoc false

  use Protobuf,
    full_name: "grpc.relational.jdbc.v1.VectorMetadata",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "VectorMetadata",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "precision",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT32,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "precision",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "dimensions",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT32,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "dimensions",
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

  field(:precision, 1, type: :int32)
  field(:dimensions, 2, type: :int32)
end
