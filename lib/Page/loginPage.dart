import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../themeData.dart';
//可以帮助实现登录注册的包，还没试过

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //text controllers
  final _myBox = Hive.box("My_Box");
  bool match = true;
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();

  bool hidePassword = true;
  bool hideConfirmPassword = true;
  void Login() {
    if (username.text == _myBox.get("Name") &&
        password == _myBox.get("Password")) {
      //用户信息匹配成功
      Navigator.popAndPushNamed(context, '/home');
      //跳转到主页面
    } else {
      print(_myBox.get("Name"));
      print(_myBox.get("Password"));
      setState(() {
        match = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: Column(
              children: [
                const Icon(Icons.lock_outline, size: 70, color: TextColor),
                const SizedBox(height: 20),
                TextField(
                  controller: username,
                  style: const TextStyle(color: TextColor),
                  decoration: const InputDecoration(hintText: "User name"),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: password,
                  style: const TextStyle(color: TextColor),
                  decoration: InputDecoration(
                    hintText: "password",
                    suffixIcon: IconButton(
                      icon: Icon(
                        hidePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => hidePassword = !hidePassword),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                //Login Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: Login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white12,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      "Login",
                      style: const TextStyle(fontSize: 16, color: TextColor),
                    ),
                  ),
                ),
                Text(match ? "" : "该用户不存在", style: TextStyle(color: TextColor)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
