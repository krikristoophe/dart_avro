import 'dart:typed_data';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_avro_method_channel.dart';

abstract class FlutterAvroPlatform extends PlatformInterface {
  /// Constructs a FlutterAvroPlatform.
  FlutterAvroPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterAvroPlatform _instance = MethodChannelFlutterAvro();

  /// The default instance of [FlutterAvroPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterAvro].
  static FlutterAvroPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterAvroPlatform] when
  /// they register themselves.
  static set instance(FlutterAvroPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<dynamic> decode(String schema, Uint8List data) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
