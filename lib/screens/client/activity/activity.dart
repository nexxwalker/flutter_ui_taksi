import 'package:flutter/material.dart';
import 'package:flutter_ui_taksi/config/pallete.dart';
import 'package:flutter_ui_taksi/utils/currency.dart';

import '../../../widget/widget.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  static const List<Map<String, dynamic>> upcomingTrips = [
    {
      'id': 'TK-2041',
      'date': 'Today, 19:30',
      'pickup': 'Kenyatta Avenue, Nyeri',
      'destination': 'Nyeri County Referral Hospital',
      'price': 350.0,
      'status': 'Ongoing',
      'driver': 'Peter Hetfield',
      'car': 'assets/car-white.png',
    },
  ];

  static const List<Map<String, dynamic>> historyTrips = [
    {
      'id': 'TK-2038',
      'date': 'Yesterday, 08:15',
      'pickup': 'Nyeri County Referral Hospital',
      'destination': 'Kenyatta Avenue, Nyeri',
      'price': 600.0,
      'status': 'Completed',
      'driver': 'Peter Hetfield',
      'car': 'assets/car-black.png',
    },
    {
      'id': 'TK-2031',
      'date': '12 Oct, 17:40',
      'pickup': 'Gakere Road, Nyeri',
      'destination': 'Chaka Road, Nyeri',
      'price': 350.0,
      'status': 'Completed',
      'driver': 'Andi Wijaya',
      'car': 'assets/car-white.png',
    },
    {
      'id': 'TK-2024',
      'date': '09 Oct, 12:05',
      'pickup': 'Chaka Road, Nyeri',
      'destination': 'The Outspan Hotel',
      'price': 350.0,
      'status': 'Cancelled',
      'driver': 'Andi Wijaya',
      'car': 'assets/car-white.png',
    },
    {
      'id': 'TK-2019',
      'date': '03 Oct, 21:10',
      'pickup': 'Kenyatta Avenue, Nyeri',
      'destination': 'Gakere Road, Nyeri',
      'price': 600.0,
      'status': 'Completed',
      'driver': 'Peter Hetfield',
      'car': 'assets/car-black.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
                    'My activity',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w100,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Tabs
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: const TabBar(
                  labelColor: Pallete.color5,
                  unselectedLabelColor: Pallete.grey2,
                  indicatorColor: Pallete.color5,
                  tabs: [
                    Tab(text: 'Upcoming'),
                    Tab(text: 'History'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const Expanded(
                child: TabBarView(
                  children: [
                    _TripList(
                      items: upcomingTrips,
                      emptyText: 'No upcoming rides',
                    ),
                    _TripList(
                      items: historyTrips,
                      emptyText: 'No past rides yet',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TripList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final String emptyText;

  const _TripList({required this.items, required this.emptyText});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          emptyText,
          style: Theme.of(context).textTheme.titleSmall,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(0),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF21242A).withOpacity(0.4),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Pallete.s),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  item['car'],
                  height: 44,
                  width: 60,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item['date'],
                            style:
                                Theme.of(context).textTheme.labelLarge,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        AppStatusChip(text: item['status']),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _RouteLine(
                      marker: 'assets/marker/marker-white.png',
                      address: item['pickup'],
                    ),
                    const SizedBox(height: 4),
                    _RouteLine(
                      marker: 'assets/marker/marker-orange.png',
                      address: item['destination'],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatToKES(item['price']),
                    style: const TextStyle(color: Pallete.color5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['id'],
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RouteLine extends StatelessWidget {
  final String marker;
  final String address;

  const _RouteLine({required this.marker, required this.address});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(marker, height: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            address,
            style: Theme.of(context).textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
