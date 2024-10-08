import 'dart:typed_data';

import 'package:dart_avro/schema/schema.dart';

/// Singleton for Avro functions
class DartAvro {
  /// Decode avro encoded data from schema
  static dynamic decode(String schema, Uint8List data) {
    final Schema sch = Schema.parse(schema);

    return sch.decode(data);
  }

  /// Decode avro encoded data from schema
  static dynamic decodeJson(Map<String, dynamic> schema, Uint8List data) {
    final Schema sch = Schema.fromJson(schema);

    return sch.decode(data);
  }

  /// Encode payload to avro encoded data from schema
  static Uint8List encode(String schema, dynamic data) {
    final Schema sch = Schema.parse(schema);

    return sch.encode(data);
  }

  /// Encode payload to avro encoded data from schema
  static Uint8List encodeJson(Map<String, dynamic> schema, dynamic data) {
    final Schema sch = Schema.fromJson(schema);

    return sch.encode(data);
  }
}
