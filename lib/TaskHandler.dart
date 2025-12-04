import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BrightnessTaskHandler extends TaskHandler {
  static const _channel = MethodChannel("auto_brightness"); //插件的methodChannel
  static const _prefsKey = 'center_number';

  int _minBrightness = 0; //设置最小亮度

  int _limitTimeMin = 3; //屏幕变暗的时间
  int _steps = 36;
  bool _showOverlay = false; //设定只展示一次文案
  int _currentStep = 0;
  int _interval = 5000; //5s
  double decrement = 0; //已经减少了的亮度
  //每隔interval 毫秒被调用一次（在ForegroundTaskOptions里面配置）
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    final v = await FlutterForegroundTask.getData(key: 'limitTimeMin');
    _limitTimeMin = (v as int?) ?? 3;
    _steps = (_limitTimeMin * 60000 / _interval).toInt();
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {}
  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {
    if (_currentStep >= _steps) {
      //确保是经过调暗之后再显示
      if (!_showOverlay) {
        await _channel.invokeMethod("showOverlay", {"minutes": _limitTimeMin});
        _showOverlay = true;
      }
      //如果要多次执行调暗就要将_currentStep清零
      _currentStep = 0;
      _showOverlay = false; //_showOverlay是不必要的如果要反复执行调暗逻辑，将_currentStep清零即可
      return;
    } else {
      await performTask(); //一定要记住异步
      _currentStep++;
    }
  }

  Future<void> performTask() async {
    var brightness = await _channel.invokeMethod("getCurrentBrightness");
    print("当前的亮度为$brightness");
    if (brightness != null && _steps - _currentStep != 0) {
      if (_currentStep != _steps - 1) {
        var progress = brightness / (_steps - _currentStep);

        var newBrightness = brightness - progress - decrement;
        if (newBrightness.ceil() == brightness) {
          decrement += progress;
          return;
        } else {
          decrement = 0;
          print("要设置的亮度为$newBrightness");
          await _channel.invokeMethod("setSystemBrightness", {
            "value": newBrightness.ceil(),
          });
        }
      } else {
        //最后一步直接将亮度设为0
        await _channel.invokeMethod("setSystemBrightness", {"value": 0});
      }
    }
  }

  @override
  void onReceiveData(Object data) async {
    if (data is Map) {
      final type = data['type'];
      if (type == 'updateLimitTime') {
        final value = data['limitTime'];
        if (value is int && value > 0) {
          var diff = value - _limitTimeMin;
          _limitTimeMin = value; //更新_limitTimeMin
          _steps += (diff * 60000 / _interval).toInt();
          //修改_steps
          await FlutterForegroundTask.saveData(
            key: 'limitTimeMin',
            value: value,
          );
        }
      }
    }
  }
}
