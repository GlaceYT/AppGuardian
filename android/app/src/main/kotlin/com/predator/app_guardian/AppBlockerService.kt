package com.predator.app_guardian

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.content.SharedPreferences
import android.util.Log
import android.view.accessibility.AccessibilityEvent

class AppBlockerService : AccessibilityService() {

    companion object {
        private const val TAG = "AppBlockerService"
        private const val PREFS_NAME = "FlutterSharedPreferences"
        var isRunning = false
            private set
    }

    private lateinit var prefs: SharedPreferences

    override fun onServiceConnected() {
        super.onServiceConnected()
        isRunning = true
        prefs = getSharedPreferences(PREFS_NAME, MODE_PRIVATE)
        Log.d(TAG, "AppBlockerService connected")
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return
        if (event.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return

        val packageName = event.packageName?.toString() ?: return
        
        // Don't block ourselves or system UI
        if (packageName == this.packageName || 
            packageName == "com.android.systemui" ||
            packageName == "com.android.launcher" ||
            packageName == "com.android.launcher3" ||
            packageName == "com.google.android.apps.nexuslauncher" ||
            packageName == "com.sec.android.app.launcher" ||
            packageName == "com.miui.home" ||
            packageName == "com.android.settings") {
            return
        }

        // Check if blocking is enabled
        val isEnabled = prefs.getBoolean("flutter.blocking_enabled", false)
        if (!isEnabled) return

        // Get blocked apps list
        val blockedAppsString = prefs.getString("flutter.blocked_apps", "") ?: ""
        if (blockedAppsString.isEmpty()) return

        val blockedApps = blockedAppsString.split(",").map { it.trim() }.filter { it.isNotEmpty() }

        if (packageName in blockedApps) {
            Log.d(TAG, "Blocked app detected: $packageName")
            launchBlocker(packageName)
        }
    }

    private fun launchBlocker(blockedPackage: String) {
        val intent = Intent(this, BlockerActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
            addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
            putExtra("blocked_package", blockedPackage)
        }
        startActivity(intent)
    }

    override fun onInterrupt() {
        Log.d(TAG, "AppBlockerService interrupted")
    }

    override fun onDestroy() {
        isRunning = false
        super.onDestroy()
        Log.d(TAG, "AppBlockerService destroyed")
    }
}
