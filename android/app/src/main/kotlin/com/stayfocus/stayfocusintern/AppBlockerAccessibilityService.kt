package com.stayfocus.stayfocusintern

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.view.accessibility.AccessibilityEvent

class AppBlockerAccessibilityService : AccessibilityService() {

    companion object {
        private const val PREFS_NAME = "app_blocker_prefs"
        private const val KEY_BLOCKED_APPS = "blocked_apps"
        private const val COOLDOWN_MS = 100L // Very short cooldown — just prevents double-launch
    }

    // In-memory cache — avoids disk read on every event
    @Volatile
    private var cachedBlockedApps: Set<String> = emptySet()

    // Per-package cooldown tracking
    private val lastBlockedTimeMap = mutableMapOf<String, Long>()

    private var lastForegroundPackage: String? = null

    // System packages to never block
    private val systemPackages = setOf(
        "com.android.systemui",
        "com.android.settings",
        "com.android.launcher",
        "com.android.launcher3",
        "com.google.android.apps.nexuslauncher",
        "com.sec.android.app.launcher",        // Samsung
        "com.miui.home",                        // Xiaomi
        "com.huawei.android.launcher",          // Huawei
        "com.oppo.launcher",                    // Oppo
        "com.vivo.launcher",                    // Vivo
        "com.android.packageinstaller",
        "com.google.android.packageinstaller",
        "com.android.permissioncontroller"
    )

    private val prefsListener = SharedPreferences.OnSharedPreferenceChangeListener { prefs, key ->
        if (key == KEY_BLOCKED_APPS) {
            cachedBlockedApps = prefs.getStringSet(KEY_BLOCKED_APPS, emptySet())?.toSet() ?: emptySet()
        }
    }

    override fun onServiceConnected() {
        super.onServiceConnected()

        // Load blocked apps into memory cache
        val prefs = applicationContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        cachedBlockedApps = prefs.getStringSet(KEY_BLOCKED_APPS, emptySet())?.toSet() ?: emptySet()

        // Listen for changes so cache stays in sync
        prefs.registerOnSharedPreferenceChangeListener(prefsListener)

        // Configure service for fast detection
        val info = serviceInfo ?: AccessibilityServiceInfo()
        info.eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED
        info.feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
        info.flags = AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS
        info.notificationTimeout = 50 // 50ms — very fast
        serviceInfo = info
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return
        if (event.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return

        val packageName = event.packageName?.toString() ?: return

        // Don't block ourselves
        if (packageName == applicationContext.packageName) return

        // Don't block known system packages
        if (systemPackages.contains(packageName)) return
        if (packageName.contains("launcher")) return

        // Track foreground app
        lastForegroundPackage = packageName

        // Check against in-memory cache (no disk read!)
        if (cachedBlockedApps.contains(packageName)) {
            val now = System.currentTimeMillis()
            val lastTime = lastBlockedTimeMap[packageName] ?: 0L

            // Minimal cooldown — just prevents the same launch intent from firing twice
            if (now - lastTime < COOLDOWN_MS) return
            lastBlockedTimeMap[packageName] = now

            // Launch blocking activity immediately
            val intent = Intent(applicationContext, BlockingActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
                addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION)
                putExtra("blocked_package", packageName)
            }
            applicationContext.startActivity(intent)

            // Kill the blocked app's background process to prevent recent-apps resume
            try {
                val am = applicationContext.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
                am.killBackgroundProcesses(packageName)
            } catch (_: Exception) {
                // Best effort — may not work on all devices
            }
        }
    }

    override fun onInterrupt() {
        // Required override — no-op
    }

    override fun onDestroy() {
        try {
            val prefs = applicationContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            prefs.unregisterOnSharedPreferenceChangeListener(prefsListener)
        } catch (_: Exception) {}
        super.onDestroy()
    }
}
