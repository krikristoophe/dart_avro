import 'dart:typed_data';

import 'package:dart_avro/schema/complex_types.dart';
import 'package:dart_avro/schema/primitive_types.dart';
import 'package:dart_avro/utils/data_buffer.dart';
import 'package:test/test.dart';

void main() {
  group('Encode', () {
    group('primitive types', () {
      test('null', () {
        const NullType type = NullType();

        final encoded = type.encode(null);

        expect(encoded, Uint8List(0));
      });

      group('boolean', () {
        test('is true', () {
          const BooleanType type = BooleanType();

          final encoded = type.encode(true);

          expect(encoded, Uint8List.fromList([1]));
        });
        test('is false', () {
          const BooleanType type = BooleanType();

          final encoded = type.encode(false);

          expect(encoded, Uint8List.fromList([0]));
        });
      });

      group('int', () {
        test('one byte', () {
          const IntType type = IntType();

          final encoded = type.encode(2);

          expect(encoded, Uint8List.fromList([0x04]));
        });
        test('two byte', () {
          const IntType type = IntType();

          final encoded = type.encode(64);

          expect(encoded, Uint8List.fromList([0x80, 0x01]));
        });

        test('one byte negative', () {
          const IntType type = IntType();

          final encoded = type.encode(-2);

          expect(encoded, Uint8List.fromList([0x03]));
        });

        test('more byte', () {
          const IntType type = IntType();

          final encoded = type.encode(3209099);

          expect(encoded, Uint8List.fromList([0x96, 0xde, 0x87, 0x3]));
        });
      });

      group('long', () {
        test('one byte', () {
          const LongType type = LongType();

          final encoded = type.encode(2);

          expect(encoded, Uint8List.fromList([0x04]));
        });
        test('two byte', () {
          const LongType type = LongType();

          final encoded = type.encode(64);

          expect(encoded, Uint8List.fromList([0x80, 0x01]));
        });

        test('one byte negative', () {
          const LongType type = LongType();

          final encoded = type.encode(-2);

          expect(encoded, Uint8List.fromList([0x03]));
        });

        test('more byte', () {
          const LongType type = LongType();

          final encoded = type.encode(3209099);

          expect(encoded, Uint8List.fromList([0x96, 0xde, 0x87, 0x3]));
        });
      });

      test('float', () {
        const FloatType type = FloatType();

        final encoded = type.encode(3.14);

        expect(encoded, Uint8List.fromList([0xc3, 0xf5, 0x48, 0x40]));
      });

      test('double', () {
        const DoubleType type = DoubleType();

        final encoded = type.encode(3.14);

        expect(
          encoded,
          Uint8List.fromList([0x1f, 0x85, 0xeb, 0x51, 0xb8, 0x1e, 0x9, 0x40]),
        );
      });

      test('bytes', () {
        const BytesType type = BytesType();

        final encoded = type.encode(Uint8List.fromList([0x66, 0x6f, 0x6f]));

        expect(encoded, Uint8List.fromList([0x06, 0x66, 0x6f, 0x6f]));
      });

      test('string', () {
        const StringType type = StringType();

        final encoded = type.encode('foo');

        expect(encoded, Uint8List.fromList([0x06, 0x66, 0x6f, 0x6f]));
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

          final encoded = type.encode({
            'long': 3209099,
            'string': 'foo',
          });

          expect(
            encoded,
            Uint8List.fromList([0x96, 0xde, 0x87, 0x3, 0x06, 0x66, 0x6f, 0x6f]),
          );
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

          const payload = {
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

          final encoded = type.encode(payload);

          expect(
            encoded,
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
            ]),
          );
        });
      });

      test('enum', () {
        const Map<String, dynamic> jsonSchema = {
          'type': 'enum',
          'name': 'Suit',
          'symbols': ['SPADES', 'HEARTS', 'DIAMONDS', 'CLUBS'],
        };

        final EnumType type = EnumType.fromJson(jsonSchema);

        final encoded = type.encode('HEARTS');

        expect(encoded, Uint8List.fromList([0x02]));
      });
      test('array', () {
        const Map<String, dynamic> jsonSchema = {
          'type': 'array',
          'items': 'long',
        };

        final ArrayType type = ArrayType.fromJson(jsonSchema);

        final encoded = type.encode([3, 27]);

        expect(encoded, Uint8List.fromList([0x04, 0x06, 0x36, 0x00]));
      });
      group('map', () {
        test('without blocksize', () {
          const Map<String, dynamic> jsonSchema = {
            'type': 'map',
            'values': {'type': 'array', 'items': 'long'},
          };

          final MapType type = MapType.fromJson(jsonSchema);

          final Map<String, dynamic> payload = {
            'foo': [3, 27],
            'boo': [4, 28],
            'hoo': [3, 27],
          };

          final encoded = type.encode(payload);

          final decoded = type.decode(DataBuffer(encoded.buffer));

          expect(
            payload,
            decoded,
          );
        });
      });
      group('union', () {
        test('string type', () {
          const Map<String, dynamic> jsonSchema = {
            'type': ['null', 'string'],
          };

          final UnionType type = UnionType.fromJson(jsonSchema);

          final encoded = type.encode('a');

          expect(encoded, Uint8List.fromList([0x02, 0x02, 0x61]));
        });

        test('null type', () {
          const Map<String, dynamic> jsonSchema = {
            'type': ['null', 'string'],
          };

          final UnionType type = UnionType.fromJson(jsonSchema);

          final encoded = type.encode(null);

          expect(encoded, Uint8List.fromList([0x00]));
        });
      });
      test('fixed', () {
        const Map<String, dynamic> jsonSchema = {
          'type': 'fixed',
          'size': 4,
          'name': 'fixed',
        };

        final FixedType type = FixedType.fromJson(jsonSchema);

        final encoded = type.encode(
          Uint8List.fromList([0x01, 0x02, 0x03, 0x04]),
        );

        expect(encoded, Uint8List.fromList([0x01, 0x02, 0x03, 0x04]));
      });
    });
  });
}
