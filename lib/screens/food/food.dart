import 'package:flutter/material.dart';
import 'package:flutter_ui_taksi/config/pallete.dart';
import 'package:flutter_ui_taksi/utils/currency.dart';
import 'package:flutter_ui_taksi/services/api_service.dart';

import '../../widget/widget.dart';

class FoodPage extends StatefulWidget {
  final ApiService api;

  const FoodPage({super.key, required this.api});

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  List<Map<String, dynamic>> restaurants = [];
  List<Map<String, dynamic>> menu = [];
  List<Map<String, dynamic>> cart = [];
  bool loading = true;
  String? error;
  bool placing = false;
  int? selectedRestaurantId;

  double get subtotal => cart.fold(0, (sum, item) => sum + (item['price'] as double) * (item['qty'] as int));
  double get deliveryFee => 100.0;
  double get total => subtotal + deliveryFee;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final rest = await widget.api.getRestaurants();
      if (!mounted) return;
      setState(() {
        restaurants = rest;
        selectedRestaurantId = rest.isNotEmpty ? rest.first['id'] : null;
        loading = false;
      });
      if (selectedRestaurantId != null) _loadMenu();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = e.toString();
      });
    }
  }

  Future<void> _loadMenu() async {
    if (selectedRestaurantId == null) return;
    try {
      final items = await widget.api.getMenu(restaurantId: selectedRestaurantId!);
      if (!mounted) return;
      setState(() { menu = items; });
    } catch (e) {
      if (!mounted) return;
      setState(() { error = e.toString(); });
    }
  }

  void _selectRestaurant(int id) {
    setState(() {
      selectedRestaurantId = id;
      cart = [];
      error = null;
    });
    _loadMenu();
  }

  void _toggle(int itemId) {
    setState(() {
      final existing = cart.indexWhere((item) => item['id'] == itemId);
      if (existing >= 0) {
        cart.removeAt(existing);
      } else {
        final item = menu.firstWhere((item) => item['id'] == itemId);
        cart.add({'id': item['id'], 'name': item['name'], 'price': item['price'], 'qty': 1});
      }
    });
  }

  Future<void> _placeOrder() async {
    if (cart.isEmpty) {
      _showSnack('Pick something from the menu first');
      return;
    }
    setState(() => placing = true);
    try {
      final order = await widget.api.createFoodOrder(
        restaurantId: selectedRestaurantId!,
        items: cart.map((item) => {'id': item['id'], 'qty': item['qty']}).toList(),
        pickupAddress: 'Kenyatta Avenue, Nyeri',
      );
      if (!mounted) return;
      setState(() {
        placing = false;
        _selectedOrder = order;
      });
      _showSnack('Order placed at $_restaurantName • ${formatToKES(order['total_kes'])} — #${order['id']}');
    } catch (e) {
      if (!mounted) return;
      setState(() => placing = false);
      _showSnack('Could not place order: $e');
    }
  }

  String get _restaurantName {
    try {
      return restaurants.firstWhere((r) => r['id'] == selectedRestaurantId)['name'] ?? 'the restaurant';
    } catch (_) {
      return 'the restaurant';
    }
  }

  Map<String, dynamic>? _selectedOrder;

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Pallete.black2),
    );
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
                  icon: const Icon(Icons.refresh_rounded),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Order food',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w100),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : error != null
                      ? Center(child: Text('Could not load food: $error'))
                      : ListView(
                          padding: const EdgeInsets.all(0),
                          children: [
                            // Restaurants
                            const Text('Restaurants around Nyeri', style: TextStyle(fontWeight: FontWeight.w100)),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 90,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: restaurants.length,
                                itemBuilder: (context, index) {
                                  final item = restaurants[index];
                                  final bool isActive = selectedRestaurantId == item['id'];
                                  return GestureDetector(
                                    onTap: () => _selectRestaurant(item['id']),
                                    child: Container(
                                      width: 190,
                                      margin: EdgeInsets.only(left: index == 0 ? 0 : 12),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isActive
                                            ? Pallete.color5.withOpacity(0.1)
                                            : const Color(0xFF21242A).withOpacity(0.4),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Pallete.s),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(item['name'], style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Icon(Icons.star_rounded, size: 14, color: Pallete.color5),
                                              const SizedBox(width: 4),
                                              Flexible(
                                                child: Text(
                                                  '${item['rating']} • ${item['eta']} away',
                                                  style: Theme.of(context).textTheme.labelSmall,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Menu
                            Text('Menu • $_restaurantName', style: const TextStyle(fontWeight: FontWeight.w100)),
                            const SizedBox(height: 12),
                            if (menu.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(child: Text('No menu items available')),
                              )
                            else
                              ...menu.map((item) {
                                final inCart = cart.any((c) => c['id'] == item['id']);
                                final qty = inCart ? (cart.firstWhere((c) => c['id'] == item['id'])['qty'] as int) : 0;
                                return GestureDetector(
                                  onTap: () => _toggle(item['id']),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: inCart
                                          ? Pallete.color5.withOpacity(0.1)
                                          : const Color(0xFF21242A).withOpacity(0.4),
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
                                              Text(formatToKES(item['price']), style: const TextStyle(color: Pallete.color5)),
                                              if (inCart) ...[
                                                const SizedBox(height: 2),
                                                Text('$qty × ${formatToKES((item['price'] as double) * qty)}', style: Theme.of(context).textTheme.labelSmall),
                                              ],
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: inCart
                                                ? Pallete.color5.withOpacity(0.3)
                                                : Pallete.s.withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Pallete.s),
                                          ),
                                          child: Icon(inCart ? Icons.check : Icons.add, size: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            const SizedBox(height: 4),
                            // Cart summary
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Pallete.color5.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Pallete.s),
                              ),
                              child: Column(
                                children: [
                                  _summaryRow('${cart.length} items', formatToKES(subtotal)),
                                  _summaryRow('Delivery fee', formatToKES(deliveryFee)),
                                  const Divider(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Total'),
                                      Text(formatToKES(total), style: const TextStyle(color: Pallete.color5)),
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
              text: placing ? 'PLACING ORDER…' : 'ORDER FOOD',
              color: Pallete.color5,
              onTap: placing ? null : _placeOrder,
            ),
            if (_selectedOrder != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Pallete.color5.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Pallete.color5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Pallete.color5, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Order #${_selectedOrder!['id']} confirmed', style: const TextStyle(fontSize: 14)),
                          Text('Status: ${_selectedOrder!['status']} • ${formatToKES(_selectedOrder!['total_kes'])}', style: Theme.of(context).textTheme.labelSmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: Theme.of(context).textTheme.bodySmall), Text(value, style: Theme.of(context).textTheme.bodyMedium)],
      ),
    );
  }
}
