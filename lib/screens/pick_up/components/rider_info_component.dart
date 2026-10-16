import 'package:flutter/material.dart';
import 'package:flutter_ui_taksi/widget/widget.dart';

import '../../../config/pallete.dart';

class RiderInfoComponent extends StatelessWidget {
  final Function()? onTrackTrip;

  const RiderInfoComponent({
    super.key,
    this.onTrackTrip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Hang on!'),
          const Text('Peter is coming to pick you up!'),

          const SizedBox(height: 8),

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
                      Row(
                        children: [
                          Text(
                            'Hyundai Kona SUV',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          Text(
                            ' • 5UMH719',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ],
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
          const SizedBox(height: 20),
          const Text('Will be there in 5 mins'),
          const SizedBox(height: 15),

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
                )
              ],
            ),
          ),
          const SizedBox(height: 24),
          AppButton(
            text: 'TRACK TRIP',
            color: Pallete.color5,
            onTap: onTrackTrip,
          ),
          const AppButton(
            text: 'CANCEL RIDE',
            color: Pallete.color5,
          ),
        ],
      ),
    );
  }
}
