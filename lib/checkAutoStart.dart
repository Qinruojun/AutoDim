import 'dart:io';
import 'dart:math';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:autostart_settings/autostart_settings.dart'; //打开开机自启权限的包
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:auto_start_permission/auto_start_permission.dart'; //检查是否有开机自启权限的包

//尝试使用autostart_settings包来实现获取开机自启权限
const platform = MethodChannel('auto_dim_channel');
Future<bool> checkAutoStart() async {
  AutoStartPermissionState state = await AutoStartPermission.instance
      .checkAutoStartState();
  if (state == AutoStartPermissionState.enabled) {
    return true;
  } else if (state == AutoStartPermissionState.disabled) {
    return false;
  } else {
    throw Exception("无法检测App是否获得了开机自启权限");
  }
}

Future<void> openAutoStart() async {
  if (!await openByPackage()) {
    await openByMethodChannel();
  }
}

//通过MethodChannel调用host Platform API打开设置
Future<bool> openByMethodChannel() async {
  try {
    await platform.invokeMethod('openAutoStartSettings');
    return true;
  } on PlatformException catch (e) {
    debugPrint('Error: ${e.message}');
    return false;
  }
}

//通过autostart_settigs打开
Future<bool> openByPackage() async {
  try {
    final canopen = await AutostartSettings.canOpen(
      autoStart: true,
      batterySafer: true,
    );
    // AutoStarPermission的枚举值enabled, disabled, noInfo,unexpectedResult

    if (canopen) {
      try {
        await AutostartSettings.open(autoStart: true, batterySafer: true);
        return true;
      } catch (openError) {
        debugPrint('打开设置页面失败: $openError');
        // 可以在这里显示错误提示给用户
        // 例如：showDialog() 或 SnackBar
        return false;
      }
    } else {
      debugPrint('设备不支持自启动设置');
      // 处理不支持的情况
      return false;
    }
  } catch (e) {
    debugPrint('检查自启动设置状态失败: $e');
    // 处理整体流程错误
    return false;
  }
}
