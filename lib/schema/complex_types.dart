import 'dart:typed_data';

import 'package:dart_avro/schema/primitive_types.dart';
import 'package:dart_avro/schema/schema.dart';
import 'package:dart_avro/utils/data_buffer.dart';

/// Record avro type
class RecordType extends NamedType<Map<String, dynamic>> {
  ///
  const RecordType({
    required super.name,
    required super.aliases,
    required super.namespace,
    required this.doc,
    required this.fields,
  });

  /// Create record from json schema
  factory RecordType.fromJson(Map<String, dynamic> json) {
    if (json['name'] == null) {
      throw Exception('No name found for record');
    }
    final List<Map<String, dynamic>> fields =
        (json['fields'] as List<dynamic>).cast<Map<String, dynamic>>();
    return RecordType(
      name: json['name'] as String,
      aliases: json['aliases'] as List<String>? ?? [],
      fields: fields.map((f) => RecordField.fromJson(f)).toList(),
      namespace: json['namespace'] as String?,
      doc: json['doc'] as String?,
    );
  }

  /// Documentation of record schema
  final String? doc;

  /// Fields of record
  final List<RecordField> fields;

  @override
  Map<String, dynamic> decode(DataBuffer data) {
    final Map<String, dynamic> result = {};

    for (final RecordField field in fields) {
      result[field.name] = field.type.decode(data);
    }

    return result;
  }

  @override
  Uint8List encode(Map<String, dynamic> payload) {
    Uint8List result = Uint8List(0);

    for (final field in fields) {
      result = Uint8List.fromList([
        ...result,
        ...field.type.encode(payload[field.name]),
      ]);
    }

    return result;
  }
}

/// Field for record schema
class RecordField {
  ///
  const RecordField({
    required this.name,
    required this.doc,
    required this.type,
    required this.order,
    required this.aliases,
  });

  /// Create record field from json schema
  factory RecordField.fromJson(Map<String, dynamic> json) {
    return RecordField(
      name: json['name'] as String,
      doc: json['doc'] as String?,
      type: AvroType.fromDynamic(json['type']),
      order: (json['order'] as String?) ?? 'ascending',
      aliases: (json['aliases'] as List<String>?) ?? [],
    );
  }

  /// Name of field
  final String name;

  /// Documentation of field
  final String? doc;

  /// Type of field
  final AvroType<dynamic> type;

  /// Order of field
  final String order; // TODO(c): manage order
  /// Alias name for backward compatibility
  final List<String> aliases; // TODO(c): manage aliases
}

/// Enum avro type
class EnumType extends NamedType<String> {
  ///
  const EnumType({
    required super.name,
    required super.namespace,
    required super.aliases,
    required this.doc,
    required this.symbols,
  });

  /// Create enum from json schema
  factory EnumType.fromJson(Map<String, dynamic> json) {
    return EnumType(
      name: json['name'] as String,
      namespace: json['namespace'] as String?,
      aliases: (json['aliases'] as List<String>?) ?? [],
      doc: json['doc'] as String?,
      symbols: json['symbols'] as List<String>,
    );
  }

  /// Documentation of enum
  final String? doc;

  /// Enum values
  final List<String> symbols;

  @override
  String decode(DataBuffer data) {
    final int index = data.readLong();
    return symbols[index];
  }

  @override
  Uint8List encode(String payload) {
    return IntType.encodeLong(symbols.indexOf(payload));
  }
}

/// Fixed avro type
class FixedType extends NamedType<Uint8List> {
  ///
  const FixedType({
    required super.name,
    required super.namespace,
    required super.aliases,
    required this.size,
  });

  /// Create fixed from json schema
  factory FixedType.fromJson(Map<String, dynamic> json) {
    return FixedType(
      name: json['name'] as String,
      namespace: json['namespace'] as String?,
      aliases: (json['aliases'] as List<String>?) ?? [],
      size: json['size'] as int,
    );
  }

  /// Size of fixed data
  final int size;

  @override
  Uint8List decode(DataBuffer data) {
    return data.next(size);
  }

  @override
  Uint8List encode(Uint8List payload) {
    return payload;
  }
}

/// Array avro type
class ArrayType extends AvroType<List<dynamic>> {
  ///
  const ArrayType({
    required this.items,
  });

  /// Create array from json schema
  factory ArrayType.fromJson(Map<String, dynamic> json) {
    return ArrayType(
      items: AvroType.fromDynamic(json['items']),
    );
  }

  /// Type of items
  final AvroType<dynamic> items;

  @override
  List<dynamic> decode(DataBuffer data) {
    late int blockCount;
    final List<dynamic> result = [];
    do {
      blockCount = data.readLong();
      if (blockCount < 0) {
        blockCount = blockCount.abs();
        data.readLong(); // Block size
      }
      for (var i = 0; i < blockCount; i++) {
        result.add(items.decode(data));
      }
    } while (blockCount > 0);
    return result;
  }

  @override
  Uint8List encode(List<dynamic> payload) {
    Uint8List result = Uint8List.fromList(IntType.encodeLong(payload.length));

    for (final item in payload) {
      result = Uint8List.fromList([
        ...result,
        ...items.encode(item),
      ]);
    }

    return Uint8List.fromList([
      ...result,
      ...IntType.encodeLong(0),
    ]);
  }
}

/// Map avro type
class MapType extends AvroType<Map<String, dynamic>> {
  ///
  const MapType({
    required this.values,
  });

  /// Create map from json schema
  factory MapType.fromJson(Map<String, dynamic> json) {
    return MapType(
      values: AvroType.fromDynamic(json['values']),
    );
  }

  /// Type of map value
  /// Dart equivalent of T in Map<String, T>
  final AvroType<dynamic> values;

  @override
  Map<String, dynamic> decode(DataBuffer data) {
    late int blockCount;
    final Map<String, dynamic> result = {};

    do {
      blockCount = data.readLong();
      if (blockCount < 0) {
        blockCount = blockCount.abs();
        data.readLong(); // Block size
      }
      for (var i = 0; i < blockCount; i++) {
        final String key = data.readString();
        result[key] = values.decode(data);
      }
    } while (blockCount > 0);

    return result;
  }

  @override
  Uint8List encode(Map<String, dynamic> payload) {
    Uint8List result = Uint8List.fromList(
      IntType.encodeLong(payload.entries.length),
    );

    for (final item in payload.entries) {
      result = Uint8List.fromList([
        ...result,
        ...StringType.encodeString(item.key),
        ...values.encode(item.value),
      ]);
    }

    return Uint8List.fromList([
      ...result,
      ...IntType.encodeLong(0),
    ]);
  }
}

/// Union avro type
class UnionType extends AvroType<dynamic> {
  ///
  const UnionType({
    required this.type,
  });

  /// Create union from json schema
  factory UnionType.fromJson(Map<String, dynamic> json) {
    final List<dynamic> type = json['type'] as List<dynamic>;
    return UnionType(
      type: type.map((t) => AvroType.fromDynamic(t)).toList(),
    );
  }

  /// Types of union
  final List<AvroType<dynamic>> type;

  @override
  dynamic decode(DataBuffer data) {
    return type[data.readLong()].decode(data);
  }

  @override
  Uint8List encode(dynamic payload) {
    final int typeIndex = type.indexWhere((t) => t.isType(payload));
    return Uint8List.fromList([
      ...IntType.encodeLong(typeIndex),
      ...type[typeIndex].encode(payload),
    ]);
  }
}
