
import 'dart:typed_data';

import 'flutter_avro_platform_interface.dart';

class FlutterAvro {
  Future<dynamic> decode(String schema, Uint8List data) {
    return FlutterAvroPlatform.instance.decode(schema, data);
  }
}
