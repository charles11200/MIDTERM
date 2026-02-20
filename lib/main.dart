import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'models/task.dart';
import 'state/address_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // ✅ Register adapters BEFORE opening typed boxes
  if (!Hive.isAdapterRegistered(TaskAdapter().typeId)) {
    Hive.registerAdapter(TaskAdapter());
  }

  // ✅ Open boxes (order matters)
  await Hive.openBox('database');          // for balance, biometrics, saved_address
  await Hive.openBox<Task>('tasks');       // typed box for Task

  // ✅ Load saved address from Hive
  await AddressStore.instance.init();

  runApp(const App());
}