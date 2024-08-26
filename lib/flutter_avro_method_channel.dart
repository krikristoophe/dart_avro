import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_avro_platform_interface.dart';

/// An implementation of [FlutterAvroPlatform] that uses method channels.
class MethodChannelFlutterAvro extends FlutterAvroPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_avro');

  @override
  Future<dynamic> decode(String schema, Uint8List data) async {
    final result = await methodChannel.invokeMethod<dynamic>('decode', {
      'schema': schema,
      'data': base64.encode(data),
    });
    return result;
  }
}
