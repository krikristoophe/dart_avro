import 'dart:typed_data';

import 'package:dart_avro/schema/complex_types.dart';
import 'package:dart_avro/schema/primitive_types.dart';
import 'package:dart_avro/utils/data_buffer.dart';
import 'package:test/test.dart';

void main() {
  group('Decode', () {
    group('primitive types', () {
      /*
      null: no value
      boolean: a binary value
      int: 32-bit signed integer
      long: 64-bit signed integer
      float: single precision (32-bit) IEEE 754 floating-point number
      double: double precision (64-bit) IEEE 754 floating-point number
      bytes: sequence of 8-bit unsigned bytes
      string: unicode character sequence
      */
      test('null', () {
        const NullType type = NullType();
        final DataBuffer buffer = DataBuffer(Uint8List(0).buffer);

        final decoded = type.decode(buffer);

        expect(decoded, isNull);
      });

      group('boolean', () {
        test('is true', () {
          const BooleanType type = BooleanType();
          final DataBuffer buffer = DataBuffer(Uint8List.fromList([1]).buffer);

          final decoded = type.decode(buffer);

          expect(decoded, true);
        });
        test('is false', () {
          const BooleanType type = BooleanType();
          final DataBuffer buffer = DataBuffer(Uint8List.fromList([0]).buffer);

          final decoded = type.decode(buffer);

          expect(decoded, false);
        });
      });

      group('int', () {
        test('one byte', () {
          const IntType type = IntType();
          final DataBuffer buffer = DataBuffer(
            Uint8List.fromList([0x04]).buffer,
          );

          final decoded = type.decode(buffer);

          expect(decoded, 2);
        });
        test('two byte', () {
          const IntType type = IntType();
          final DataBuffer buffer = DataBuffer(
            Uint8List.fromList([0x80, 0x01]).buffer,
          );

          final decoded = type.decode(buffer);

          expect(decoded, 64);
        });

        test('one byte negative', () {
          const IntType type = IntType();
          final DataBuffer buffer = DataBuffer(
            Uint8List.fromList([0x03]).buffer,
          );

          final decoded = type.decode(buffer);

          expect(decoded, -2);
        });

        test('more byte', () {
          const IntType type = IntType();
          final DataBuffer buffer = DataBuffer(
            Uint8List.fromList([0x96, 0xde, 0x87, 0x3]).buffer,
          );

          final decoded = type.decode(buffer);

          expect(decoded, 3209099);
        });
      });

      group('long', () {
        test('one byte', () {
          const LongType type = LongType();
          final DataBuffer buffer = DataBuffer(
            Uint8List.fromList([0x04]).buffer,
          );

          final decoded = type.decode(buffer);

          expect(decoded, 2);
        });
        test('two byte', () {
          const LongType type = LongType();
          final DataBuffer buffer = DataBuffer(
            Uint8List.fromList([0x80, 0x01]).buffer,
          );

          final decoded = type.decode(buffer);

          expect(decoded, 64);
        });

        test('one byte negative', () {
          const LongType type = LongType();
          final DataBuffer buffer = DataBuffer(
            Uint8List.fromList([0x03]).buffer,
          );

          final decoded = type.decode(buffer);

          expect(decoded, -2);
        });

        test('more byte', () {
          const LongType type = LongType();
          final DataBuffer buffer = DataBuffer(
            Uint8List.fromList([0x96, 0xde, 0x87, 0x3]).buffer,
          );

          final decoded = type.decode(buffer);

          expect(decoded, 3209099);
        });
      });

      test('float', () {
        const FloatType type = FloatType();
        final DataBuffer buffer =
            DataBuffer(Uint8List.fromList([0xc3, 0xf5, 0x48, 0x40]).buffer);

        final decoded = type.decode(buffer);

        expect(decoded.toStringAsFixed(3), 3.14.toStringAsFixed(3));
      });

      test('double', () {
        const DoubleType type = DoubleType();
        final DataBuffer buffer = DataBuffer(
          Uint8List.fromList([0x1f, 0x85, 0xeb, 0x51, 0xb8, 0x1e, 0x9, 0x40])
              .buffer,
        );

        final decoded = type.decode(buffer);

        expect(decoded, 3.14);
      });

      test('bytes', () {
        const BytesType type = BytesType();
        final DataBuffer buffer = DataBuffer(
          Uint8List.fromList([0x06, 0x66, 0x6f, 0x6f]).buffer,
        );

        final decoded = type.decode(buffer);

        expect(decoded, Uint8List.fromList([0x66, 0x6f, 0x6f]));
      });

      test('string', () {
        const StringType type = StringType();
        final DataBuffer buffer = DataBuffer(
          Uint8List.fromList([0x06, 0x66, 0x6f, 0x6f]).buffer,
        );

        final decoded = type.decode(buffer);

        expect(decoded, 'foo');
      });
    });

    group('complex types', () {
      group('record', () {
        test('primitive', () {
          const Map<String, dynamic> jsonSchema = {
            'type': 'record',
            'name': 'testingRecord',
            'fields': [
              {'name': 'long', 'type': 'long'},
              {'name': 'string', 'type': 'string'},
            ],
          };
          final RecordType type = RecordType.fromJson(jsonSchema);

          final DataBuffer buffer = DataBuffer(
            Uint8List.fromList([0x96, 0xde, 0x87, 0x3, 0x06, 0x66, 0x6f, 0x6f])
                .buffer,
          );

          final decoded = type.decode(buffer);

          expect(decoded['long'], 3209099);
          expect(decoded['string'], 'foo');
        });

        test('with union', () {
          const Map<String, dynamic> jsonSchema = {
            'fields': [
              {
                'name': 'bic',
                'type': ['null', 'string'],
              },
              {'name': 'countryOfBirth', 'type': 'string'},
              {'name': 'customerId', 'type': 'string'},
              {'name': 'dateOfBirth', 'type': 'string'},
              {'name': 'dateOfOpened', 'type': 'string'},
              {'name': 'firstName', 'type': 'string'},
              {'name': 'lastName', 'type': 'string'},
              {'name': 'lineOfBusiness', 'type': 'string'},
              {'name': 'placeOfBirth', 'type': 'string'},
              {
                'name': 'title',
                'type': ['null', 'string'],
              }
            ],
            'name': 'NeuronDemoCustomer',
            'type': 'record',
          };
          final RecordType type = RecordType.fromJson(jsonSchema);

          final DataBuffer buffer = DataBuffer(
            Uint8List.fromList([
              0x02,
              0x16,
              0x52,
              0x56,
              0x4f,
              0x54,
              0x41,
              0x54,
              0x41,
              0x43,
              0x58,
              0x58,
              0x58,
              0x04,
              0x4c,
              0x55,
              0x06,
              0x36,
              0x38,
              0x37,
              0x14,
              0x31,
              0x39,
              0x36,
              0x39,
              0x2d,
              0x31,
              0x31,
              0x2d,
              0x31,
              0x36,
              0x14,
              0x32,
              0x30,
              0x32,
              0x31,
              0x2d,
              0x30,
              0x34,
              0x2d,
              0x31,
              0x31,
              0x16,
              0x4c,
              0x61,
              0x72,
              0x61,
              0x2d,
              0x53,
              0x6f,
              0x70,
              0x68,
              0x69,
              0x65,
              0x0c,
              0x53,
              0x63,
              0x68,
              0x77,
              0x61,
              0x62,
              0x08,
              0x43,
              0x4f,
              0x52,
              0x50,
              0x20,
              0x52,
              0x69,
              0x65,
              0x64,
              0x20,
              0x69,
              0x6d,
              0x20,
              0x49,
              0x6e,
              0x6e,
              0x6b,
              0x72,
              0x65,
              0x69,
              0x73,
              0x02,
              0x08,
              0x4d,
              0x61,
              0x67,
              0x2e,
            ]).buffer,
          );

          final decoded = type.decode(buffer);

          const expected = {
            'bic': 'RVOTATACXXX',
            'countryOfBirth': 'LU',
            'customerId': '687',
            'dateOfBirth': '1969-11-16',
            'dateOfOpened': '2021-04-11',
            'firstName': 'Lara-Sophie',
            'lastName': 'Schwab',
            'lineOfBusiness': 'CORP',
            'placeOfBirth': 'Ried im Innkreis',
            'title': 'Mag.',
          };

          for (final entry in expected.entries) {
            expect(entry.value, decoded[entry.key]);
          }
        });
      });

      test('enum', () {
        const Map<String, dynamic> jsonSchema = {
          'type': 'enum',
          'name': 'Suit',
          'symbols': ['SPADES', 'HEARTS', 'DIAMONDS', 'CLUBS'],
        };

        final EnumType type = EnumType.fromJson(jsonSchema);

        final DataBuffer buffer = DataBuffer(
          Uint8List.fromList([0x02]).buffer,
        );

        final decoded = type.decode(buffer);

        expect(decoded, 'HEARTS');
      });
      test('array', () {
        const Map<String, dynamic> jsonSchema = {
          'type': 'array',
          'items': 'long',
        };

        final ArrayType type = ArrayType.fromJson(jsonSchema);

        final DataBuffer buffer = DataBuffer(
          Uint8List.fromList([0x04, 0x06, 0x36, 0x00]).buffer,
        );

        final decoded = type.decode(buffer);

        expect(decoded[0], 3);
        expect(decoded[1], 27);
      });
      group('map', () {
        test('without blocksize', () {
          const Map<String, dynamic> jsonSchema = {
            'type': 'map',
            'values': {'type': 'array', 'items': 'long'},
          };

          final MapType type = MapType.fromJson(jsonSchema);

          final DataBuffer buffer = DataBuffer(
            Uint8List.fromList([
              0x04, // block count
              0x06, 0x66, 0x6f, 0x6f, // string
              0x04, 0x06, 0x36, 0x00, // array
              0x06, 0x62, 0x6f, 0x6f, // string
              0x04, 0x08, 0x38, 0x00, // array
              0x02, // block count
              0x06, 0x68, 0x6f, 0x6f, // string
              0x04, 0x06, 0x36, 0x00, // array
              0x00,
            ]).buffer,
          );

          final decoded = type.decode(buffer);

          expect(decoded['foo'], [3, 27]);
          expect(decoded['boo'], [4, 28]);
          expect(decoded['hoo'], [3, 27]);
        });

        test('with blocksize', () {
          const Map<String, dynamic> jsonSchema = {
            'type': 'map',
            'values': {'type': 'array', 'items': 'long'},
          };

          final MapType type = MapType.fromJson(jsonSchema);

          final DataBuffer buffer = DataBuffer(
            Uint8List.fromList([
              0x03, // block count
              0x10, // block size
              0x06, 0x66, 0x6f, 0x6f, // string
              0x04, 0x06, 0x36, 0x00, // array
              0x06, 0x62, 0x6f, 0x6f, // string
              0x04, 0x08, 0x38, 0x00, // array
              0x01, // block count
              0x10, // block size
              0x06, 0x68, 0x6f, 0x6f, // string
              0x04, 0x06, 0x36, 0x00, // array
              0x00,
            ]).buffer,
          );

          final decoded = type.decode(buffer);

          expect(decoded['foo'], [3, 27]);
          expect(decoded['boo'], [4, 28]);
          expect(decoded['hoo'], [3, 27]);
        });
      });
      group('union', () {
        test('string type', () {
          const Map<String, dynamic> jsonSchema = {
            'type': ['null', 'string'],
          };

          final UnionType type = UnionType.fromJson(jsonSchema);

          final DataBuffer buffer = DataBuffer(
            Uint8List.fromList([0x02, 0x02, 0x61]).buffer,
          );

          final decoded = type.decode(buffer);

          expect(decoded, 'a');
        });

        test('null type', () {
          const Map<String, dynamic> jsonSchema = {
            'type': ['null', 'string'],
          };

          final UnionType type = UnionType.fromJson(jsonSchema);

          final DataBuffer buffer = DataBuffer(
            Uint8List.fromList([0x00]).buffer,
          );

          final decoded = type.decode(buffer);

          expect(decoded, isNull);
        });
      });
      test('fixed', () {
        const Map<String, dynamic> jsonSchema = {
          'type': 'fixed',
          'size': 4,
          'name': 'fixed',
        };

        final FixedType type = FixedType.fromJson(jsonSchema);

        final DataBuffer buffer = DataBuffer(
          Uint8List.fromList([0x01, 0x02, 0x03, 0x04]).buffer,
        );

        final decoded = type.decode(buffer);

        expect(decoded, Uint8List.fromList([0x01, 0x02, 0x03, 0x04]));
      });
    });
  });
}
