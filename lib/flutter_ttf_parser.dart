
import 'flutter_ttf_parser_platform_interface.dart';

export 'ttf_parser/ttf_parser.dart';

class FlutterTtfParser {
  Future<String?> getPlatformVersion() {
    return FlutterTtfParserPlatform.instance.getPlatformVersion();
  }
}
