package com.stayfocus.stayfocusintern

import android.app.Activity
import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import android.view.Gravity
import android.graphics.Color
import android.util.TypedValue

class BlockingActivity : Activity() {

    private var blockedPackage: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        blockedPackage = intent.getStringExtra("blocked_package")

        // Kill the blocked app immediately
        killBlockedApp()

        // Programmatic layout
        val layout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setBackgroundColor(Color.BLACK)
            setPadding(48, 48, 48, 48)
        }

        val icon = TextView(this).apply {
            text = "🚫"
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 64f)
            gravity = Gravity.CENTER
        }

        val message = TextView(this).apply {
            text = "This app is blocked.\nStay focused."
            setTextColor(Color.WHITE)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 24f)
            gravity = Gravity.CENTER
        }

        val spacer = TextView(this).apply {
            text = ""
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 32f)
        }

        val button = Button(this).apply {
            text = "Go Back"
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 18f)
            setOnClickListener {
                goHome()
            }
        }

        layout.addView(icon)
        layout.addView(message)
        layout.addView(spacer)
        layout.addView(button)

        setContentView(layout)
    }

    override fun onNewIntent(intent: Intent?) {
        super.onNewIntent(intent)
        // Handle re-launch via singleTop
        blockedPackage = intent?.getStringExtra("blocked_package") ?: blockedPackage
        killBlockedApp()
    }

    override fun onResume() {
        super.onResume()
        // Also try to kill on resume in case it's still lingering
        killBlockedApp()
    }

    @Suppress("DEPRECATION")
    override fun onBackPressed() {
        // Always go home — never let back press escape to the blocked app
        goHome()
    }

    private fun killBlockedApp() {
        val pkg = blockedPackage ?: return
        try {
            val am = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            am.killBackgroundProcesses(pkg)
        } catch (_: Exception) {
            // Best effort
        }
    }

    private fun goHome() {
        killBlockedApp()
        val homeIntent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        startActivity(homeIntent)
        finish()
    }
}
