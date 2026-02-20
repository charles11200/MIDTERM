import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';

import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final box = Hive.box('database');

  final username = TextEditingController();
  final password = TextEditingController();

  bool hidePassword = true;
  String msg = '';

  void signup() {
    final u = username.text.trim();
    final p = password.text.trim();

    if (u.isEmpty || p.isEmpty) {
      setState(() => msg = "Please fill in all fields.");
      return;
    }

    box.put('username', u);
    box.put('password', p);

    // defaults
    box.put('biometrics', box.get('biometrics', defaultValue: true));
    box.put('darkMode', box.get('darkMode', defaultValue: false));
    box.put('deliveryAddress', box.get('deliveryAddress', defaultValue: 'Enter an address'));

    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Create Account"),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CupertinoTextField(
                controller: username,
                padding: const EdgeInsets.all(12),
                placeholder: "Username",
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(CupertinoIcons.person),
                ),
              ),
              const SizedBox(height: 12),
              CupertinoTextField(
                controller: password,
                padding: const EdgeInsets.all(12),
                placeholder: "Password",
                obscureText: hidePassword,
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(CupertinoIcons.lock),
                ),
                suffix: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => setState(() => hidePassword = !hidePassword),
                  child: Icon(hidePassword ? CupertinoIcons.eye : CupertinoIcons.eye_slash),
                ),
              ),
              const SizedBox(height: 18),
              CupertinoButton.filled(
                onPressed: signup,
                child: const Text("Sign Up"),
              ),
              const SizedBox(height: 10),
              Text(msg, style: const TextStyle(color: CupertinoColors.destructiveRed)),
            ],
          ),
        ),
      ),
    );
  }
}
