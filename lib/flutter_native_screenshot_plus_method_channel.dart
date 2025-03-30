import 'package:flutter/services.dart';
import 'flutter_native_screenshot_plus_platform_interface.dart';

class MethodChannelFlutterNativeScreenshotPlus
    extends FlutterNativeScreenshotPlusPlatform {
  static const MethodChannel _channel =
  MethodChannel('flutter_native_screenshot_plus');

  @override
  Future<String?> takeScreenshot() async {
    return await _channel.invokeMethod<String>('takeScreenshot');
  }
}