package com.flutter_native_screenshot.plus.flutter_native_screenshot_plus

import android.app.Activity
import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.media.MediaScannerConnection
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.view.PixelCopy
import android.view.View
import android.view.Window
import androidx.annotation.RequiresApi
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.renderer.FlutterRenderer
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import java.io.File
import java.io.FileOutputStream
import java.text.SimpleDateFormat
import java.util.Date

class FlutterNativeScreenshotPlusPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
  private lateinit var channel: MethodChannel
  private var activity: Activity? = null
  private var context: Context? = null
  private var flutterRenderer: FlutterRenderer? = null

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    context = binding.applicationContext
    flutterRenderer = binding.flutterEngine.renderer
    channel = MethodChannel(binding.binaryMessenger, "flutter_native_screenshot_plus")
    channel.setMethodCallHandler(this)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    context = null
    flutterRenderer = null
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivity() {
    activity = null
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "takeScreenshot" -> takeScreenshot(result)
      else -> result.notImplemented()
    }
  }

  private fun takeScreenshot(result: MethodChannel.Result) {
    val currentActivity = activity ?: return result.error("NO_ACTIVITY", "Activity is null", null)
    val renderer = flutterRenderer ?: return result.error("NO_RENDERER", "FlutterRenderer is null", null)

    try {
      // Use Flutter's built-in bitmap capture for better reliability
      val bitmap = renderer.bitmap ?: return result.error("CAPTURE_ERROR", "Failed to get Flutter bitmap", null)

      val path = saveBitmapToFile(bitmap)
      if (path != null) {
        result.success(path)
      } else {
        result.error("SAVE_ERROR", "Failed to save screenshot", null)
      }
    } catch (e: Exception) {
      result.error("EXCEPTION", "Error capturing screenshot: ${e.message}", null)
    }
  }

  private fun saveBitmapToFile(bitmap: Bitmap): String? {
    return try {
      val timeStamp = SimpleDateFormat("yyyyMMddHHmmss").format(Date())
      val fileName = "screenshot_$timeStamp.png"
      val file = File(context?.getExternalFilesDir(null), fileName)

      FileOutputStream(file).use { out ->
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, out)
        out.flush()
      }

      refreshMediaGallery(file.absolutePath)
      file.absolutePath
    } catch (e: Exception) {
      null
    }
  }

  private fun refreshMediaGallery(filePath: String) {
    context?.let {
      MediaScannerConnection.scanFile(it, arrayOf(filePath), arrayOf("image/png"), null)
    }
  }
}