package com.example.auto_dim_2


import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.net.Uri
import android.provider.Settings
import android.content.Context
import android.content.ComponentName
import android.os.Build
import android.util.Log
import android.os.PowerManager
import android.content.BroadcastReceiver
import android.content.IntentFilter
import io.flutter.plugin.common.EventChannel
import android.view.WindowManager
import android.view.WindowManager.LayoutParams
import android.graphics.PixelFormat
import android.view.View

//只要进程不被杀死，广播都可以一直运行
class MainActivity : FlutterActivity() {

   //权限获取的MethodChannel
            private val CHANNEL = "auto_dim_channel"
           
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
   
   
    

        //权限获取的handler实现
       //MethodChannel必须放在configureFlutterEngine的内部，才能够获取flutterEngine
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                   
                //WRITE_SETTINGS 权限
                "openWriteSettings" -> {
                    val intent = Intent(Settings.ACTION_MANAGE_WRITE_SETTINGS)
                    intent.data = Uri.parse("package:$packageName")
                    startActivity(intent)
                    result.success(true)
                }

                "checkWriteSettings" -> {
                    val granted = Settings.System.canWrite(this)
                    result.success(granted)
                } 
              "openSystemAlertWindow" -> {
                print("尝试打开浮窗权限设置")
               val intent = Intent("android.settings.action.MANAGE_OVERLAY_PERMISSION")
               intent.data = Uri.parse("package:$packageName")
               activity?.startActivity(intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))


                result.success(true)
}
                "checkSystemAlertWindow"->{
                    val permission=Settings.canDrawOverlays(this)&&testOverlayPermission(this)
                    result.success(permission)
                }
              
                //忽略电池优化
                "openIgnoreBatteryOptimizations" -> {
                    openIgnoreBatteryOptimizations()
                    result.success(null)
                }

                "checkIgnoringBatteryOptimizations" -> {
                    val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
                    val isIgnoring = pm.isIgnoringBatteryOptimizations(applicationContext.packageName)
                    result.success(isIgnoring)
                }

                //开机自启设置
                "openAutoStartSettings" -> {
                    openAutoStartSettings()
                    result.success(true)
                }
                //获取厂商名称
                "getManufacturer" -> {
                    result.success(Build.MANUFACTURER)
                }

                else -> result.notImplemented()
            }
        }
    }

    /** 忽略电池优化 **/
    private fun openIgnoreBatteryOptimizations() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
            val pkg = applicationContext.packageName
            val intent = Intent().apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
                if (!pm.isIgnoringBatteryOptimizations(pkg)) {
                    action = Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS
                    data = Uri.parse("package:$pkg")
                } else {
                    action = Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS
                }
            }
            startActivity(intent)
        }
    }
  /*使用小浮窗测试是否获得了SYSTEM_ALERT_WINDOW权限 */
  fun testOverlayPermission(context: Context): Boolean {
    return try {
        val wm = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val params = WindowManager.LayoutParams(
            1,
            1,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                WindowManager.LayoutParams.TYPE_SYSTEM_ALERT,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSPARENT
        )
        val view = View(context)
        wm.addView(view, params)
        wm.removeView(view)
        true
    } catch (e: Exception) {
        false
    }
}





    /** 开机自启设置 **///旧版本，发现在oppo手机的测试上出现问题
   /*fun openAutoStartSettings() {
    val manufacturer = Build.MANUFACTURER.lowercase()

        try {
            val intent = Intent().apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
                when {
                    manufacturer.contains("xiaomi") ->
                        component = ComponentName("com.miui.securitycenter", "com.miui.permcenter.autostart.AutoStartManagementActivity")
                    manufacturer.contains("oppo") ->
                        component = ComponentName("com.coloros.safecenter", "com.coloros.safecenter.permission.startup.StartupAppListActivity")
                    manufacturer.contains("vivo") ->
                        component = ComponentName("com.vivo.permissionmanager", "com.vivo.permissionmanager.activity.BgStartUpManagerActivity")
                    manufacturer.contains("huawei") ->
                        component = ComponentName("com.huawei.systemmanager", "com.huawei.systemmanager.optimize.process.ProtectActivity")
                    else -> {
                        action = Settings.ACTION_APPLICATION_DETAILS_SETTINGS
                        data = Uri.parse("package:$packageName")
                    }
                }
            }

            startActivity(intent)

        } catch (e: Exception) {
            val fallbackIntent = Intent().apply {
                action = Settings.ACTION_APPLICATION_DETAILS_SETTINGS
                data = Uri.parse("package:$packageName")
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            startActivity(fallbackIntent)
        }
    }*/
        private fun openAutoStartSettings() {
        val manufacturer = Build.MANUFACTURER.lowercase()
        val intentList = mutableListOf<Intent>()

        when {
            manufacturer.contains("xiaomi") || manufacturer.contains("redmi") -> {
                intentList += Intent().apply {
                    component = ComponentName(
                        "com.miui.securitycenter",
                        "com.miui.permcenter.autostart.AutoStartManagementActivity"
                    )
                }
            }
            manufacturer.contains("huawei") || manufacturer.contains("honor") -> {
                intentList += Intent().apply {
                    component = ComponentName(
                        "com.huawei.systemmanager",
                        "com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity"
                    )
                }
            }
            manufacturer.contains("oppo") -> {
                intentList += Intent().apply {
                    component = ComponentName(
                        "com.coloros.safecenter",
                        "com.coloros.safecenter.startupapp.StartupAppListActivity"
                    )
                }
                intentList += Intent().apply {
                    component = ComponentName(
                        "com.coloros.safecenter",
                        "com.coloros.safecenter.permission.startup.StartupAppListActivity"
                    )
                }
            }
            manufacturer.contains("vivo") -> {
                intentList += Intent().apply {
                    component = ComponentName(
                        "com.iqoo.secure",
                        "com.iqoo.secure.ui.phoneoptimize.AddWhiteListActivity"
                    )
                }
            }
            manufacturer.contains("meizu") -> {
                intentList += Intent().apply {
                    component = ComponentName(
                        "com.meizu.safe",
                        "com.meizu.safe.permission.SmartBGActivity"
                    )
                }
            }
            // 其他厂商暂时不指定，直接走兜底
        }

        // 兜底：应用详情和电池优化设置
        intentList += Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
            data = Uri.parse("package:$packageName")
        }
        intentList += Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)

        for (intent in intentList) {
            try {
                if (intent.resolveActivity(packageManager) != null) {
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(intent)
                    return
                }
            } catch (_: Exception) {
            }
        }
}