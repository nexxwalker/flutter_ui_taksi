import 'package:flutter/material.dart';
import 'package:flutter_ui_taksi/config/pallete.dart';
import 'package:flutter_ui_taksi/config/routes.dart';
import 'package:flutter_ui_taksi/services/api_service.dart';

import '../widget/widget.dart';

class HomePage extends StatelessWidget {
  final ApiService? api;

  const HomePage({super.key, this.api});

  @override
  Widget build(BuildContext context) {
    final api = this.api ?? ApiService.forWeb();
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
                  onTap: () {},
                  icon: const Icon(Icons.menu_rounded),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Good Evening Peyman',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w100,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'What do you want to do today?',
              style: TextStyle(fontWeight: FontWeight.w100),
            ),
            const SizedBox(height: 16),
            // Ride card
            CardRideButton(
              onTap: () => Navigator.pushNamed(context, Routes.pickUp),
            ),
            const SizedBox(height: 16),
            // Service cards
            Row(
              children: [
                Expanded(
                  child: ServiceCard(
                    icon: Icons.shopping_basket_rounded,
                    title: 'Need groceries?',
                    onTap: () => Navigator.pushNamed(
                      context,
                      Routes.groceries,
                      arguments: {'api': api},
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ServiceCard(
                    icon: Icons.local_shipping_rounded,
                    title: 'Need a delivery?',
                    onTap: () => Navigator.pushNamed(
                      context,
                      Routes.delivery,
                      arguments: {'api': api},
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ServiceCard(
                    icon: Icons.restaurant_rounded,
                    title: 'Hmm... Hungry?!',
                    onTap: () => Navigator.pushNamed(
                      context,
                      Routes.food,
                      arguments: {'api': api},
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Footer
            Expanded(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(48),
                        child: Image.asset(
                          'assets/person.png',
                          height: 44,
                          width: 44,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Peyman Hosseini',
                              style: TextStyle(fontSize: 14),
                            ),
                            Text(
                              'Premium member',
                              style: TextStyle(
                                fontSize: 12,
                                color: Pallete.grey2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppButtonIcon(
                        onTap: () => Navigator.pushNamed(context, Routes.roles),
                        icon: const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CardRideButton extends StatelessWidget {
  final VoidCallback onTap;
  const CardRideButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Pallete.color5.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Pallete.color5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Pallete.color5.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.drive_eta_rounded, color: Pallete.color5),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Book a ride',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w100),
                  ),
                  Text(
                    'Pickup anywhere in Nyeri',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Pallete.grey2),
          ],
        ),
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const ServiceCard({super.key, required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF21242A).withOpacity(0.6),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Pallete.s),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Pallete.s.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Pallete.color5, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: const TextStyle(fontSize: 14)),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Pallete.grey2),
          ],
        ),
      ),
    );
  }
}
