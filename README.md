# dart_avro

A pure dart package to decode avro encoding

## Getting Started

```dart
final Uint8List data  = Uint8List.fromList([0x04]);
final Map<String, dynamic> schema = {
  'type': 'int',
};

final int decoded = DartAvro.decodeJson(schema, data);
```

## Types

| avro type | dart type |
|:----:|:----:|
| null | null |
| boolean | bool |
| int, long | int |
| double, float | double |
| bytes, fixed | Uint8List |
| string | String |
| record, map | Map<String, dynamic> |
| enum | string |
| array | List<dynamic> |

## TODO

- Encoding
- Model generation