import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'auto_brightness_platform_interface.dart';

/// An implementation of [AutoBrightnessPlatform] that uses method channels.
class MethodChannelAutoBrightness extends AutoBrightnessPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('auto_brightness');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
