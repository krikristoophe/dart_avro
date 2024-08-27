import 'dart:typed_data';

import 'package:dart_avro/schema/schema.dart';
import 'package:dart_avro/utils/data_buffer.dart';

/// null avro type
class NullType extends AvroType<Null> {
  ///
  const NullType();

  ///
  factory NullType.fromJson() {
    return const NullType();
  }

  @override
  Null decode(DataBuffer data) {
    return null;
  }
}

/// Boolean avro type
class BooleanType extends AvroType<bool> {
  ///
  const BooleanType();

  ///
  factory BooleanType.fromJson() {
    return const BooleanType();
  }

  @override
  bool decode(DataBuffer data) {
    return data.readBool();
  }
}

/// Int avro type
class IntType extends AvroType<int> {
  ///
  const IntType();

  ///
  factory IntType.fromJson() {
    return const IntType();
  }

  @override
  int decode(DataBuffer data) {
    return data.readLong();
  }
}

/// Long avro type
class LongType extends IntType {
  ///
  const LongType();

  ///
  factory LongType.fromJson() {
    return const LongType();
  }
}

/// Float avro type
class FloatType extends AvroType<double> {
  ///
  const FloatType();

  ///
  factory FloatType.fromJson() {
    return const FloatType();
  }

  @override
  double decode(DataBuffer data) {
    return data.readFloat();
  }
}

/// Double avro type
class DoubleType extends AvroType<double> {
  ///
  const DoubleType();

  ///
  factory DoubleType.fromJson() {
    return const DoubleType();
  }

  @override
  double decode(DataBuffer data) {
    return data.readDouble();
  }
}

/// Bytes avro type
class BytesType extends AvroType<Uint8List> {
  ///
  const BytesType();

  ///
  factory BytesType.fromJson() {
    return const BytesType();
  }

  @override
  Uint8List decode(DataBuffer data) {
    return data.next(data.readLong());
  }
}

/// String avro type
class StringType extends AvroType<String> {
  ///
  const StringType();

  ///
  factory StringType.fromJson() {
    return const StringType();
  }

  @override
  String decode(DataBuffer data) {
    return data.readString();
  }
}
