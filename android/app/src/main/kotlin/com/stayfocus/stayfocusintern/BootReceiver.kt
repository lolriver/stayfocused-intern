package com.stayfocus.stayfocusintern

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Ensures the AccessibilityService picks up the blocked apps list
 * after a device reboot. The AccessibilityService itself auto-restarts
 * when enabled in system settings, but this receiver warms up the
 * SharedPreferences cache early.
 */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED ||
            intent.action == "android.intent.action.QUICKBOOT_POWERON") {
            // Touch SharedPreferences so it's loaded into memory early.
            // The AccessibilityService will pick it up via its listener.
            val prefs = context.getSharedPreferences("app_blocker_prefs", Context.MODE_PRIVATE)
            prefs.getStringSet("blocked_apps", emptySet())
        }
    }
}
