import Flutter
import UIKit

@objcMembers
public class FlutterNativeScreenshotPlusPlugin: NSObject, FlutterPlugin {
    private var result: FlutterResult?
    private var screenshotPath: String?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_native_screenshot_plus", binaryMessenger: registrar.messenger())
        let instance = FlutterNativeScreenshotPlusPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "takeScreenshot" {
            self.result = result
            captureScreenshot()
        } else {
            result(FlutterMethodNotImplemented)
        }
    }

    private func getScreenshotName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        return "native_screenshot_\(formatter.string(from: Date())).png"
    }

    private func getScreenshotPath() -> URL? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let dir = paths.first else { return nil }
        return dir.appendingPathComponent(getScreenshotName())
    }

    private func saveImageToFile(image: UIImage) -> String? {
        guard let imageData = image.pngData(), let path = getScreenshotPath() else { return nil }
        do {
            try imageData.write(to: path)
            return path.path
        } catch {
            print("Error saving screenshot: \(error)")
            return nil
        }
    }

    @objc private func saveCompleted(image: UIImage, error: NSError?, contextInfo: UnsafeMutableRawPointer?) {
        if error == nil, let screenshotPath = self.screenshotPath {
            result?(screenshotPath)
        } else {
            result?(FlutterError(code: "SAVE_FAILED", message: "Failed to save screenshot", details: nil))
        }
    }

    private func saveImageToGallery(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted(image:error:contextInfo:)), nil)
    }

    private func captureScreenshot() {
        guard let window = UIApplication.shared.windows.first else {
            result?(FlutterError(code: "NO_WINDOW", message: "No active window found", details: nil))
            return
        }

        let renderer = UIGraphicsImageRenderer(size: window.bounds.size)
        let image = renderer.image { _ in
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        }

        guard let path = saveImageToFile(image: image) else {
            result?(FlutterError(code: "WRITE_FAILED", message: "Could not write screenshot", details: nil))
            return
        }

        self.screenshotPath = path
        saveImageToGallery(image: image)
    }
}
