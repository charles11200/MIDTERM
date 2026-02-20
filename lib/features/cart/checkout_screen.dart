import 'package:flutter/cupertino.dart';
import '../../core/constants/colors.dart';
import '../../state/cart_provider.dart';
import 'payment_webview_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final cart = CartStore.instance;

  String deliveryOption = 'Standard • 22 mins • ₱50';
  String notes = '';
  bool includeCutlery = false;

  Future<void> _chooseDelivery() async {
    await showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: const Text('Delivery options'),
        message: const Text('Choose your delivery speed'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              setState(() => deliveryOption = 'Priority • 17 mins • ₱70');
              Navigator.pop(context);
            },
            child: const Text('Priority • 17 mins • ₱70'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              setState(() => deliveryOption = 'Standard • 22 mins • ₱50');
              Navigator.pop(context);
            },
            child: const Text('Standard • 22 mins • ₱50'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              setState(() => deliveryOption = 'Saver • 37 mins • ₱35');
              Navigator.pop(context);
            },
            child: const Text('Saver • 37 mins • ₱35'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deliveryFee = deliveryOption.contains('₱70')
        ? 70.0
        : deliveryOption.contains('₱35')
        ? 35.0
        : 50.0;

    final grandTotal = cart.total + deliveryFee;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Checkout')),
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            _card(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                Text('Deliver to', style: TextStyle(fontWeight: FontWeight.w900)),
                SizedBox(height: 6),
                Text('Enter an address (UI only for now)', style: TextStyle(color: CupertinoColors.systemGrey)),
              ]),
            ),
            const SizedBox(height: 10),
            _card(
              child: Row(
                children: [
                  const Expanded(child: Text('Delivery option', style: TextStyle(fontWeight: FontWeight.w900))),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _chooseDelivery,
                    child: Text(deliveryOption, style: const TextStyle(color: AppColors.grabGreen, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _card(
              child: Row(
                children: [
                  const Expanded(child: Text('Include cutlery', style: TextStyle(fontWeight: FontWeight.w900))),
                  CupertinoSwitch(
                    value: includeCutlery,
                    onChanged: (v) => setState(() => includeCutlery = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Notes for rider', style: TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    placeholder: 'e.g. Leave at guard / call me when outside',
                    onChanged: (v) => setState(() => notes = v),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _card(
              child: Column(
                children: [
                  _row('Subtotal', '₱${cart.total.toStringAsFixed(2)}'),
                  _row('Delivery fee', '₱${deliveryFee.toStringAsFixed(2)}'),
                  const SizedBox(height: 6),
                  _row('Total', '₱${grandTotal.toStringAsFixed(2)}', bold: true),
                ],
              ),
            ),
            const SizedBox(height: 14),
            CupertinoButton.filled(
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(builder: (_) => PaymentWebviewScreen(amount: grandTotal)),
                );
              },
              child: const Text('Place order'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String a, String b, {bool bold = false}) {
    final style = TextStyle(fontWeight: bold ? FontWeight.w900 : FontWeight.w600);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(a, style: style),
        Text(b, style: style),
      ]),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: child,
    );
  }
}
