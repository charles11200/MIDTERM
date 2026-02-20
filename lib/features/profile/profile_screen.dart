import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../auth/login_screen.dart';

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

  void _editAddress() {
    final controller = TextEditingController(
      text: box.get('deliveryAddress', defaultValue: 'Enter an address'),
    );

    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text("Delivery Address"),
        content: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: CupertinoTextField(
            controller: controller,
            placeholder: "Enter address",
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
              box.put(
                'deliveryAddress',
                controller.text.trim().isEmpty ? "Enter an address" : controller.text.trim(),
              );
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
    final address = box.get('deliveryAddress', defaultValue: 'Enter an address');
    final balance = box.get('balance', defaultValue: 0.0);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Profile"),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            /// BALANCE & SECURITY
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

            /// ADDRESS
            CupertinoListSection.insetGrouped(
              header: const Text("Delivery"),
              children: [
                CupertinoListTile(
                  title: const Text("Delivery Address"),
                  additionalInfo: Text(address),
                  trailing: const Icon(CupertinoIcons.chevron_right),
                  onTap: _editAddress,
                ),
              ],
            ),

            /// LOGOUT
            CupertinoListSection.insetGrouped(
              children: [
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.square_arrow_right, color: CupertinoColors.systemRed),
                  title: const Text(
                    "Log Out",
                    style: TextStyle(color: CupertinoColors.systemRed, fontWeight: FontWeight.w600),
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
