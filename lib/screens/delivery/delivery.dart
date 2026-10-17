import 'package:flutter/material.dart';
import 'package:flutter_ui_taksi/config/pallete.dart';
import 'package:flutter_ui_taksi/utils/currency.dart';
import 'package:flutter_ui_taksi/services/api_service.dart';

import '../../widget/widget.dart';

class DeliveryPage extends StatefulWidget {
  final ApiService api;

  const DeliveryPage({super.key, required this.api});

  @override
  State<DeliveryPage> createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage> {

  @override
  void initState() {
    super.initState();
  }

  static final List<Map<String, dynamic>> parcels = [
    {'id': 1, 'name': 'Envelope', 'description': 'Documents & small items', 'price': 200.0, 'icon': Icons.mail_outline_rounded, 'type': 'envelope'},
    {'id': 2, 'name': 'Small box', 'description': 'Fits a boda boot box', 'price': 350.0, 'icon': Icons.inventory_2_outlined, 'type': 'small_box'},
    {'id': 3, 'name': 'Big box', 'description': 'Bulky goods within Nyeri', 'price': 600.0, 'icon': Icons.local_shipping_outlined, 'type': 'big_box'},
  ];

  int activeParcel = 1;
  String pickupAddress = 'Kenyatta Avenue, Nyeri';
  String dropoffAddress = 'Nyeri County Referral Hospital';
  String receiverName = 'Jane Wambui';
  String receiverPhone = '0712 345 678';

  bool loading = false;
  bool creating = false;
  String? error;
  Map<String, dynamic>? createdDelivery;
  bool created = false;

  Map<String, dynamic>? get selectedParcel => parcels.cast<Map<String, dynamic>>().firstWhere((p) => p['id'] == activeParcel, orElse: () => parcels.first);

  Future<void> _requestCourier() async {
    if (creating) return;
    setState(() { creating = true; error = null; });
    try {
      final d = await widget.api.createDelivery(
        pickupAddress: pickupAddress,
        dropoffAddress: dropoffAddress,
        receiverName: receiverName,
        receiverPhone: receiverPhone,
        parcelType: selectedParcel!['type'] as String,
      );
      if (!mounted) return;
      setState(() {
        creating = false;
        created = true;
        createdDelivery = d;
      });
      _showSnack('A boda courier is on the way to $pickupAddress • ${formatToKES(d['parcel_price_kes'])} — delivery #${d['id']}');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        creating = false;
        error = e.toString();
      });
      _showSnack('Could not request courier: $e');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Pallete.black2));
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
                  icon: Icon(Icons.arrow_back, color: Colors.grey[800]),
                ),
                const SizedBox(width: 16),
                const Text('Send a delivery', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w100)),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(0),
                children: [
                  // Route
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF21242A).withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Pallete.s),
                    ),
                    child: Column(
                      children: [
                        AppInputLocation(
                          icon: Image.asset('assets/marker/marker-white.png', height: 35),
                          location: pickupAddress,
                        ),
                        AppInputLocation(
                          icon: Image.asset('assets/marker/marker-orange.png', height: 35),
                          location: dropoffAddress,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Receiver
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF21242A).withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Pallete.s),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(48),
                          child: Image.asset('assets/person.png', height: 44, width: 44),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(receiverName),
                              Text('Receiver • $receiverPhone', style: Theme.of(context).textTheme.labelSmall),
                            ],
                          ),
                        ),
                        const AppStatusChip(text: 'Pending'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Parcel size
                  const Text('Parcel size', style: TextStyle(fontWeight: FontWeight.w100)),
                  const SizedBox(height: 12),
                  ...parcels.map((item) {
                    final bool isActive = activeParcel == item['id'];
                    return GestureDetector(
                      onTap: () => setState(() => activeParcel = item['id']),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isActive
                              ? Pallete.color5.withOpacity(0.1)
                              : const Color(0xFF21242A).withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Pallete.s),
                        ),
                        child: Row(
                          children: [
                            Icon(item['icon'], color: isActive ? Pallete.color5 : Pallete.grey1),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['name']),
                                  Text(item['description'], style: Theme.of(context).textTheme.labelSmall),
                                ],
                              ),
                            ),
                            Text(formatToKES(item['price'] as double), style: const TextStyle(color: Pallete.color5)),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  if (error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      color: Colors.red.withOpacity(0.1),
                      child: Text(error!, style: const TextStyle(color: Colors.red)),
                    ),
                  if (creating)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              text: creating ? 'REQUESTING COURIER…' : 'REQUEST COURIER • ${formatToKES(selectedParcel!['price'] as double)}',
              color: Pallete.color5,
              onTap: creating ? null : _requestCourier,
            ),
            if (created && createdDelivery != null) ...[
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
                          Text('Delivery #${createdDelivery!['id']} requested', style: const TextStyle(fontSize: 14)),
                          Text('${createdDelivery!['pickup_address']} → ${createdDelivery!['dropoff_address']} • ${createdDelivery!['status']}', style: Theme.of(context).textTheme.labelSmall),
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
}
