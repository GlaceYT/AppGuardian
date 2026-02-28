package com.predator.app_guardian

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class BootReceiver : BroadcastReceiver() {
    
    companion object {
        private const val TAG = "BootReceiver"
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED || 
            intent.action == "android.intent.action.QUICKBOOT_POWERON") {
            Log.d(TAG, "Device booted - Device Hub is ready")
            // The AccessibilityService will be restarted automatically by the system
            // if it was enabled before the reboot. No need to manually start it.
        }
    }
}
