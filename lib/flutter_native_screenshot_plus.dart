import 'flutter_native_screenshot_plus_platform_interface.dart';

class FlutterNativeScreenshotPlus {
  Future<String?> takeScreenshot() {
    return FlutterNativeScreenshotPlusPlatform.instance.takeScreenshot();
  }
}