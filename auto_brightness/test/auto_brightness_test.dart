import 'package:flutter_test/flutter_test.dart';
import 'package:auto_brightness/auto_brightness.dart';
import 'package:auto_brightness/auto_brightness_platform_interface.dart';
import 'package:auto_brightness/auto_brightness_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAutoBrightnessPlatform
    with MockPlatformInterfaceMixin
    implements AutoBrightnessPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final AutoBrightnessPlatform initialPlatform = AutoBrightnessPlatform.instance;

  test('$MethodChannelAutoBrightness is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAutoBrightness>());
  });

  test('getPlatformVersion', () async {
    AutoBrightness autoBrightnessPlugin = AutoBrightness();
    MockAutoBrightnessPlatform fakePlatform = MockAutoBrightnessPlatform();
    AutoBrightnessPlatform.instance = fakePlatform;

    expect(await autoBrightnessPlugin.getPlatformVersion(), '42');
  });
}
