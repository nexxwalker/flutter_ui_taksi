import 'package:flutter/material.dart';
import 'package:flutter_ui_taksi/config/pallete.dart';
import 'package:flutter_ui_taksi/config/routes.dart';
import 'package:flutter_ui_taksi/utils/currency.dart';

import '../../../widget/widget.dart';

class TripProgressPage extends StatefulWidget {
  const TripProgressPage({super.key});

  @override
  State<TripProgressPage> createState() => _TripProgressPageState();
}

class _TripProgressPageState extends State<TripProgressPage> {
  bool tripFinished = false;
  int rating = 0;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final String pickup = _valueOrDefault(args, 'pickup', 'Kenyatta Avenue, Nyeri');
    final String destination =
        _valueOrDefault(args, 'destination', 'Nyeri County Referral Hospital');
    final double fare = (args?['fare'] as double?) ?? 350.0;

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20).copyWith(top: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                    Text(
                      tripFinished ? 'Trip finished' : 'Trip in progress',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w100,
                      ),
                    ),
                  ],
                ),
                const AppButtonIcon(
                  icon: AppSvgIcon('notifications'),
                  isNotify: true,
                ),
              ],
            ),
            const SizedBox(height: 24),

            Expanded(
              child: tripFinished ? _ratingView(context) : _tripView(
                pickup: pickup,
                destination: destination,
                fare: fare,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _valueOrDefault(
      Map<String, dynamic>? args, String key, String fallback) {
    final dynamic value = args?[key];
    if (value is String && value.isNotEmpty) return value;
    return fallback;
  }

  Widget _tripView(
      {required String pickup,
      required String destination,
      required double fare}) {
    return ListView(
      padding: const EdgeInsets.all(0),
      children: [
        // Trip status
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Pallete.color5.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Pallete.s),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Peter is driving you'),
                  AppStatusChip(text: 'On trip'),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Arriving in about 12 minutes',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Route
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF21242A).withOpacity(0.4),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Pallete.s),
          ),
          child: Column(
            children: [
              _RouteRow(
                marker: 'assets/marker/marker-white.png',
                address: pickup,
                label: 'PICKUP',
              ),
              Container(
                margin: const EdgeInsets.only(left: 8),
                height: 24,
                width: 1,
                color: Pallete.s,
              ),
              _RouteRow(
                marker: 'assets/marker/marker-orange.png',
                address: destination,
                label: 'DROPOFF',
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Progress
        SizedBox(
          height: 30,
          child: Stack(
            children: [
              Positioned(
                top: 8,
                left: 0,
                right: 0,
                child: Container(
                  height: 3,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Pallete.s,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 3,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Pallete.color5,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 150,
                child: Image.asset(
                  'assets/car-icon.png',
                  height: 20,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Trip stats
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const _TripStat(label: 'DISTANCE', value: '4.2 km'),
            const _TripStat(label: 'TRIP TIME', value: '12 min'),
            _TripStat(label: 'FARE', value: formatToKES(fare)),
          ],
        ),
        const SizedBox(height: 24),

        // Driver info
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(48),
                  child: Image.asset(
                    'assets/person.png',
                    height: 48,
                    width: 48,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Peter Hetfield'),
                    Text(
                      'Hyundai Kona SUV • 5UMH719',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                AppButtonIcon(
                  icon: const AppSvgIcon('phone'),
                  borderRadius: 10,
                  border: Border.all(color: Pallete.s),
                ),
                const SizedBox(width: 16),
                AppButtonIcon(
                  icon: const AppSvgIcon('message', height: 18),
                  borderRadius: 10,
                  border: Border.all(color: Pallete.s),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 32),

        AppButton(
          text: 'END TRIP',
          color: Pallete.color5,
          onTap: () {
            setState(() {
              tripFinished = true;
            });
          },
        ),
        const AppButton(text: 'CANCEL RIDE'),
      ],
    );
  }

  Widget _ratingView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),

        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(64),
            child: Image.asset(
              'assets/person.png',
              height: 96,
              width: 96,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'Rate your trip',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w100),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'How was your ride with Peter?',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        const SizedBox(height: 24),

        // Stars
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final isActive = index < rating;

            return GestureDetector(
              onTap: () {
                setState(() {
                  rating = index + 1;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  isActive ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 40,
                  color:
                      isActive ? Pallete.color5 : Colors.grey.withOpacity(0.4),
                ),
              ),
            );
          }),
        ),
        const Spacer(),

        AppButton(
          text: 'SUBMIT RATING',
          color: Pallete.color5,
          onTap: () {
            Navigator.pushNamedAndRemoveUntil(
                context, Routes.home, (route) => false);
          },
        ),
      ],
    );
  }
}

class _RouteRow extends StatelessWidget {
  final String marker;
  final String address;
  final String label;

  const _RouteRow({
    required this.marker,
    required this.address,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(marker, height: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall,
              ),
              Text(
                address,
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TripStat extends StatelessWidget {
  final String label;
  final String value;

  const _TripStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Pallete.color5)),
      ],
    );
  }
}
