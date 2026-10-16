import 'package:flutter/material.dart';
import 'package:flutter_ui_taksi/config/pallete.dart';
import 'package:flutter_ui_taksi/utils/currency.dart';
import 'package:flutter_ui_taksi/services/api_service.dart';

import '../../widget/widget.dart';

class GroceriesPage extends StatefulWidget {
  final ApiService api;

  const GroceriesPage({super.key, required this.api});

  @override
  State<GroceriesPage> createState() => _GroceriesPageState();
}

class _GroceriesPageState extends State<GroceriesPage> {
  @override
  void initState() {
    super.initState();
  }

  static const List<Map<String, dynamic>> stores = [
    {'id': 1, 'name': 'Naivas Nyeri'},
    {'id': 2, 'name': 'Quickmart Nyeri'},
    {'id': 3, 'name': 'Nyeri Municipal Market'},
  ];

  static const List<Map<String, dynamic>> basket = [
    {'id': 1, 'name': 'Tilapia (fresh, 1 kg)', 'price': 800.0},
    {'id': 2, 'name': 'Unga 2 kg', 'price': 260.0},
    {'id': 3, 'name': 'Sukuma wiki (bunch)', 'price': 30.0},
    {'id': 4, 'name': 'Milk 1 L', 'price': 65.0},
    {'id': 5, 'name': 'Bread 400 g', 'price': 65.0},
    {'id': 6, 'name': 'Tomatoes 1 kg', 'price': 120.0},
  ];

  static const double deliveryFee = 100.0;

  int activeStore = 1;
  final Map<int, int> quantities = {1: 1, 3: 1, 4: 1};

  double get total => basket.fold(
      0,
      (sum, item) =>
          sum + (item['price'] as double) * (quantities[item['id']] ?? 0));

  int get itemCount => quantities.values.fold(0, (sum, q) => sum + q);

  void changeQuantity(int id, int delta) {
    setState(() {
      final int next = (quantities[id] ?? 0) + delta;
      if (next <= 0) {
        quantities.remove(id);
      } else {
        quantities[id] = next;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20).copyWith(top: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                AppButtonIcon(
                  onTap: () => Navigator.maybePop(context),
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Buy me groceries',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w100,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Store picker
            const Text(
              'Shop at',
              style: TextStyle(fontWeight: FontWeight.w100),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: stores.length,
                itemBuilder: (context, index) {
                  final store = stores[index];
                  final bool isActive = activeStore == store['id'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        activeStore = store['id'];
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(
                        left: index == 0 ? 0 : 8,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isActive
                            ? Pallete.s
                            : const Color(0xFF21242A).withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Pallete.s),
                      ),
                      child: Text(
                        store['name'],
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Basket
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(0),
                children: [
                  ...basket.map((item) {
                    final int quantity = quantities[item['id']] ?? 0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF21242A).withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Pallete.s),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['name']),
                                Text(
                                  formatToKES(item['price']),
                                  style:
                                      Theme.of(context).textTheme.labelMedium,
                                ),
                              ],
                            ),
                          ),
                          _quantityButton(
                            icon: Icons.remove,
                            onTap: () =>
                                changeQuantity(item['id'], -1),
                          ),
                          SizedBox(
                            width: 36,
                            child: Center(
                              child: Text('$quantity'),
                            ),
                          ),
                          _quantityButton(
                            icon: Icons.add,
                            onTap: () => changeQuantity(item['id'], 1),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 4),
                  Text(
                    'Delivery to Kenyatta Avenue, Nyeri • ${formatToKES(deliveryFee)} fee',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 12),

                  // Summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Pallete.color5.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Pallete.s),
                    ),
                    child: Column(
                      children: [
                        _summaryRow(
                            '$itemCount items', formatToKES(total)),
                        _summaryRow('Delivery fee', formatToKES(deliveryFee)),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total'),
                            Text(
                              formatToKES(total + deliveryFee),
                              style:
                                  const TextStyle(color: Pallete.color5),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            AppButton(
              text: 'PLACE GROCERIES ORDER',
              color: Pallete.color5,
              onTap: () {
                if (itemCount == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Add items to your basket first'),
                      backgroundColor: Pallete.black2,
                    ),
                  );
                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Groceries from ${stores.firstWhere((store) => store['id'] == activeStore)['name']} on the way • ${formatToKES(total + deliveryFee)}',
                    ),
                    backgroundColor: Pallete.black2,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _quantityButton(
      {required IconData icon, required Function()? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Pallete.color5.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Pallete.s),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
