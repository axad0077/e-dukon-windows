package com.example.dokon_boshqaruv

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.hardware.camera2.CameraCharacteristics
import android.hardware.camera2.CameraManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger,
            "dokon_boshqaruv/camera_diagnostics").setMethodCallHandler { call, result ->
            if (call.method != "probe") {
                result.notImplemented()
            } else {
                try {
                    val manager = getSystemService(Context.CAMERA_SERVICE) as CameraManager
                    val cameras = manager.cameraIdList.map { id ->
                        try {
                            val info = manager.getCameraCharacteristics(id)
                            mapOf<String, Any?>(
                                "id" to id,
                                "facing" to info.get(CameraCharacteristics.LENS_FACING),
                                "hardware_level" to info.get(CameraCharacteristics.INFO_SUPPORTED_HARDWARE_LEVEL),
                                "flash" to info.get(CameraCharacteristics.FLASH_INFO_AVAILABLE)
                            )
                        } catch (error: Exception) {
                            mapOf<String, Any?>("id" to id, "error" to error.toString())
                        }
                    }
                    @Suppress("DEPRECATION")
                    val info = packageManager.getPackageInfo(packageName, 0)
                    result.success(mapOf(
                        "patch" to "camera-fix-2026-10-26-v1",
                        "manufacturer" to Build.MANUFACTURER,
                        "model" to Build.MODEL,
                        "android_sdk" to Build.VERSION.SDK_INT,
                        "android_release" to Build.VERSION.RELEASE,
                        "app_version" to info.versionName,
                        "camera_permission" to (checkSelfPermission(Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED),
                        "camera_count" to cameras.size,
                        "cameras" to cameras
                    ))
                } catch (error: Exception) {
                    result.error("CAMERA_PROBE", error.toString(),
                        mapOf("stage" to "android.camera2.enumerate",
                            "stack" to error.stackTraceToString().take(10000)))
                }
            }
        }
    }
}
