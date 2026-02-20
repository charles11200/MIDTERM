import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'state/address_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // Open the main database box
  await Hive.openBox('database');

  // Load saved address from Hive
  await AddressStore.instance.init();

  runApp(const App());
}
