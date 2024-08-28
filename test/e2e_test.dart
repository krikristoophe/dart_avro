import 'dart:typed_data';

import 'package:dart_avro/schema/complex_types.dart';
import 'package:dart_avro/schema/primitive_types.dart';
import 'package:dart_avro/utils/data_buffer.dart';
import 'package:test/test.dart';

void main() {
  group('E2E', () {
    group('primitive types', () {
      test('null', () {
        const NullType type = NullType();

        const Null payload = null;

        final encoded = type.encode(payload);

        final decoded = type.decode(DataBuffer(encoded.buffer));

        expect(payload, decoded);
      });

      group('boolean', () {
        test('is true', () {
          const BooleanType type = BooleanType();

          const payload = true;

          final encoded = type.encode(payload);

          final decoded = type.decode(DataBuffer(encoded.buffer));

          expect(payload, decoded);
        });
        test('is false', () {
          const BooleanType type = BooleanType();

          const payload = false;

          final encoded = type.encode(payload);

          final decoded = type.decode(DataBuffer(encoded.buffer));

          expect(payload, decoded);
        });
      });

      group('int', () {
        test('one byte', () {
          const IntType type = IntType();

          const payload = 2;

          final encoded = type.encode(payload);

          final decoded = type.decode(DataBuffer(encoded.buffer));

          expect(payload, decoded);
        });
        test('two byte', () {
          const IntType type = IntType();

          const payload = 64;

          final encoded = type.encode(payload);

          final decoded = type.decode(DataBuffer(encoded.buffer));

          expect(payload, decoded);
        });

        test('one byte negative', () {
          const IntType type = IntType();

          const payload = -2;

          final encoded = type.encode(payload);

          final decoded = type.decode(DataBuffer(encoded.buffer));

          expect(payload, decoded);
        });

        test('more byte', () {
          const IntType type = IntType();

          const payload = 3209099;

          final encoded = type.encode(payload);

          final decoded = type.decode(DataBuffer(encoded.buffer));

          expect(payload, decoded);
        });
      });

      group('long', () {
        test('one byte', () {
          const LongType type = LongType();

          const payload = 2;

          final encoded = type.encode(payload);

          final decoded = type.decode(DataBuffer(encoded.buffer));

          expect(payload, decoded);
        });
        test('two byte', () {
          const LongType type = LongType();

          const payload = 64;

          final encoded = type.encode(payload);

          final decoded = type.decode(DataBuffer(encoded.buffer));

          expect(payload, decoded);
        });

        test('one byte negative', () {
          const LongType type = LongType();

          const payload = -2;

          final encoded = type.encode(payload);

          final decoded = type.decode(DataBuffer(encoded.buffer));

          expect(payload, decoded);
        });

        test('more byte', () {
          const LongType type = LongType();

          const payload = 3209099;

          final encoded = type.encode(payload);

          final decoded = type.decode(DataBuffer(encoded.buffer));

          expect(payload, decoded);
        });
      });

      test('float', () {
        const FloatType type = FloatType();

        const payload = 3.14;

        final encoded = type.encode(payload);

        final decoded = type.decode(DataBuffer(encoded.buffer));

        expect(payload.toStringAsFixed(3), decoded.toStringAsFixed(3));
      });

      test('double', () {
        const DoubleType type = DoubleType();

        const payload = 3.14;

        final encoded = type.encode(payload);

        final decoded = type.decode(DataBuffer(encoded.buffer));

        expect(payload, decoded);
      });

      test('bytes', () {
        const BytesType type = BytesType();
        final payload = Uint8List.fromList([0x66, 0x6f, 0x6f]);

        final encoded = type.encode(payload);

        final decoded = type.decode(DataBuffer(encoded.buffer));

        expect(payload, decoded);
      });

      test('string', () {
        const StringType type = StringType();

        const payload = 'foo';

        final encoded = type.encode(payload);

        final decoded = type.decode(DataBuffer(encoded.buffer));

        expect(payload, decoded);
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

          final payload = {
            'long': 3209099,
            'string': 'foo',
          };

          final encoded = type.encode(payload);

          final decoded = type.decode(DataBuffer(encoded.buffer));

          expect(payload, decoded);
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

          final decoded = type.decode(DataBuffer(encoded.buffer));

          expect(payload, decoded);
        });
      });

      test('enum', () {
        const Map<String, dynamic> jsonSchema = {
          'type': 'enum',
          'name': 'Suit',
          'symbols': ['SPADES', 'HEARTS', 'DIAMONDS', 'CLUBS'],
        };

        final EnumType type = EnumType.fromJson(jsonSchema);
        const payload = 'HEARTS';

        final encoded = type.encode(payload);

        final decoded = type.decode(DataBuffer(encoded.buffer));

        expect(payload, decoded);
      });
      test('array', () {
        const Map<String, dynamic> jsonSchema = {
          'type': 'array',
          'items': 'long',
        };

        final ArrayType type = ArrayType.fromJson(jsonSchema);

        final payload = [3, 27];

        final encoded = type.encode(payload);

        final decoded = type.decode(DataBuffer(encoded.buffer));

        expect(payload, decoded);
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

          expect(payload, decoded);
        });
      });
      group('union', () {
        test('string type', () {
          const Map<String, dynamic> jsonSchema = {
            'type': ['null', 'string'],
          };

          final UnionType type = UnionType.fromJson(jsonSchema);

          const payload = 'a';

          final encoded = type.encode(payload);

          final decoded = type.decode(DataBuffer(encoded.buffer));

          expect(payload, decoded);
        });

        test('null type', () {
          const Map<String, dynamic> jsonSchema = {
            'type': ['null', 'string'],
          };

          final UnionType type = UnionType.fromJson(jsonSchema);

          const String? payload = null;

          final encoded = type.encode(payload);

          final decoded = type.decode(DataBuffer(encoded.buffer));

          expect(payload, decoded);
        });
      });
      test('fixed', () {
        const Map<String, dynamic> jsonSchema = {
          'type': 'fixed',
          'size': 4,
          'name': 'fixed',
        };

        final FixedType type = FixedType.fromJson(jsonSchema);

        final payload = Uint8List.fromList([0x01, 0x02, 0x03, 0x04]);

        final encoded = type.encode(payload);

        final decoded = type.decode(DataBuffer(encoded.buffer));

        expect(payload, decoded);
      });
    });
  });
}
