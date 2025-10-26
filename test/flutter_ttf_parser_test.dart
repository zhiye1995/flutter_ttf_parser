import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ttf_parser/flutter_ttf_parser.dart';
import 'package:flutter_ttf_parser/flutter_ttf_parser_platform_interface.dart';
import 'package:flutter_ttf_parser/flutter_ttf_parser_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterTtfParserPlatform
    with MockPlatformInterfaceMixin
    implements FlutterTtfParserPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterTtfParserPlatform initialPlatform = FlutterTtfParserPlatform.instance;

  test('$MethodChannelFlutterTtfParser is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterTtfParser>());
  });

  test('getPlatformVersion', () async {
    FlutterTtfParser flutterTtfParserPlugin = FlutterTtfParser();
    MockFlutterTtfParserPlatform fakePlatform = MockFlutterTtfParserPlatform();
    FlutterTtfParserPlatform.instance = fakePlatform;

    expect(await flutterTtfParserPlugin.getPlatformVersion(), '42');
  });
}
