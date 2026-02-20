import 'package:flutter/cupertino.dart';
import '../../core/constants/colors.dart';
import '../../core/widgets/safe_image.dart';
import '../../state/cart_provider.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final cart = CartStore.instance;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Basket')),
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: SafeArea(
        child: cart.items.isEmpty
            ? const Center(child: Text('Your basket is empty.'))
            : Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: cart.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final it = cart.items[i];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        SafeAssetImage(path: it.image, width: 62, height: 62, radius: 14),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(it.name, style: const TextStyle(fontWeight: FontWeight.w900)),
                            const SizedBox(height: 6),
                            Text('₱${it.price.toStringAsFixed(0)}',
                                style: const TextStyle(color: CupertinoColors.systemGrey)),
                          ]),
                        ),
                        Row(
                          children: [
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () => setState(() => cart.decrease(it.id)),
                              child: const Icon(CupertinoIcons.minus_circle, color: CupertinoColors.systemGrey),
                            ),
                            Text('${it.qty}', style: const TextStyle(fontWeight: FontWeight.w900)),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () => setState(() => cart.add(it)),
                              child: const Icon(CupertinoIcons.plus_circle, color: AppColors.grabGreen),
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                        Text('₱${cart.total.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    CupertinoButton.filled(
                      onPressed: () async {
                        await Navigator.of(context).push(
                          CupertinoPageRoute(builder: (_) => const CheckoutScreen()),
                        );
                        setState(() {});
                      },
                      child: const Text('Checkout'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
