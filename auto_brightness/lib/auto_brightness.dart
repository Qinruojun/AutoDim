
import 'auto_brightness_platform_interface.dart';

class AutoBrightness {
  Future<String?> getPlatformVersion() {
    return AutoBrightnessPlatform.instance.getPlatformVersion();
  }
}
