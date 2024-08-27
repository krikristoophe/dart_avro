import 'package:dart_avro/schema/complex_types.dart';
import 'package:dart_avro/schema/primitive_types.dart';
import 'package:dart_avro/schema/schema.dart';
import 'package:test/test.dart';

void main() {
  group('Schema', () {
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
        const Map<String, dynamic> jsonSchema = {'type': 'null'};

        final Schema schema = Schema.fromJson(jsonSchema);

        expect(schema.type, isA<NullType>());
      });

      test('boolean', () {
        const Map<String, dynamic> jsonSchema = {'type': 'boolean'};

        final Schema schema = Schema.fromJson(jsonSchema);

        expect(schema.type, isA<BooleanType>());
      });

      test('int', () {
        const Map<String, dynamic> jsonSchema = {'type': 'int'};

        final Schema schema = Schema.fromJson(jsonSchema);

        expect(schema.type, isA<IntType>());
      });

      test('long', () {
        const Map<String, dynamic> jsonSchema = {'type': 'long'};

        final Schema schema = Schema.fromJson(jsonSchema);

        expect(schema.type, isA<LongType>());
      });

      test('float', () {
        const Map<String, dynamic> jsonSchema = {'type': 'float'};

        final Schema schema = Schema.fromJson(jsonSchema);

        expect(schema.type, isA<FloatType>());
      });

      test('double', () {
        const Map<String, dynamic> jsonSchema = {'type': 'double'};

        final Schema schema = Schema.fromJson(jsonSchema);

        expect(schema.type, isA<DoubleType>());
      });

      test('bytes', () {
        const Map<String, dynamic> jsonSchema = {'type': 'bytes'};

        final Schema schema = Schema.fromJson(jsonSchema);

        expect(schema.type, isA<BytesType>());
      });

      test('string', () {
        const Map<String, dynamic> jsonSchema = {'type': 'string'};

        final Schema schema = Schema.fromJson(jsonSchema);

        expect(schema.type, isA<StringType>());
      });
    });

    group('complex types', () {
      test('record', () {
        const Map<String, dynamic> jsonSchema = {
          'type': 'record',
          'name': 'LongList',
          'aliases': ['LinkedLongs'],
          'fields': [
            {'name': 'value', 'type': 'long'},
            {
              'name': 'next',
              'type': ['null', 'string'],
            }
          ],
        };

        final Schema schema = Schema.fromJson(jsonSchema);

        expect(schema.type, isA<RecordType>());
        final RecordType type = schema.type as RecordType;
        expect(type.name, jsonSchema['name']);
        expect(type.aliases, jsonSchema['aliases'] ?? <String>[]);
        expect(type.doc, jsonSchema['doc']);
        expect(type.namespace, jsonSchema['namespace']);
        final RecordField firstField = type.fields[0];
        final RecordField secondField = type.fields[1];
        expect(firstField.type, isA<LongType>());
        expect(firstField.name, 'value');
        expect(secondField.type, isA<UnionType>());
        expect(secondField.name, 'next');

        final UnionType unionField = type.fields[1].type as UnionType;
        expect(unionField.type[0], isA<NullType>());
        expect(unionField.type[1], isA<StringType>());
      });

      test('enums', () {
        const Map<String, dynamic> jsonSchema = {
          'type': 'enum',
          'name': 'Suit',
          'symbols': ['SPADES', 'HEARTS', 'DIAMONDS', 'CLUBS'],
        };

        final Schema schema = Schema.fromJson(jsonSchema);

        expect(schema.type, isA<EnumType>());
        final EnumType type = schema.type as EnumType;
        expect(type.name, jsonSchema['name']);
        expect(type.aliases, jsonSchema['aliases'] ?? <String>[]);
        expect(type.namespace, jsonSchema['namespace']);
        expect(type.doc, jsonSchema['doc']);
        expect(type.symbols, jsonSchema['symbols']);
      });

      test('fixed', () {
        const Map<String, dynamic> jsonSchema = {
          'type': 'fixed',
          'size': 16,
          'name': 'md5',
        };

        final Schema schema = Schema.fromJson(jsonSchema);

        expect(schema.type, isA<FixedType>());
        final FixedType type = schema.type as FixedType;
        expect(type.name, jsonSchema['name']);
        expect(type.aliases, jsonSchema['aliases'] ?? <String>[]);
        expect(type.namespace, jsonSchema['namespace']);
        expect(type.size, jsonSchema['size']);
      });

      test('array', () {
        const Map<String, dynamic> jsonSchema = {
          'type': 'array',
          'items': 'string',
          'default': <String>[],
        };

        final Schema schema = Schema.fromJson(jsonSchema);

        expect(schema.type, isA<ArrayType>());
        final ArrayType type = schema.type as ArrayType;
        expect(type.items, isA<StringType>());
      });

      test('map', () {
        const Map<String, dynamic> jsonSchema = {
          'type': 'map',
          'values': 'long',
          'default': <String, dynamic>{},
        };

        final Schema schema = Schema.fromJson(jsonSchema);

        expect(schema.type, isA<MapType>());
        final MapType type = schema.type as MapType;
        expect(type.values, isA<LongType>());
      });

      test('union', () {
        const Map<String, dynamic> jsonSchema = {
          'type': [
            'null',
            'string',
            {
              'type': 'record',
              'name': 'recordInUnion',
              'fields': <Map<String, dynamic>>[],
            }
          ],
        };

        final Schema schema = Schema.fromJson(jsonSchema);

        expect(schema.type, isA<UnionType>());
        final UnionType type = schema.type as UnionType;
        expect(type.type[0], isA<NullType>());
        expect(type.type[1], isA<StringType>());
        expect(type.type[2], isA<RecordType>());
      });
    });

    group('Edge cases', () {
      test('string not json', () {
        final Schema schema = Schema.parse('string');

        expect(schema.type, isA<StringType>());
      });
    });
  });
}
