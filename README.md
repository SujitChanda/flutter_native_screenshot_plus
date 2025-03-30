# Flutter Native Screenshot Plus 📸

[![pub package](https://img.shields.io/pub/v/flutter_native_screenshot_plus.svg)](https://pub.dev/packages/flutter_native_screenshot_plus)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)
[![Platform: Android & iOS](https://img.shields.io/badge/platform-Android%20%7C%20iOS-blue.svg)]()

A high-performance Flutter plugin for capturing native screenshots with PixelCopy support (Android 8.0+). Captures exactly what users see on screen.

## Table of Contents
- [Features](#features-✨)
- [Installation](#installation-🔧)
- [Platform Setup](#platform-setup-⚙️)
  - [Android](#android)
  - [iOS](#ios)
- [Usage](#usage-🚀)
- [Permission Handling](#permission-handling-🔐)
- [Example Project](#example-project-🧩)
- [FAQ](#faq-❓)
- [Troubleshooting](#troubleshooting-⚠️)
- [Contributing](#contributing-🤝)
- [License](#license-📜)

## Features ✨
- **Native Performance**: Uses platform-specific APIs (PixelCopy on Android)
- **High Fidelity**: Captures exactly what's displayed on screen
- **Simple API**: Single method call with path return
- **Automatic Media Scanning**: Screenshots appear in gallery immediately
- **Thread-Safe**: Background processing for large screenshots

## Installation 🔧
Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_native_screenshot_plus: ^1.0.0
```

Then run:
```bash
flutter pub get
```

## Platform Setup ⚙️

### Android
1. Add permissions to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

2. For Android 10+ compatibility, add to the `<application>` tag:
```xml
android:requestLegacyExternalStorage="true"
```

### iOS
Add to `ios/Runner/Info.plist`:
```xml
<key>NSPhotoLibraryAddUsageDescription</key>
<string>$(PRODUCT_NAME) saves screenshots to your photo library</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>$(PRODUCT_NAME) saves screenshots to your photo library</string>
```

## Usage 🚀
Basic implementation:
```dart
import 'package:flutter_native_screenshot_plus/flutter_native_screenshot_plus.dart';

// Capture and save screenshot
final path = await FlutterNativeScreenshotPlus().takeScreenshot();

if (path != null) {
  // Use the file path (display preview, upload, etc.)
  print('Screenshot saved at: \$path'); 
} else {
  print('Failed to capture screenshot');
}
```

## Permission Handling 🔐
This plugin requires these permissions but doesn't handle runtime requests. We recommend using [permission_handler](https://pub.dev/packages/permission_handler):

```dart
// Example permission check
final status = await [Permission.storage, Permission.photos].request();
if (status[Permission.storage]!.isGranted) {
  // Proceed with screenshot
}
```

## Example Project 🧩
See complete implementation in the [example folder](example/). To run:
```bash
cd example
flutter run
```

## FAQ ❓

### Where are screenshots saved?
| Platform | Location |
|----------|----------|
| Android | `/storage/emulated/0/Android/data/<package_name>/cache` |
| iOS | App's Documents directory |

### Why do I get black screenshots?
1. Ensure permissions are granted
2. On Android, wait for UI rendering to complete:
```dart
await Future.delayed(const Duration(milliseconds: 300));
```

### How to share the screenshot?
Use the [share_plus](https://pub.dev/packages/share_plus) package:
```dart
await Share.shareXFiles([XFile(screenshotPath)]);
```

## Troubleshooting ⚠️

### Android Errors
- **"File not found"**: Check if storage permissions are granted
- **"Blank images"**: Add delay before capturing

### iOS Errors
- **Missing permissions**: Verify Info.plist entries
- **Sandbox issues**: Use app-specific directories

## Contributing 🤝
We welcome contributions! Please follow these steps:
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License 📜
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

Made with ❤️ by Sujit Chanda. Happy screenshotting! 📱💥