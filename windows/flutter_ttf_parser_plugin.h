#ifndef FLUTTER_PLUGIN_FLUTTER_TTF_PARSER_PLUGIN_H_
#define FLUTTER_PLUGIN_FLUTTER_TTF_PARSER_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace flutter_ttf_parser {

class FlutterTtfParserPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FlutterTtfParserPlugin();

  virtual ~FlutterTtfParserPlugin();

  // Disallow copy and assign.
  FlutterTtfParserPlugin(const FlutterTtfParserPlugin&) = delete;
  FlutterTtfParserPlugin& operator=(const FlutterTtfParserPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace flutter_ttf_parser

#endif  // FLUTTER_PLUGIN_FLUTTER_TTF_PARSER_PLUGIN_H_
