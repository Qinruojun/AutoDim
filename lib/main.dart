import 'dart:io';
import 'package:auto_dim_2/Page/permissionPage.dart';
import 'package:auto_dim_2/themeData.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'BrightnessUI.dart';
import 'TaskHandler.dart';

void main() {
  // 初始化前台服务配置
  FlutterForegroundTask.initCommunicationPort();
  runApp(MyApp());
}

// 这里的 callback 必须是顶层函数或静态函数
// @pragma('vm:entry-point')
// void startCallback() {
//   FlutterForegroundTask.setTaskHandler(BrightnessTaskHandler());
// }

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //void _initService() {
  //   FlutterForegroundTask.init(
  //     androidNotificationOptions: AndroidNotificationOptions(
  //       channelId: 'foreground_service',
  //       channelName: 'Foreground Service Notification',
  //       channelDescription:
  //           'This notification appears when the foreground service is running.',
  //       onlyAlertOnce: true,
  //     ),
  //     iosNotificationOptions: const IOSNotificationOptions(
  //       showNotification: false,
  //       playSound: false,
  //     ),
  //     foregroundTaskOptions: ForegroundTaskOptions(
  //       eventAction: ForegroundTaskEventAction.repeat(5000),
  //       autoRunOnBoot: true, //开机自启
  //       autoRunOnMyPackageReplaced: true,
  //       allowWakeLock: true,
  //       allowWifiLock: true,
  //     ),
  //   );
  // }

  // Future<ServiceRequestResult> _startService() async {
  //   if (await FlutterForegroundTask.isRunningService) {
  //     return FlutterForegroundTask.restartService();
  //   } else {
  //     return FlutterForegroundTask.startService(
  //       // You can manually specify the foregroundServiceType for the service
  //       // to be started, as shown in the comment below.
  //       serviceTypes: [ForegroundServiceTypes.dataSync],
  //       serviceId: 256,
  //       notificationTitle: '亮度服务已随开机启动',
  //       notificationText: 'Tap to return to the app',
  //       notificationIcon: null,
  //       notificationButtons: [
  //         const NotificationButton(id: 'btn_hello', text: 'hello'),
  //       ],
  //       notificationInitialRoute:
  //           '/home', //当用户点击通知时，插件会拉起App,这个参数是拉起App时Flutter要打开的初始路由
  //       callback: startCallback,
  //     );
  //   }
  // }

  // Future<ServiceRequestResult> _stopService() {
  //   return FlutterForegroundTask.stopService();
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   // Add a callback to receive data sent from the TaskHandler.
  //   // FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);

  //   WidgetsBinding.instance.addPostFrameCallback((_) async {
  //     // Request permissions and initialize the service.
  //     _initService();
  //     await _startService();
  //   });
  // }

  // @override
  // void dispose() {
  //   // Remove a callback to receive data sent from the TaskHandler.
  //   //FlutterForegroundTask.removeTaskDataCallback(_onReceiveTaskData);
  //   //_taskDataListenable.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: darkTheme,
      routes: {
        '/home': (context) => const Bubble(),
        '/permission': (context) => const Permissionpage(),
      },
      initialRoute: '/permission',
    );
  }
}
