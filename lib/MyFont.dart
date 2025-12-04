import 'package:flutter/material.dart';

//复制json和ttf文件到fonts中，json是为了方便查看unicode码，ttf才是素材
class MyFont {
  //因为希望可以直接通过类来调用
  static const IconData Wechat = IconData(
    0xf0106, //找到从阿里巴巴下载的图表库的json文件的Unicode，前面加上个0x表示十六进制
    fontFamily: "MyIcon", //在pubspec.yaml中自定义的font family,要加双引号：String
    matchTextDirection: true,
  );
  static const IconData CD = IconData(
    0xe670,
    fontFamily: 'MyIcon',
    matchTextDirection: true,
  );
  static const IconData Data = IconData(
    0xe50f,
    fontFamily: 'MyIcon',
    matchTextDirection: true,
  );
  static const IconData LogIn = IconData(
    0x10219,
    fontFamily: 'MyIcon',

    matchTextDirection: true,
  );
  static const IconData User = IconData(
    0xe620,
    fontFamily: 'MyIcon',
    matchTextDirection: true,
  );
  static const IconData Light_1 = IconData(
    0xe683,
    fontFamily: 'MyIcon',
    matchTextDirection: true,
  );
  static const IconData Light_2 = IconData(
    0xe507,
    fontFamily: 'MyIcon',
    matchTextDirection: true,
  );
  static const IconData Menu = IconData(
    0xe609,
    fontFamily: 'MyIcon',
    matchTextDirection: true,
  );
}
