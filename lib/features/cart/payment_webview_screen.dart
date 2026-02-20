import 'package:flutter/cupertino.dart';

import '../../core/biometrics.dart';
import '../../core/constants/colors.dart';
import '../../models/order.dart';
import '../../state/cart_provider.dart';
import '../../state/order_provider.dart';
import '../../tracking/tracking_screen.dart';

class PaymentWebviewScreen extends StatefulWidget {
  const PaymentWebviewScreen({super.key, required this.amount});
  final double amount;

  @override
  State<PaymentWebviewScreen> createState() => _PaymentWebviewScreenState();
}

class _PaymentWebviewScreenState extends State<PaymentWebviewScreen> {
  bool isCashless = true;
  bool _processing = false;

  /// ===============================
  /// BIOMETRIC AUTH (CONVERGE STYLE)
  /// ===============================
  Future<bool> _authenticate() async {
    final okAvailable = await Biometrics.isAvailable();
    if (!okAvailable) {
      if (!mounted) return false;
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text("Biometrics Error"),
          content: const Text(
            "Biometrics not available or not set up on this device.",
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text("OK"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return false;
    }

    return Biometrics.authenticate(reason: "Confirm payment");
  }

  /// ===============================
  /// CONFIRM PAYMENT
  /// ===============================
  Future<void> _confirmPayment() async {
    if (_processing) return;
    setState(() => _processing = true);

    // If cashless, require biometrics confirm. If cash, skip biometrics.
    if (isCashless) {
      final ok = await _authenticate();
      if (!mounted) return;
      if (!ok) {
        setState(() => _processing = false);
        return;
      }
    }

    final cart = CartStore.instance;
    final now = DateTime.now();

    final order = Order(
      orderId: 'ORD-${now.millisecondsSinceEpoch.toString().substring(7)}',
      restaurantName: 'Mock Restaurant',
      total: widget.amount,
      createdAtIso: now.toIso8601String(),
      status: isCashless ? 'Paid' : 'Cash on Delivery',
    );

    OrderStore.instance.addOrder(order);
    cart.clear();

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      CupertinoPageRoute(builder: (_) => const TrackingScreen()),
          (r) => false,
    );
  }

  /// ===============================
  /// UI
  /// ===============================
  @override
  Widget build(BuildContext context) {
    final amount = widget.amount;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Payment'),
      ),
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            /// XENDIT BOX
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Xendit (Mock Payment)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This is UI only. Backend integration will be added later.',
                    style: TextStyle(
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Amount',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      Text(
                        '₱${amount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            /// CASH OPTION
            _methodTile(
              title: 'Cash',
              subtitle: 'Pay upon arrival (COD)',
              selected: !isCashless,
              onTap: () => setState(() => isCashless = false),
            ),

            /// CASHLESS OPTION
            _methodTile(
              title: 'Cashless',
              subtitle: 'Online payment via Xendit (Mock)',
              selected: isCashless,
              onTap: () => setState(() => isCashless = true),
            ),

            const SizedBox(height: 16),

            /// CONFIRM BUTTON
            CupertinoButton(
              color: AppColors.grabGreen,
              onPressed: _processing ? null : _confirmPayment,
              child: _processing
                  ? const CupertinoActivityIndicator()
                  : const Text('Confirm Payment'),
            ),

            const SizedBox(height: 10),

            CupertinoButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  /// ===============================
  /// METHOD TILE
  /// ===============================
  Widget _methodTile({
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.grabGreen : AppColors.cardBorder,
            width: selected ? 1.4 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? CupertinoIcons.checkmark_circle_fill
                  : CupertinoIcons.circle,
              color: selected ? AppColors.grabGreen : CupertinoColors.systemGrey,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: CupertinoColors.systemGrey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_right,
              color: CupertinoColors.systemGrey,
            ),
          ],
        ),
      ),
    );
  }
}
