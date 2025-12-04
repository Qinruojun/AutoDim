//request()方法返回会权限的新状态：isGranted,isDinied，isPermanentlyDenied等
//请求用户权限的界面
import 'dart:async';
import 'dart:io';
import '../checkAutoStart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:autostart_settings/autostart_settings.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:auto_start_permission/auto_start_permission.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class Permissionpage extends StatefulWidget {
  const Permissionpage({super.key});
  static const platform = MethodChannel('auto_dim_channel');
  @override
  State<Permissionpage> createState() => _PermissionpageState();
}

class _PermissionpageState extends State<Permissionpage>
    with WidgetsBindingObserver {
  String? _currentPermType = null;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  // 颜色常量：黑色背景 + 绿色文字
  static const Color _bgColor = Colors.black;
  static const Color _primaryGreen = Color(0xFF00E676); // 亮绿色
  static const Color _dialogBg = Color(0xFF101010);
  //定义声明权限需要原因的文本
  static const writeSettingExpl = "AutoDim需要获取系统写入权限，用于获取用户的屏幕使用时长信息以及进行屏幕亮度调试";
  static const iBatteryOpExpl = "AutoDim需要获取忽略电池优化权限，以维持App的后台运行";
  static const autoStartExpl = "AutoDim需要开机自启以实现屏幕使用时间的统计与干预";
  static const sysAlertWinExpl = "AutoDim需要悬浮窗权限来实现文案提示";
  static const permWrite = "write";
  static const permBattery = "battery";
  static const permAutostart = "autostart";
  static const permSysAlerWin = "systemalertwindow";
  static const wSCheckMeth = "checkWriteSettings";
  static const iBCheckMeth = "checkIgnoringBatteryOptimizations";
  static const sysAleWinMeth = "checkSystemAlertWindow";
  final cAutoStart = Completer<void>();
  final cWriteSetting = Completer<void>();
  final cIgBattery = Completer<void>();
  final cSAWindow = Completer<void>();

  bool _dialogShowing = false;

  Future<void> requestPermissions() async {
    // Android 13+, you need to allow notification permission to display foreground service notification.
    //
    // iOS: If you need notification, ask for permission.
    final NotificationPermission notificationPermission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }

    if (Platform.isAndroid) {
      // Android 12+, there are restrictions on starting a foreground service.
      //
      // To restart the service on device reboot or unexpected problem, you need to allow below permission.
      if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
        // This function requires `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission.
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }

      // Use this utility only if you provide services that require long-term survival,
      // such as exact alarm service, healthcare service, or Bluetooth communication.
      //
      // This utility requires the "android.permission.SCHEDULE_EXACT_ALARM" permission.
      // Using this permission may make app distribution difficult due to Google policy.
      if (!await FlutterForegroundTask.canScheduleExactAlarms) {
        // When you call this function, will be gone to the settings page.
        // So you need to explain to the user why set it.
        await FlutterForegroundTask.openAlarmsAndRemindersSettings();
      }
    }
  }

  //当前正在访问的权限
  // void ShowPermissionDialog(onPressedFuncton, String Explanation) {
  //   //if(_dialogShowing)return;//如果当前有弹窗就不打开弹窗

  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (_) => AlertDialog(
  //       title: const Text("AutoDim", style: TextStyle()),
  //       content: Text(Explanation),
  //       actions: [
  //         TextButton(
  //           onPressed: () async {
  //             await onPressedFuncton();
  //           },
  //           child: const Text("去设置"),
  //         ),
  //         TextButton(
  //           onPressed: () => SystemNavigator.pop(),
  //           child: const Text("拒绝"),
  //         ),
  //       ],
  //     ),
  //   );
  //   _dialogShowing = true;
  // }
  /// 弹出权限说明弹窗：黑色背景 + 绿色文字 + 绿色边框
  void ShowPermissionDialog(onPressedFuncton, String explanation) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (_) => AlertDialog(
        backgroundColor: _dialogBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _primaryGreen, width: 1.6),
        ),
        titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
        actionsPadding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        title: Row(
          children: [
            const Icon(
              Icons.lock_outline_rounded,
              size: 24,
              color: _primaryGreen,
            ),
            const SizedBox(width: 8),
            Text(
              "AutoDim 权限",
              style: const TextStyle(
                color: _primaryGreen,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          explanation,
          style: const TextStyle(
            color: _primaryGreen,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actionsAlignment: MainAxisAlignment.end,
        actions: [
          TextButton(
            onPressed: () async {
              await onPressedFuncton();
            },
            child: const Text("去设置"),
          ),
          TextButton(
            onPressed: () {
              _dialogShowing = false;
              SystemNavigator.pop();
            },
            child: const Text("拒绝"),
          ),
        ],
      ),
    );

    _dialogShowing = true;
  }

  Future<void> _open(String methodName) async {
    try {
      await Permissionpage.platform.invokeMethod(methodName);
    } on PlatformException catch (e) {
      debugPrint("Error:${e.message}");
    }
  }

  Future<bool> _check(String methodName) async {
    try {
      final result = await Permissionpage.platform.invokeMethod(methodName);
      return result == true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _checkPermissions() async {
    if (await _check(wSCheckMeth) &&
        await _check(iBCheckMeth) &&
        await checkAutoStart() &&
        await _check(sysAleWinMeth)) {
      if (mounted) {
        Navigator.popAndPushNamed(context, '/home');
      }
    } else {
      if (!await _check(wSCheckMeth)) {
        ShowPermissionDialog(
          () => _open("openWriteSettings"),
          writeSettingExpl,
        );
        _currentPermType = permWrite;

        await Future.wait([cWriteSetting.future]); //函数会暂定在这里直到接到complete信号
        if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      } else {
        cWriteSetting.complete();
      }
      if (!await _check(iBCheckMeth)) {
        ShowPermissionDialog(
          //() => _open("openIgnoreBatteryOptimizations"),
          requestPermissions,
          iBatteryOpExpl,
        );
        _currentPermType = permBattery;
        await Future.wait([cIgBattery.future]);
        if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      } else {
        cIgBattery.complete();
      }
      if (!await checkAutoStart()) {
        ShowPermissionDialog(openAutoStart, autoStartExpl);
        _currentPermType = permAutostart;
        await Future.wait([cAutoStart.future]);
        if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      } else {
        cAutoStart.complete();
      }
      if (!await _check(sysAleWinMeth)) {
        debugPrint("程序执行到这里");
        ShowPermissionDialog(
          () => _open("openSystemAlertWindow"),
          sysAlertWinExpl,
        );
        _currentPermType = permSysAlerWin;
        await Future.wait([cSAWindow.future]);
        if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      } else {
        cSAWindow.complete();
      }
      await Future.wait([
        cAutoStart.future,
        cIgBattery.future,
        cWriteSetting.future,
        cSAWindow.future,
      ]);
      //所有权限都被授权完成，返回homePage
      if (mounted) {
        Navigator.popAndPushNamed(context, '/home');
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  //当用户从后台返回app后会被自动触发
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state != AppLifecycleState.resumed) return;
    if (!_dialogShowing) return; //当前没有弹窗
    switch (_currentPermType) {
      case permWrite:
        if (await _check(wSCheckMeth)) {
          //授权成功
          cWriteSetting.complete(); //发送信号
          //弹出弹窗
        }
        break;
      case permBattery:
        if (await _check(iBCheckMeth)) {
          //授权成功
          cIgBattery.complete(); //发送信号
        }
        break;

      case permAutostart:
        if (await checkAutoStart()) {
          cAutoStart.complete();
        }
        break;
      case permSysAlerWin:
        if (await _check(sysAleWinMeth)) {
          cSAWindow.complete();
        }
        break;
    }
  }

  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: Column(
  //       children: [
  //         SizedBox(height: 70),
  //         Center(
  //           child: Text(
  //             "AutoDim",
  //             style: TextStyle(color: Colors.grey, fontSize: 30),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  @override
  Widget build(BuildContext context) {
    // 只在这个页面覆盖一层深色 + 绿色主题
    final baseTheme = Theme.of(context);

    final pageTheme = baseTheme.copyWith(
      scaffoldBackgroundColor: _bgColor,
      dialogBackgroundColor: _dialogBg,
      textTheme: baseTheme.textTheme.apply(
        bodyColor: _primaryGreen,
        displayColor: _primaryGreen,
      ),
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: _primaryGreen,
        secondary: _primaryGreen,
        surface: _dialogBg,
        onSurface: _primaryGreen,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: _primaryGreen),
      ),
    );

    return Theme(
      data: pageTheme,
      child: Scaffold(
        backgroundColor: _bgColor,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 72,
                  color: _primaryGreen,
                ),
                const SizedBox(height: 24),
                Text(
                  "AutoDim",
                  style: const TextStyle(
                    color: _primaryGreen,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "正在检查所需权限…",
                  style: TextStyle(
                    color: _primaryGreen.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),
                CircularProgressIndicator(
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    _primaryGreen,
                  ),
                  strokeWidth: 2,
                  backgroundColor: Colors.white12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
