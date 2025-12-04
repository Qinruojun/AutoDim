import 'package:flutter/material.dart';

/// 全局主色：绿色
const Color? TextColor = Color.fromARGB(255, 40, 194, 120);

// 定义整个 App 的深色绿色主题
final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,

  /// 颜色体系：以 TextColor 为主色，黑色为背景
  colorScheme: ColorScheme.fromSeed(
    seedColor: TextColor ?? Color.fromARGB(255, 40, 194, 120),
    brightness: Brightness.dark,
    background: Colors.black,
    primary: TextColor ?? Colors.greenAccent,
    secondary: TextColor ?? Colors.greenAccent,
  ),

  /// 整个 App 的背景色
  scaffoldBackgroundColor: Colors.black,

  /// 全局字体：默认文字都是绿色
  textTheme: TextTheme(
    bodySmall: TextStyle(color: TextColor),
    bodyMedium: TextStyle(color: TextColor),
    bodyLarge: TextStyle(color: TextColor),
    titleMedium: TextStyle(color: TextColor, fontWeight: FontWeight.w500),
    titleLarge: TextStyle(
      color: TextColor,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),

  /// AppBar：黑底 + 绿色标题/图标
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.black,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 20,
      color: TextColor,
      fontWeight: FontWeight.w600,
    ),
    iconTheme: IconThemeData(color: TextColor),
  ),

  /// TextButton：文字绿色
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: TextColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      textStyle: const TextStyle(fontSize: 14),
    ),
  ),

  /// ElevatedButton：绿色实心按钮 + 黑色文字
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: TextColor,
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      elevation: 0,
    ),
  ),

  /// OutlinedButton：绿色描边 + 绿色文字
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: TextColor,
      side: BorderSide(color: TextColor ?? Colors.greenAccent),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  ),

  /// FloatingActionButton：绿色圆形按钮
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: TextColor,
    foregroundColor: Colors.black,
    elevation: 4,
  ),

  /// 卡片：深灰背景 + 绿色淡描边
  cardTheme: CardThemeData(
    color: const Color(0xFF101010),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(
        color: (TextColor ?? Colors.greenAccent).withOpacity(0.4),
      ),
    ),
    margin: const EdgeInsets.all(10),
  ),

  /// Dialog：黑色背景 + 绿色描边（注意这里用的是 DialogThemeData）
  dialogTheme: DialogThemeData(
    backgroundColor: Colors.black,
    surfaceTintColor: Colors.black,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(color: TextColor ?? Colors.greenAccent, width: 1.5),
    ),
    titleTextStyle: TextStyle(
      color: TextColor,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
    contentTextStyle: TextStyle(color: TextColor, fontSize: 14),
  ),

  /// 默认图标颜色也统一成绿色
  iconTheme: IconThemeData(color: TextColor),
);
