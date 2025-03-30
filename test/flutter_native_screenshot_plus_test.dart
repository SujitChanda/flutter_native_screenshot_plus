import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_native_screenshot_plus/flutter_native_screenshot_plus.dart';
import 'package:flutter_native_screenshot_plus/flutter_native_screenshot_plus_platform_interface.dart';
import 'package:flutter_native_screenshot_plus/flutter_native_screenshot_plus_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterNativeScreenshotPlusPlatform
    with MockPlatformInterfaceMixin
    implements FlutterNativeScreenshotPlusPlatform {

  @override
  Future<String?> takeScreenshot() async => 'fake/path/screenshot.png';
}

void main() {
  final initialPlatform = FlutterNativeScreenshotPlusPlatform.instance;

  test('$MethodChannelFlutterNativeScreenshotPlus is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterNativeScreenshotPlus>());
  });

  test('takeScreenshot returns path', () async {
    final plugin = FlutterNativeScreenshotPlus();
    final fakePath = 'fake/path/screenshot.png';

    FlutterNativeScreenshotPlusPlatform.instance =
        MockFlutterNativeScreenshotPlusPlatform();

    expect(await plugin.takeScreenshot(), fakePath);
  });

  tearDown(() {
    FlutterNativeScreenshotPlusPlatform.instance = initialPlatform;
  });
}