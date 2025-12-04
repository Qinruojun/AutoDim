//一个用来调控dart的小控件
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'TaskHandler.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(BrightnessTaskHandler());
}

class Bubble extends StatefulWidget {
  const Bubble({super.key});

  @override
  State<Bubble> createState() => _BubbleState();
}

class _BubbleState extends State<Bubble> {
  static const _prefsKey = 'center_number';

  int _limitTime = 3; // 默认值
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  //加载存储好的值
  Future<void> _loadNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt(_prefsKey);
    if (value != null) {
      setState(() {
        _limitTime = value;
        _controller.text = value.toString();
      });
    }
  }

  void _initService() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'foreground_service',
        channelName: 'Foreground Service Notification',
        channelDescription:
            'This notification appears when the foreground service is running.',
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(5000),
        autoRunOnBoot: true, //开机自启
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  Future<ServiceRequestResult> _startService() async {
    if (await FlutterForegroundTask.isRunningService) {
      return FlutterForegroundTask.restartService();
    } else {
      return FlutterForegroundTask.startService(
        // You can manually specify the foregroundServiceType for the service
        // to be started, as shown in the comment below.
        serviceTypes: [ForegroundServiceTypes.dataSync],
        serviceId: 256,
        notificationTitle: '亮度服务已随开机启动',
        notificationText: 'Tap to return to the app',
        notificationIcon: null,
        notificationButtons: [
          const NotificationButton(id: 'btn_hello', text: 'hello'),
        ],
        notificationInitialRoute:
            '/home', //当用户点击通知时，插件会拉起App,这个参数是拉起App时Flutter要打开的初始路由
        callback: startCallback,
      );
    }
  }

  Future<ServiceRequestResult> _stopService() {
    return FlutterForegroundTask.stopService();
  }

  @override
  void initState() {
    super.initState();
    // Add a callback to receive data sent from the TaskHandler.
    // FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);
    _controller = TextEditingController(text: _limitTime.toString());
    _loadNumber();
    //逻辑稍微有点不合理，应该先loadNumber发现为空再使用默认值然后对_controller的Text进行初始化，后面可以进行修正
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Request permissions and initialize the service.
      _initService();
      await _startService();
    });
  }

  @override
  void dispose() {
    // Remove a callback to receive data sent from the TaskHandler.
    //FlutterForegroundTask.removeTaskDataCallback(_onReceiveTaskData);
    //_taskDataListenable.dispose();
    super.dispose();
    _controller.dispose();
    _focusNode.dispose();
  }

  // @override
  // void initState() {
  //   super.initState();
  // _controller = TextEditingController(text: _limitTime.toString());
  // _loadNumber();
  // }

  Future<void> _saveNumber(int value) async {
    _limitTime = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsKey, value);
    // 再用前台任务自己的存储保存一份
    await FlutterForegroundTask.saveData(key: 'limitTimeMin', value: value);
  }

  // @override
  // void dispose() {
  //   _controller.dispose();
  //   _focusNode.dispose();
  //   super.dispose();
  // }

  Future<void> updateLimitTime(int limitTime) async {
    FlutterForegroundTask.sendDataToTask({
      'type': 'updateLimitTime',
      'limitTime': limitTime,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Center(
        child: Container(
          width: 180,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 60,
              fontWeight: FontWeight.w500,
              color: Colors.greenAccent,
            ),
            cursorColor: Colors.greenAccent,
            decoration: const InputDecoration(
              border: InputBorder.none,
              counterText: '', // 不显示长度计数
              isCollapsed: true, // 去掉默认内边距
            ),
            // 用户点键盘上的“完成/Enter”时触发保存
            onSubmitted: (text) async {
              final v = int.tryParse(text);
              if (v != null) {
                await _saveNumber(v);
                await updateLimitTime(v);
              } else {
                // 非法输入时恢复上一次合法值
                _controller.text = _limitTime.toString();
              }
            },
          ),
        ),
      ),
    );
  }
}
