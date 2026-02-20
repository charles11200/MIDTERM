import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  
  // Open boxes
  await Hive.openBox('database');
  await Hive.openBox('tasks'); // Box for To-Do list

  runApp(const App());
}
