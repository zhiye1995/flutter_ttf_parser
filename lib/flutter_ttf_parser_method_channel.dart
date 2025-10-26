import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_ttf_parser_platform_interface.dart';

/// An implementation of [FlutterTtfParserPlatform] that uses method channels.
class MethodChannelFlutterTtfParser extends FlutterTtfParserPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_ttf_parser');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
