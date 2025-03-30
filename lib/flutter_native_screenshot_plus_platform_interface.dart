import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_native_screenshot_plus_method_channel.dart';


abstract class FlutterNativeScreenshotPlusPlatform extends PlatformInterface {
  FlutterNativeScreenshotPlusPlatform() : super(token: _token);

  static final Object _token = Object();
  static FlutterNativeScreenshotPlusPlatform _instance =
  MethodChannelFlutterNativeScreenshotPlus();

  static FlutterNativeScreenshotPlusPlatform get instance => _instance;

  static set instance(FlutterNativeScreenshotPlusPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> takeScreenshot() {
    throw UnimplementedError('takeScreenshot() not implemented.');
  }
}
