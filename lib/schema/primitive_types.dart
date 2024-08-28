import 'dart:convert';
import 'dart:typed_data';

import 'package:dart_avro/schema/schema.dart';
import 'package:dart_avro/utils/data_buffer.dart';
import 'package:dart_avro/utils/data_writer_buffer.dart';

/// null avro type
class NullType extends AvroType<Null> {
  ///
  const NullType();

  /// Create null type from json
  factory NullType.fromJson() {
    return const NullType();
  }

  @override
  Null decode(DataBuffer data) {
    return null;
  }

  @override
  Uint8List encode(Null payload) {
    return Uint8List(0);
  }
}

/// Boolean avro type
class BooleanType extends AvroType<bool> {
  ///
  const BooleanType();

  /// Create Boolean type from json
  factory BooleanType.fromJson() {
    return const BooleanType();
  }

  @override
  bool decode(DataBuffer data) {
    return data.readBool();
  }

  @override
  Uint8List encode(bool payload) {
    if (payload) {
      return Uint8List.fromList([1]);
    }
    return Uint8List.fromList([0]);
  }
}

/// Int avro type
class IntType extends AvroType<int> {
  ///
  const IntType();

  /// Create Int type from json
  factory IntType.fromJson() {
    return const IntType();
  }

  @override
  int decode(DataBuffer data) {
    return data.readLong();
  }

  @override
  Uint8List encode(int payload) {
    return encodeLong(payload);
  }

  /// Encode long to avro bytes
  static Uint8List encodeLong(int n) {
    // Copied from js avsc library

    final DataWriterBuffer data = DataWriterBuffer();
    int f;
    int m;
    int pos = 0;

    if (n >= -1073741824 && n < 1073741824) {
      // Won't overflow, we can use integer arithmetic.
      m = n >= 0 ? n << 1 : (~n << 1) | 1;
      do {
        data[pos] = m & 0x7f;
        m >>= 7;
      } while (m != 0 && (data[pos++] |= 0x80) != 0);
    } else {
      // We have to use slower floating arithmetic.
      f = n >= 0 ? n * 2 : (-n * 2) - 1;
      do {
        data[pos] = f & 0x7f;
        f = (f / 128) as int;
      } while (f >= 1 && (data[pos++] |= 0x80) != 0);
    }
    return data.buffer;
  }
}

/// Long avro type
class LongType extends IntType {
  ///
  const LongType();

  /// Create Long type from json
  factory LongType.fromJson() {
    return const LongType();
  }
}

/// Float avro type
class FloatType extends AvroType<double> {
  ///
  const FloatType();

  /// Create Float type from json
  factory FloatType.fromJson() {
    return const FloatType();
  }

  @override
  double decode(DataBuffer data) {
    return data.readFloat();
  }

  @override
  Uint8List encode(double payload) {
    return (ByteData(4)..setFloat32(0, payload, Endian.little))
        .buffer
        .asUint8List();
  }
}

/// Double avro type
class DoubleType extends AvroType<double> {
  ///
  const DoubleType();

  /// Create Double type from json
  factory DoubleType.fromJson() {
    return const DoubleType();
  }

  @override
  double decode(DataBuffer data) {
    return data.readDouble();
  }

  @override
  Uint8List encode(double payload) {
    return (ByteData(8)..setFloat64(0, payload, Endian.little))
        .buffer
        .asUint8List();
  }
}

/// Bytes avro type
class BytesType extends AvroType<Uint8List> {
  ///
  const BytesType();

  /// Create Byte type from json
  factory BytesType.fromJson() {
    return const BytesType();
  }

  @override
  Uint8List decode(DataBuffer data) {
    return data.next(data.readLong());
  }

  @override
  Uint8List encode(Uint8List payload) {
    return Uint8List.fromList([
      ...IntType.encodeLong(payload.length),
      ...payload,
    ]);
  }
}

/// String avro type
class StringType extends AvroType<String> {
  ///
  const StringType();

  /// Create String type from json
  factory StringType.fromJson() {
    return const StringType();
  }

  @override
  String decode(DataBuffer data) {
    return data.readString();
  }

  @override
  Uint8List encode(String payload) {
    return encodeString(payload);
  }

  /// Encode String to avro bytes
  static Uint8List encodeString(String payload) {
    final data = utf8.encode(payload);
    return Uint8List.fromList([
      ...IntType.encodeLong(data.length),
      ...data,
    ]);
  }
}
