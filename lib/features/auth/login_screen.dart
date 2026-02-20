import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons; // ONLY icon
import 'package:hive/hive.dart';

import '../../core/biometrics.dart';

import '../home/home_tabs.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final box = Hive.box('database');

  final username = TextEditingController();
  final password = TextEditingController();

  bool hidePassword = true;
  String msg = "";

    // LocalAuthentication is handled by Biometrics helper (see lib/core/biometrics.dart)

  Future<void> biometricLogin() async {
    final bioEnabled = box.get('biometrics', defaultValue: true) == true;
    final savedUser = (box.get('username') ?? '').toString();
    final savedPass = (box.get('password') ?? '').toString();

    if (!bioEnabled) {
      if (!mounted) return;
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text("Biometrics Disabled"),
          content: const Text("Enable biometrics in Profile > Security to use Face ID / Fingerprint."),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text("OK"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    if (savedUser.isEmpty || savedPass.isEmpty) {
      if (!mounted) return;
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text("No saved account"),
          content: const Text("Login once with your username and password to save your account."),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text("OK"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    final ok = await Biometrics.authenticate(reason: "Authenticate to login");
    if (!mounted) return;

    if (!ok) return;

    // ✅ After successful biometrics, log in using the saved credentials
    username.text = savedUser;
    password.text = savedPass;
    login();
  }


  void login() {
    final u = username.text.trim();
    final p = password.text.trim();

    if (u == (box.get("username") ?? "").toString() &&
        p == (box.get("password") ?? "").toString()) {
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (_) => const HomeTabs()),
      );
    } else {
      setState(() => msg = "Invalid username or password");
    }
  }

  @override
  void dispose() {
    username.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(middle: Text("Login")),
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
                  child: Icon(
                    hidePassword ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              CupertinoButton.filled(
                onPressed: login,
                child: const Text("Login"),
              ),

              // ✅ Always show fingerprint button (Grab-like)
              CupertinoButton(
                padding: const EdgeInsets.only(top: 6),
                onPressed: biometricLogin,
                child: const Icon(Icons.fingerprint, size: 34),
              ),

              const SizedBox(height: 8),
              Text(
                msg,
                style: const TextStyle(color: CupertinoColors.destructiveRed),
              ),

              const SizedBox(height: 14),
              CupertinoButton(
                onPressed: () {
                  box.clear();
                  Navigator.pushReplacement(
                    context,
                    CupertinoPageRoute(builder: (_) => const SignupScreen()),
                  );
                },
                child: const Text("Reset Account"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
