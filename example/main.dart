// ignore_for_file: avoid_print

import 'dart:typed_data';

import 'package:dart_avro/dart_avro.dart';

void main() {
  final Map<String, dynamic> schema = {
    'type': 'int',
  };

  // Encode data
  final Uint8List data = DartAvro.encodeJson(schema, 23);

  // Decode data
  final int decoded = DartAvro.decodeJson(schema, data) as int;
  print(decoded);
}
