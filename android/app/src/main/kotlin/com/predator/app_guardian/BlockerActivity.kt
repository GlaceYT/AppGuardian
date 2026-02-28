package com.predator.app_guardian

import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Bundle
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.view.animation.AccelerateDecelerateInterpolator
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import kotlin.random.Random

class BlockerActivity : Activity() {

    private var blockedPackage: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        blockedPackage = intent.getStringExtra("blocked_package")

        // Make fullscreen
        window.apply {
            addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                attributes.layoutInDisplayCutoutMode =
                    WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES
            }
            decorView.systemUiVisibility = (
                View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                or View.SYSTEM_UI_FLAG_FULLSCREEN
                or View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                or View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
            )
            navigationBarColor = Color.parseColor("#FAFAFA")
            statusBarColor = Color.parseColor("#FAFAFA")
            // Light status bar icons (dark icons on light bg)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                decorView.systemUiVisibility = decorView.systemUiVisibility or
                    View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR
            }
        }

        // ── Random wait times that never end ──
        val waitHours = listOf(
            "2 hours 30 minutes",
            "4 hours 15 minutes", 
            "5 hours 45 minutes",
            "6 hours 10 minutes",
            "8 hours 20 minutes",
            "10 hours 30 minutes",
            "12 hours",
            "3 hours 50 minutes",
            "7 hours 25 minutes",
            "1 hour 45 minutes"
        )
        val randomWait = waitHours[Random.nextInt(waitHours.size)]

        // Get blocked app name & icon
        var appName = "this app"
        var appIcon: android.graphics.drawable.Drawable? = null
        if (blockedPackage != null) {
            try {
                val pm = packageManager
                val appInfo = pm.getApplicationInfo(blockedPackage!!, 0)
                appName = pm.getApplicationLabel(appInfo).toString()
                appIcon = pm.getApplicationIcon(appInfo)
            } catch (_: Exception) {}
        }

        // ── Build the "Server Down" UI ──
        val rootLayout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setPadding(dpToPx(32), dpToPx(60), dpToPx(32), dpToPx(40))
            setBackgroundColor(Color.parseColor("#FAFAFA"))
        }

        // App icon (the blocked app's actual icon)
        val iconView = ImageView(this).apply {
            if (appIcon != null) {
                setImageDrawable(appIcon)
            }
            val params = LinearLayout.LayoutParams(dpToPx(80), dpToPx(80))
            params.bottomMargin = dpToPx(28)
            layoutParams = params
            // Slight greyscale tint to make it look "offline"
            alpha = 0.6f
        }

        // Warning icon
        val warningIcon = TextView(this).apply {
            text = "⚠️"
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 56f)
            gravity = Gravity.CENTER
            val params = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
            params.bottomMargin = dpToPx(20)
            layoutParams = params
        }

        // "Server Error" title
        val titleText = TextView(this).apply {
            text = "Server Unavailable"
            setTextColor(Color.parseColor("#212121"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 24f)
            typeface = Typeface.create("sans-serif-medium", Typeface.BOLD)
            gravity = Gravity.CENTER
            val params = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
            params.bottomMargin = dpToPx(12)
            layoutParams = params
        }

        // Subtitle / error message
        val messageText = TextView(this).apply {
            text = "Sorry, $appName servers are currently " +
                   "experiencing issues. Our team is working to " +
                   "resolve this as quickly as possible."
            setTextColor(Color.parseColor("#757575"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 15f)
            typeface = Typeface.create("sans-serif", Typeface.NORMAL)
            gravity = Gravity.CENTER
            setLineSpacing(dpToPx(3).toFloat(), 1f)
            val params = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
            params.bottomMargin = dpToPx(28)
            layoutParams = params
        }

        // Divider
        val divider = View(this).apply {
            setBackgroundColor(Color.parseColor("#E0E0E0"))
            val params = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                dpToPx(1)
            )
            params.bottomMargin = dpToPx(20)
            layoutParams = params
        }

        // Expected availability card
        val etaCard = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setPadding(dpToPx(20), dpToPx(16), dpToPx(20), dpToPx(16))
            val cardBg = GradientDrawable().apply {
                shape = GradientDrawable.RECTANGLE
                cornerRadius = dpToPx(14).toFloat()
                setColor(Color.parseColor("#FFF3E0"))
                setStroke(dpToPx(1), Color.parseColor("#FFE0B2"))
            }
            background = cardBg
            val params = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
            params.bottomMargin = dpToPx(24)
            layoutParams = params
        }

        val etaIcon = TextView(this).apply {
            text = "🕐"
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 22f)
            gravity = Gravity.CENTER
            val params = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
            params.bottomMargin = dpToPx(6)
            layoutParams = params
        }

        val etaLabel = TextView(this).apply {
            text = "Expected availability"
            setTextColor(Color.parseColor("#E65100"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 12f)
            typeface = Typeface.create("sans-serif", Typeface.NORMAL)
            gravity = Gravity.CENTER
            val params = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
            params.bottomMargin = dpToPx(4)
            layoutParams = params
        }

        val etaTime = TextView(this).apply {
            text = "Approximately $randomWait"
            setTextColor(Color.parseColor("#BF360C"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 16f)
            typeface = Typeface.create("sans-serif-medium", Typeface.BOLD)
            gravity = Gravity.CENTER
        }

        etaCard.addView(etaIcon)
        etaCard.addView(etaLabel)
        etaCard.addView(etaTime)

        // Error code (makes it look legit)
        val errorCode = "ERR_${Random.nextInt(100, 999)}_SRV_${Random.nextInt(10, 99)}"
        val errorCodeText = TextView(this).apply {
            text = "Error: $errorCode"
            setTextColor(Color.parseColor("#BDBDBD"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 11f)
            typeface = Typeface.create("monospace", Typeface.NORMAL)
            gravity = Gravity.CENTER
            val params = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
            params.bottomMargin = dpToPx(24)
            layoutParams = params
        }

        // "Try Again" button (that just sends you home lol)
        val tryAgainButton = TextView(this).apply {
            text = "Try Again Later"
            setTextColor(Color.WHITE)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 16f)
            typeface = Typeface.create("sans-serif-medium", Typeface.BOLD)
            gravity = Gravity.CENTER
            setPadding(dpToPx(48), dpToPx(14), dpToPx(48), dpToPx(14))

            val buttonBg = GradientDrawable().apply {
                shape = GradientDrawable.RECTANGLE
                cornerRadius = dpToPx(28).toFloat()
                setColor(Color.parseColor("#1565C0"))
            }
            background = buttonBg

            val params = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
            params.bottomMargin = dpToPx(12)
            layoutParams = params

            setOnClickListener {
                goHome()
            }
        }

        // "Contact Support" text link (also just goes home)
        val contactSupport = TextView(this).apply {
            text = "Contact Support"
            setTextColor(Color.parseColor("#1565C0"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
            gravity = Gravity.CENTER
            setPadding(0, dpToPx(8), 0, dpToPx(8))

            setOnClickListener {
                goHome()
            }
        }

        // Add all views
        rootLayout.addView(iconView)
        rootLayout.addView(warningIcon)
        rootLayout.addView(titleText)
        rootLayout.addView(messageText)
        rootLayout.addView(divider)
        rootLayout.addView(etaCard)
        rootLayout.addView(errorCodeText)
        rootLayout.addView(tryAgainButton)
        rootLayout.addView(contactSupport)

        setContentView(rootLayout)

        // Entry animation
        rootLayout.alpha = 0f
        rootLayout.translationY = 30f
        rootLayout.animate()
            .alpha(1f)
            .translationY(0f)
            .setDuration(350)
            .setInterpolator(AccelerateDecelerateInterpolator())
            .start()
    }

    private fun goHome() {
        val homeIntent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        startActivity(homeIntent)
        finish()
    }

    override fun onBackPressed() {
        // Back button also goes home — can't get back to blocked app
        goHome()
    }

    private fun dpToPx(dp: Int): Int {
        return TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP,
            dp.toFloat(),
            resources.displayMetrics
        ).toInt()
    }
}
