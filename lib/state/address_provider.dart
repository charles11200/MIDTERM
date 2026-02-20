import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/saved_address.dart';

class AddressStore extends ChangeNotifier {
  AddressStore._();
  static final AddressStore instance = AddressStore._();

  static const _boxName = "profile_box";
  static const _keySavedAddress = "saved_address";

  SavedAddress? _saved;

  SavedAddress? get saved => _saved;

  Future<void> init() async {
    final box = await Hive.openBox(_boxName);
    final raw = box.get(_keySavedAddress);
    _saved = SavedAddress.fromJson(raw);
  }

  Future<void> save(SavedAddress addr) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_keySavedAddress, addr.toJson());
    _saved = addr;
    notifyListeners();
  }

  Future<void> clear() async {
    final box = await Hive.openBox(_boxName);
    await box.delete(_keySavedAddress);
    _saved = null;
    notifyListeners();
  }
}