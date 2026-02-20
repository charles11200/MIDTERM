import 'package:flutter/cupertino.dart';

import '../../core/constants/colors.dart';
import '../../models/order.dart';
import '../../state/cart_provider.dart';
import '../../state/order_provider.dart';
import '../../tracking/tracking_screen.dart';
import 'xendit_invoice_page.dart';
import 'xendit_service.dart';

class PaymentWebviewScreen extends StatefulWidget {
  const PaymentWebviewScreen({super.key, required this.amount});
  final double amount;

  @override
  State<PaymentWebviewScreen> createState() => _PaymentWebviewScreenState();
}

class _PaymentWebviewScreenState extends State<PaymentWebviewScreen> {
  final String apiKey =
      "xnd_development_DSG7HbBeJKpUjiRguG9LxTH6qr5okg26rIdfAN5HbHgqNn9BpseBeLTWCR006O8";

  final TextEditingController _amountController = TextEditingController();

  bool _creating = false;
  String _status = "PENDING";

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.amount.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _createInvoiceAndOpenFullScreen() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      _showError("Invalid amount.");
      return;
    }

    setState(() {
      _creating = true;
      _status = "CREATING_INVOICE";
    });

    try {
      final service = XenditService(apiKey);
      final invoice = await service.createInvoice(
        amount: amount,
        externalId: "ext_${DateTime.now().millisecondsSinceEpoch}",
        description: "GrabFood Order Payment",
      );

      final invoiceId = (invoice["id"] ?? "").toString();
      final invoiceUrl = (invoice["invoice_url"] ?? "").toString();
      final status = (invoice["status"] ?? "PENDING").toString().toUpperCase();

      if (invoiceId.isEmpty || invoiceUrl.isEmpty) {
        throw Exception("Missing invoice id/url in response.");
      }

      if (!mounted) return;
      setState(() {
        _creating = false;
        _status = status;
      });

      // ✅ FULL SCREEN PAGE HERE
      final paid = await Navigator.of(context).push<bool>(
        CupertinoPageRoute(
          builder: (_) => XenditInvoicePage(
            apiKey: apiKey,
            invoiceId: invoiceId,
            invoiceUrl: invoiceUrl,
          ),
        ),
      );

      if (paid == true) {
        _finalizeOrder("Paid via Xendit");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _creating = false);
      _showError("Failed to create invoice.\n$e");
    }
  }

  void _finalizeOrder(String status) {
    final cart = CartStore.instance;
    final now = DateTime.now();
    final total = double.tryParse(_amountController.text) ?? widget.amount;

    final order = Order(
      orderId: 'ORD-${now.millisecondsSinceEpoch.toString().substring(7)}',
      restaurantName: 'GrabFood Order',
      total: total,
      createdAtIso: now.toIso8601String(),
      status: status,
    );

    OrderStore.instance.addOrder(order);
    cart.clear();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      CupertinoPageRoute(builder: (_) => const TrackingScreen()),
          (r) => false,
    );
  }

  void _showError(String msg) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text("Error"),
        content: Text(msg),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final amount = double.tryParse(_amountController.text) ?? widget.amount;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text("Payment"),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Icon(CupertinoIcons.xmark, color: CupertinoColors.systemRed),
        ),
      ),
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: SafeArea(
        child: Column(
          children: [
            // status header
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.money_dollar_circle_fill, color: AppColors.grabGreen),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Xendit Invoice", style: TextStyle(fontWeight: FontWeight.w900)),
                          const SizedBox(height: 2),
                          Text(
                            "Status: $_status",
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: (_status == "PAID" || _status == "SETTLED")
                                  ? AppColors.grabGreen
                                  : CupertinoColors.systemGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text("₱${amount.toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
            ),

            // amount + button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Amount", style: TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    CupertinoTextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabled: !_creating,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton.filled(
                        onPressed: _creating ? null : _createInvoiceAndOpenFullScreen,
                        child: _creating
                            ? const CupertinoActivityIndicator()
                            : const Text("Pay Now"),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // optional helper (no embedded webview anymore)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                "After creating the invoice, you will be redirected to a full-screen payment page.",
                style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}