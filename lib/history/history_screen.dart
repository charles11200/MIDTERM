import 'package:flutter/cupertino.dart';
import '../../core/constants/colors.dart';
import '../../state/order_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = OrderStore.instance.orders;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Transaction History')),
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: SafeArea(
        child: orders.isEmpty
            ? const Center(child: Text('No transactions yet.'))
            : ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final o = orders[i];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order ${o.orderId}', style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text('Restaurant: ${o.restaurantName}'),
                  Text('Total: ₱${o.total.toStringAsFixed(2)}'),
                  Text('Status: ${o.status}'),
                  const SizedBox(height: 6),
                  Text(o.createdAtIso, style: const TextStyle(color: CupertinoColors.systemGrey, fontSize: 12)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
