import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'features/auth/auth_gate.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('database');

    return ValueListenableBuilder(
      valueListenable: box.listenable(keys: const ['darkMode']),
      builder: (context, _, __) {
        final darkMode = box.get('darkMode', defaultValue: false) as bool;

        return CupertinoApp(
          debugShowCheckedModeBanner: false,
          theme: CupertinoThemeData(
            brightness: darkMode ? Brightness.dark : Brightness.light,
          ),
          home: const AuthGate(),
        );
      },
    );
  }
}
