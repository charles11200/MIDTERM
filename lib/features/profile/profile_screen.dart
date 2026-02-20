import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../auth/login_screen.dart';
import '../../state/address_provider.dart';
import 'address_picker_screen.dart';
import '../../models/saved_address.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final box = Hive.box('database');

  void _editBalance() {
    final controller = TextEditingController(
      text: box.get('balance', defaultValue: 0.0).toString(),
    );

    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text("Current Balance"),
        content: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: CupertinoTextField(
            controller: controller,
            keyboardType: TextInputType.number,
            placeholder: "Enter amount",
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: const Text("Save"),
            onPressed: () {
              final amount = double.tryParse(controller.text) ?? 0.0;
              box.put('balance', amount);
              Navigator.pop(context);
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  void logout() {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text("Log Out"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          CupertinoDialogAction(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text("Log Out"),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                CupertinoPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final biometrics = box.get('biometrics', defaultValue: true);
    final balance = box.get('balance', defaultValue: 0.0);

    final saved = AddressStore.instance.saved;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Profile"),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            CupertinoListSection.insetGrouped(
              header: const Text("Account & Security"),
              children: [
                CupertinoListTile(
                  title: const Text("Current Balance"),
                  additionalInfo: Text("₱${balance.toStringAsFixed(2)}"),
                  trailing: const Icon(CupertinoIcons.pencil),
                  onTap: _editBalance,
                ),
                CupertinoListTile(
                  title: const Text("Enable Biometrics"),
                  trailing: CupertinoSwitch(
                    value: biometrics,
                    onChanged: (v) {
                      box.put('biometrics', v);
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),

            CupertinoListSection.insetGrouped(
              header: const Text("Delivery"),
              children: [
                CupertinoListTile(
                  title: const Text("Saved Address"),
                  additionalInfo: Text(
                    saved == null
                        ? "Not set"
                        : "${saved.label} • ${saved.addressLine}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(CupertinoIcons.chevron_right),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => AddressPickerScreen(initial: saved),
                      ),
                    );

                    if (result is SavedAddress) {
                      await AddressStore.instance.save(result);
                      setState(() {});
                    }
                  },
                ),
              ],
            ),

            CupertinoListSection.insetGrouped(
              children: [
                CupertinoListTile(
                  leading: const Icon(
                    CupertinoIcons.square_arrow_right,
                    color: CupertinoColors.systemRed,
                  ),
                  title: const Text(
                    "Log Out",
                    style: TextStyle(
                      color: CupertinoColors.systemRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: logout,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}