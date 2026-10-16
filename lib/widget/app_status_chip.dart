import 'package:flutter/material.dart';

import '../config/pallete.dart';

class AppStatusChip extends StatelessWidget {
  final String text;
  const AppStatusChip({super.key, required this.text});

  Color get _color {
    switch (text.toLowerCase()) {
      case 'completed':
      case 'active':
      case 'online':
      case 'approved':
        return const Color(0xFF35FE55);
      case 'ongoing':
      case 'on trip':
      case 'in progress':
      case 'pending':
        return Pallete.color5;
      default:
        return const Color(0xFFFE3535);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color color = _color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          letterSpacing: 0.5,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
