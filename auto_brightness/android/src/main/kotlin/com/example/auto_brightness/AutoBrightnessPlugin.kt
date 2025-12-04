package com.example.auto_brightness


import android.content.Context
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.provider.Settings
import android.util.Log
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.TextView
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class AutoBrightnessPlugin : FlutterPlugin, MethodCallHandler {

    private lateinit var channel: MethodChannel
    private lateinit var appContext: Context

    private var windowManager: WindowManager? = null
    private var overlayView: FrameLayout? = null

    // TextView 的 id，用来 update 文本
    private val overlayTextViewId: Int = View.generateViewId()

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        appContext = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "auto_brightness")
        channel.setMethodCallHandler(this)

        windowManager = appContext.getSystemService(Context.WINDOW_SERVICE) as WindowManager
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        hideUsageOverlay()
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getCurrentBrightness" -> {
                val value = getCurrentBrightness()
                result.success(value) // Double
            }
            "setSystemBrightness" -> {
                val value = call.argument<Int>("value") ?: 0
                setSystemBrightness(value)
                result.success(null)
            }
            "showOverlay" -> {
                val minutes = call.argument<Int>("minutes") ?: 0
                showUsageOverlay(minutes)
                result.success(null)
            }
            "hideOverlay" -> {
                hideUsageOverlay()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    // 读取系统亮度 (0~255)
    private fun getCurrentBrightness(): Double {
        return try {
            Settings.System.getFloat(
                appContext.contentResolver,
                Settings.System.SCREEN_BRIGHTNESS
            ).toDouble()
        } catch (e: Exception) {
            Log.e("Brightness", "无法获取屏幕亮度", e)
            100.0
        }
    }

    // 设置系统亮度
    private fun setSystemBrightness(value: Int) {
        Log.d("Brightness", "开始设置亮度: $value")

        try {
            // 关闭自动亮度
            Settings.System.putInt(
                appContext.contentResolver,
                Settings.System.SCREEN_BRIGHTNESS_MODE,
                Settings.System.SCREEN_BRIGHTNESS_MODE_MANUAL
            )

            Settings.System.putInt(
                appContext.contentResolver,
                Settings.System.SCREEN_BRIGHTNESS,
                value.coerceIn(0, 255)
            )
        } catch (e: Exception) {
            Log.e("Brightness", "设置亮度失败", e)
        }
    }

    // 显示覆盖层（整屏黑 + 中间卡片）
    private fun showUsageOverlay(minutes: Int) {
        if (!Settings.canDrawOverlays(appContext)) {
            Log.w("Overlay", "没有悬浮窗权限，无法显示提示")
            return
        }

        val wm = windowManager
            ?: (appContext.getSystemService(Context.WINDOW_SERVICE) as WindowManager).also {
                windowManager = it
            }

        // 已经有 overlay 了，更新文字即可
        overlayView?.let {
            updateOverlayText(minutes)
            return
        }

        // 整屏容器
        val root = FrameLayout(appContext).apply {
            setBackgroundColor(Color.parseColor("#FF111111"))
            isClickable = true
            isFocusable = true
        }

        // 中间的卡片
        val card = FrameLayout(appContext).apply {
            layoutParams = FrameLayout.LayoutParams(
                dp(220),
                dp(140)
            ).apply {
                gravity = Gravity.CENTER
            }

            background = GradientDrawable().apply {
                cornerRadius = dp(16).toFloat()
                setColor(Color.parseColor("#FF181818"))
                setStroke(1, Color.parseColor("#FF202020"))
            }
        }

        // 文本
        val textView = TextView(appContext).apply {
            id = overlayTextViewId
            text = "你已玩了${minutes}分钟手机"
            setTextColor(Color.parseColor("#FF33FF66"))
            textSize = 24f
            gravity = Gravity.CENTER
        }

        card.addView(
            textView,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
        )

        root.addView(card)

        // 点击任意位置关闭
        root.setOnClickListener {
            hideUsageOverlay()
        }

        val windowType =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                WindowManager.LayoutParams.TYPE_PHONE

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            windowType,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                    WindowManager.LayoutParams.FLAG_FULLSCREEN,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
        }

        wm.addView(root, params)
        overlayView = root
    }

    // 更新 overlay 上的文字
    private fun updateOverlayText(minutes: Int) {
        val overlay = overlayView ?: return
        val tv = overlay.findViewById<TextView>(overlayTextViewId)
        tv?.text = "你已玩了${minutes}分钟手机"
    }

    // 隐藏 overlay
    private fun hideUsageOverlay() {
        val wm = windowManager ?: return
        val overlay = overlayView ?: return

        try {
            wm.removeView(overlay)
        } catch (e: Exception) {
            Log.e("Overlay", "移除 overlay 出错", e)
        } finally {
            overlayView = null
        }
    }

    private fun dp(value: Int): Int =
        (value * appContext.resources.displayMetrics.density).toInt()
}
