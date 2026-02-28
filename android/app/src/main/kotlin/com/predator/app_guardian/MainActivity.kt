package com.predator.app_guardian

import android.app.AppOpsManager
import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.net.Uri
import android.os.Build
import android.os.Process
import android.provider.Settings
import android.util.Base64
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.predator.app_guardian/native"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInstalledApps" -> {
                    try {
                        val apps = getInstalledApps()
                        result.success(apps)
                    } catch (e: Exception) {
                        result.error("ERROR", "Failed to get installed apps: ${e.message}", null)
                    }
                }
                "isAccessibilityServiceEnabled" -> {
                    result.success(isAccessibilityServiceEnabled())
                }
                "openAccessibilitySettings" -> {
                    val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(intent)
                    result.success(true)
                }
                "isUsageStatsPermissionGranted" -> {
                    result.success(isUsageStatsPermissionGranted())
                }
                "openUsageStatsSettings" -> {
                    val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(intent)
                    result.success(true)
                }
                "isDeviceAdminActive" -> {
                    result.success(isDeviceAdminActive())
                }
                "requestDeviceAdmin" -> {
                    val componentName = ComponentName(this, AppGuardianDeviceAdmin::class.java)
                    val intent = Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN).apply {
                        putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, componentName)
                        putExtra(
                            DevicePolicyManager.EXTRA_ADD_EXPLANATION,
                            "Device Hub needs admin privileges to prevent unauthorized uninstallation and protect your device."
                        )
                    }
                    startActivity(intent)
                    result.success(true)
                }
                "isOverlayPermissionGranted" -> {
                    result.success(Settings.canDrawOverlays(this))
                }
                "requestOverlayPermission" -> {
                    val intent = Intent(
                        Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                        Uri.parse("package:$packageName")
                    )
                    startActivity(intent)
                    result.success(true)
                }
                "getServiceStatus" -> {
                    val status = mapOf(
                        "accessibility" to isAccessibilityServiceEnabled(),
                        "usageStats" to isUsageStatsPermissionGranted(),
                        "deviceAdmin" to isDeviceAdminActive(),
                        "overlay" to Settings.canDrawOverlays(this)
                    )
                    result.success(status)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun getInstalledApps(): List<Map<String, Any?>> {
        val pm = packageManager
        val mainIntent = Intent(Intent.ACTION_MAIN, null).apply {
            addCategory(Intent.CATEGORY_LAUNCHER)
        }

        val resolveInfos = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            pm.queryIntentActivities(mainIntent, PackageManager.ResolveInfoFlags.of(0))
        } else {
            @Suppress("DEPRECATION")
            pm.queryIntentActivities(mainIntent, 0)
        }

        val apps = mutableListOf<Map<String, Any?>>()
        val myPackage = packageName

        for (resolveInfo in resolveInfos) {
            val activityInfo = resolveInfo.activityInfo
            val pkgName = activityInfo.packageName

            // Skip our own app
            if (pkgName == myPackage) continue

            // Skip some critical system apps
            if (pkgName == "com.android.settings" || 
                pkgName == "com.android.systemui") continue

            val appName = resolveInfo.loadLabel(pm).toString()
            val isSystemApp = (activityInfo.applicationInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0

            // Get app icon as base64
            var iconBase64: String? = null
            try {
                val drawable = resolveInfo.loadIcon(pm)
                iconBase64 = drawableToBase64(drawable)
            } catch (e: Exception) {
                // Icon not available
            }

            apps.add(mapOf(
                "packageName" to pkgName,
                "appName" to appName,
                "isSystemApp" to isSystemApp,
                "icon" to iconBase64
            ))
        }

        // Sort by app name
        return apps.sortedBy { (it["appName"] as? String)?.lowercase() }
    }

    private fun drawableToBase64(drawable: Drawable): String {
        val bitmap = if (drawable is BitmapDrawable) {
            drawable.bitmap
        } else {
            val width = drawable.intrinsicWidth.coerceAtLeast(1)
            val height = drawable.intrinsicHeight.coerceAtLeast(1)
            val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bitmap)
            drawable.setBounds(0, 0, canvas.width, canvas.height)
            drawable.draw(canvas)
            bitmap
        }

        // Scale down to save memory
        val scaledBitmap = Bitmap.createScaledBitmap(bitmap, 72, 72, true)
        val stream = ByteArrayOutputStream()
        scaledBitmap.compress(Bitmap.CompressFormat.PNG, 80, stream)
        val bytes = stream.toByteArray()
        return Base64.encodeToString(bytes, Base64.NO_WRAP)
    }

    private fun isAccessibilityServiceEnabled(): Boolean {
        val serviceName = "$packageName/${AppBlockerService::class.java.canonicalName}"
        val enabledServices = Settings.Secure.getString(
            contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        ) ?: return false
        return enabledServices.contains(serviceName)
    }

    private fun isUsageStatsPermissionGranted(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOps.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            Process.myUid(),
            packageName
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun isDeviceAdminActive(): Boolean {
        val devicePolicyManager = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        val componentName = ComponentName(this, AppGuardianDeviceAdmin::class.java)
        return devicePolicyManager.isAdminActive(componentName)
    }
}
