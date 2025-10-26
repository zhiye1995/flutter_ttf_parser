import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_ttf_parser_method_channel.dart';

abstract class FlutterTtfParserPlatform extends PlatformInterface {
  /// Constructs a FlutterTtfParserPlatform.
  FlutterTtfParserPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterTtfParserPlatform _instance = MethodChannelFlutterTtfParser();

  /// The default instance of [FlutterTtfParserPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterTtfParser].
  static FlutterTtfParserPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterTtfParserPlatform] when
  /// they register themselves.
  static set instance(FlutterTtfParserPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
