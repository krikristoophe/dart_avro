import 'dart:convert';
import 'dart:typed_data';

import 'package:dart_avro/schema/complex_types.dart';
import 'package:dart_avro/schema/primitive_types.dart';
import 'package:dart_avro/utils/data_buffer.dart';

/// Avro parsed schema
class Schema {
  ///
  const Schema({
    required this.type,
  });

  /// Parse schema from decoded json
  factory Schema.fromJson(Map<String, dynamic> json) {
    return Schema(type: AvroType.fromJson(json));
  }

  /// Parse schema from json string
  /// Can also parse raw string type like `string`
  factory Schema.parse(String schema) {
    return Schema(type: AvroType.parse(schema));
  }

  /// First type of schema
  final AvroType<dynamic> type;

  /// Decode data with current schema
  dynamic decode(Uint8List data) {
    return type.decode(DataBuffer(data.buffer));
  }
}

// TODO(c): manage alias
/// abstract avro type
abstract class AvroType<T> {
  ///
  const AvroType();

  /// Parse avro type from dynamic schema
  /// Used to manage raw string type, Json object type or List for union
  static AvroType<dynamic> fromDynamic(dynamic schema) {
    if (schema is Map<String, dynamic>) {
      return AvroType.fromJson(schema);
    }
    if (schema is String) {
      return AvroType.parse(schema);
    }

    if (schema is List) {
      return UnionType(
        type: schema.map((s) => AvroType.fromDynamic(s)).toList(),
      );
    }

    throw UnimplementedError('${schema.runtimeType} type not implemented');
  }

  /// Parse type from json
  /// Can parse raw string type like `long`
  static AvroType<dynamic> parse(String schema) {
    late final Map<String, dynamic> json;
    try {
      json = jsonDecode(schema) as Map<String, dynamic>;
    } on FormatException catch (_) {
      json = {'type': schema};
    } catch (_) {
      if (schema == 'null') {
        json = {'type': 'null'};
      } else {
        rethrow;
      }
    }

    return AvroType.fromJson(json);
  }

  ///
  static AvroType<dynamic> fromJson(Map<String, dynamic> json) {
    final dynamic untypedType = json['type'];
    if (untypedType == null) {
      throw Exception('No type specified');
    }

    if (untypedType is List) {
      return UnionType.fromJson(json);
    }

    final String type = untypedType as String;

    switch (type) {
      case 'null':
        return NullType.fromJson();
      case 'boolean':
        return BooleanType.fromJson();
      case 'int':
        return IntType.fromJson();
      case 'long':
        return LongType.fromJson();
      case 'float':
        return FloatType.fromJson();
      case 'double':
        return DoubleType.fromJson();
      case 'bytes':
        return BytesType.fromJson();
      case 'string':
        return StringType.fromJson();
      case 'record':
        return RecordType.fromJson(json);
      case 'array':
        return ArrayType.fromJson(json);
      case 'enum':
        return EnumType.fromJson(json);
      case 'map':
        return MapType.fromJson(json);
      case 'fixed':
        return FixedType.fromJson(json);
    }

    throw UnimplementedError('$type type not implemented');
  }

  /// Decode data for current type
  T decode(DataBuffer data);
}

/// abstract named avro type
/// Record, enum and fixed
abstract class NamedType<T> extends AvroType<T> {
  ///
  const NamedType({
    required this.name,
    required this.namespace,
    required this.aliases,
  });

  /// Name of schema
  final String name;

  /// namespace of schema
  final String? namespace;

  /// Aliases for backward schema compatibility
  final List<String> aliases;
}
