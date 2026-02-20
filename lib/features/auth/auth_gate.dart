import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';

import 'login_screen.dart';
import 'signup_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('database');
    final hasAccount = (box.get('username') != null && box.get('password') != null);

    return hasAccount ? const LoginScreen() : const SignupScreen();
  }
}