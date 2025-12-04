import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../themeData.dart';

//因为是简单的应用，用户注册之后直接跳转到登录界面，后面注册和登录界面都会不再显示
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _myBox = Hive.box("My_Box");
  bool match = true;
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController comfirmpassword = TextEditingController();
  bool hidePassword = true;
  bool hideConfirmPassword = true;
  void submit() {
    if (password.text != comfirmpassword.text) {
      setState(() {
        match = false;
      });
    } else {
      _myBox.put('Name', username.text);
      _myBox.put("Password", password.text);
      Navigator.popAndPushNamed(context, '/login'); //跳转到登录界面
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
                Text(match ? "" : "用户名和密码不匹配"),
                TextField(
                  controller: comfirmpassword,
                  style: const TextStyle(color: TextColor),
                  decoration: InputDecoration(
                    hintText: "Confirm your password",
                    suffixIcon: IconButton(
                      icon: Icon(
                        hideConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () => setState(
                        () => hideConfirmPassword = !hideConfirmPassword,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                //Login Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white12,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      "Register",
                      style: const TextStyle(fontSize: 16, color: TextColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
