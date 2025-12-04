import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'auto_brightness_method_channel.dart';

abstract class AutoBrightnessPlatform extends PlatformInterface {
  /// Constructs a AutoBrightnessPlatform.
  AutoBrightnessPlatform() : super(token: _token);

  static final Object _token = Object();

  static AutoBrightnessPlatform _instance = MethodChannelAutoBrightness();

  /// The default instance of [AutoBrightnessPlatform] to use.
  ///
  /// Defaults to [MethodChannelAutoBrightness].
  static AutoBrightnessPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AutoBrightnessPlatform] when
  /// they register themselves.
  static set instance(AutoBrightnessPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
