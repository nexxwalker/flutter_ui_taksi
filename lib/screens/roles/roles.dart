import 'package:flutter/material.dart';
import 'package:flutter_ui_taksi/config/pallete.dart';
import 'package:flutter_ui_taksi/config/routes.dart';

import '../../widget/widget.dart';

class RolesPage extends StatelessWidget {
  const RolesPage({super.key});

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
                  'Switch role',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w100,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(0),
                children: [
                  const Text(
                    'Choose how you want to use My Town App',
                    style: TextStyle(fontWeight: FontWeight.w100),
                  ),
                  const SizedBox(height: 16),

                  // Client
                  AppRoleCard(
                    title: 'Client',
                    subtitle: 'Book a ride, track your driver and rate trips',
                    icon: Icons.person_pin_circle_rounded,
                    color: Pallete.color5,
                    onTap: () => Navigator.pushNamedAndRemoveUntil(
                        context, Routes.home, (route) => false),
                  ),

                  // Driver
                  AppRoleCard(
                    title: 'Driver',
                    subtitle: 'Go online, accept requests and track earnings',
                    icon: Icons.drive_eta_rounded,
                    color: const Color(0xFF35FE55),
                    onTap: () => Navigator.pushNamedAndRemoveUntil(
                        context, Routes.driver, (route) => false),
                  ),

                  // Admin
                  AppRoleCard(
                    title: 'Admin',
                    subtitle: 'Monitor rides, approve drivers and revenue',
                    icon: Icons.admin_panel_settings_rounded,
                    color: const Color(0xFF35DAFE),
                    onTap: () => Navigator.pushNamedAndRemoveUntil(
                        context, Routes.admin, (route) => false),
                  ),

                  const SizedBox(height: 8),

                  // Client activity
                  AppRoleCard(
                    title: 'My rides',
                    subtitle: 'View your upcoming and past trips',
                    icon: Icons.history_rounded,
                    color: Pallete.primary,
                    onTap: () => Navigator.pushNamed(context, Routes.activity),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppRoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Function()? onTap;

  const AppRoleCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Pallete.s),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Pallete.s),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }
}
