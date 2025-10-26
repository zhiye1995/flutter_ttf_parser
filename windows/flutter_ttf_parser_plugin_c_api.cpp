#include "include/flutter_ttf_parser/flutter_ttf_parser_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "flutter_ttf_parser_plugin.h"

void FlutterTtfParserPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  flutter_ttf_parser::FlutterTtfParserPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
