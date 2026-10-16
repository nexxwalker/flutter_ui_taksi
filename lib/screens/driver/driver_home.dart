import 'package:flutter/material.dart';
import 'package:flutter_ui_taksi/config/pallete.dart';
import 'package:flutter_ui_taksi/config/routes.dart';
import 'package:flutter_ui_taksi/utils/currency.dart';

import '../../widget/widget.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  int currentIndex = 0;
  bool isOnline = true;

  List<Map<String, dynamic>> requests = [
    {
      'id': 'TK-2041',
      'name': 'Rina Saputra',
      'pickup': 'Kenyatta Avenue, Nyeri',
      'destination': 'Nyeri County Referral Hospital',
      'price': 350.0,
      'distance': '4.2 km',
      'classes': 'Economy',
    },
    {
      'id': 'TK-2042',
      'name': 'Budi Santoso',
      'pickup': 'Gakere Road, Nyeri',
      'destination': 'Nyeri County Referral Hospital',
      'price': 600.0,
      'distance': '6.8 km',
      'classes': 'Business',
    },
    {
      'id': 'TK-2043',
      'name': 'Maya Lestari',
      'pickup': 'Chaka Road, Nyeri',
      'destination': 'Kenyatta Avenue, Nyeri',
      'price': 350.0,
      'distance': '3.1 km',
      'classes': 'Economy',
    },
  ];

  List<Map<String, dynamic>> trips = [
    {
      'name': 'Andi Wijaya',
      'pickup': 'Kenyatta Avenue, Nyeri',
      'destination': 'Gakere Road, Nyeri',
      'price': 600.0,
      'date': 'Today, 14:20',
      'status': 'Completed',
    },
    {
      'name': 'Sinta Dewi',
      'pickup': 'Nyeri County Referral Hospital',
      'destination': 'Chaka Road, Nyeri',
      'price': 350.0,
      'date': 'Today, 11:05',
      'status': 'Completed',
    },
    {
      'name': 'Rina Saputra',
      'pickup': 'Gakere Road, Nyeri',
      'destination': 'Kenyatta Avenue, Nyeri',
      'price': 350.0,
      'date': 'Yesterday, 19:45',
      'status': 'Completed',
    },
    {
      'name': 'Budi Santoso',
      'pickup': 'Chaka Road, Nyeri',
      'destination': 'The Outspan Hotel',
      'price': 350.0,
      'date': 'Yesterday, 08:30',
      'status': 'Cancelled',
    },
  ];

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
                ClipRRect(
                  borderRadius: BorderRadius.circular(48),
                  child: Image.asset(
                    'assets/person.png',
                    height: 44,
                    width: 44,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Peter Hetfield',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Text(
                        'Hyundai Kona SUV • 5UMH719',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
                AppButtonIcon(
                  onTap: () => Navigator.pushNamed(context, Routes.roles),
                  icon: const Icon(
                    Icons.swap_horiz_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Expanded(
              child: IndexedStack(
                index: currentIndex,
                children: [
                  _homeTab(),
                  _tripsTab(),
                  _earningsTab(),
                ],
              ),
            ),

            // Bottom navigation
            Container(
              decoration: BoxDecoration(
                color: Pallete.black1,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Pallete.s),
              ),
              child: BottomNavigationBar(
                currentIndex: currentIndex,
                onTap: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedItemColor: Pallete.color5,
                unselectedItemColor: Pallete.grey1,
                selectedFontSize: 12,
                unselectedFontSize: 12,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_rounded),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.route_rounded),
                    label: 'Trips',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.account_balance_wallet_rounded),
                    label: 'Earnings',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // HOME TAB
  Widget _homeTab() {
    return ListView(
      padding: const EdgeInsets.all(0),
      children: [
        // Status switch
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isOnline
                ? const Color(0xFF35FE55).withOpacity(0.1)
                : const Color(0xFFFE3535).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Pallete.s),
          ),
          child: Row(
            children: [
              Container(
                height: 10,
                width: 10,
                decoration: BoxDecoration(
                  color: isOnline
                      ? const Color(0xFF35FE55)
                      : const Color(0xFFFE3535),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isOnline ? 'You are ONLINE' : 'You are OFFLINE',
                  style: TextStyle(
                    color: isOnline
                        ? const Color(0xFF35FE55)
                        : const Color(0xFFFE3535),
                  ),
                ),
              ),
              Switch(
                value: isOnline,
                onChanged: (value) {
                  setState(() {
                    isOnline = value;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Today earnings
        Stack(
          children: [
            const AppSvg(
              'bg-money',
              height: 120,
            ),
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    formatToKES(4800),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'TODAY’S EARNINGS • 12 TRIPS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        if (!isOnline) ...[
          // Offline empty state
          Column(
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 48,
                color: Colors.grey.withOpacity(0.5),
              ),
              const SizedBox(height: 12),
              Text(
                'You are offline, no requests will come in',
                style: Theme.of(context).textTheme.titleSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              AppButton(
                text: 'GO ONLINE',
                color: Pallete.color5,
                onTap: () {
                  setState(() {
                    isOnline = true;
                  });
                },
              ),
            ],
          ),
        ] else ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Incoming requests',
                style: TextStyle(fontWeight: FontWeight.w100),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: Pallete.color5.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Pallete.color5),
                ),
                child: Text(
                  '${requests.length}',
                  style: const TextStyle(color: Pallete.color5, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (requests.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF21242A).withOpacity(0.4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Pallete.s),
              ),
              child: Center(
                child: Text(
                  'No new requests right now, stay online',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            )
          else
            ...requests.map((request) => _requestCard(request)),
        ],
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _requestCard(Map<String, dynamic> request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Pallete.color5.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Pallete.s),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request['name'],
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      '${request['classes']} • ${request['distance']} • ${request['id']}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              Text(
                formatToKES(request['price']),
                style: const TextStyle(color: Pallete.color5, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _routeLine('assets/marker/marker-white.png', request['pickup']),
          const SizedBox(height: 6),
          _routeLine(
              'assets/marker/marker-orange.png', request['destination']),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  text: 'DECLINE',
                  color: Pallete.s,
                  onTap: () {
                    setState(() {
                      requests
                          .removeWhere((item) => item['id'] == request['id']);
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _actionButton(
                  text: 'ACCEPT',
                  color: Pallete.color5,
                  onTap: () {
                    setState(() {
                      requests
                          .removeWhere((item) => item['id'] == request['id']);
                      trips.insert(0, {
                        'name': request['name'],
                        'pickup': request['pickup'],
                        'destination': request['destination'],
                        'price': request['price'],
                        'date': 'Just now',
                        'status': 'Ongoing',
                      });
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Trip ${request['id']} accepted, head to pickup'),
                        backgroundColor: Pallete.black2,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // TRIPS TAB
  Widget _tripsTab() {
    return ListView(
      padding: const EdgeInsets.all(0),
      children: [
        const Text(
          'Your trips',
          style: TextStyle(fontWeight: FontWeight.w100),
        ),
        const SizedBox(height: 12),
        if (trips.isEmpty)
          Center(
            child: Text(
              'No trips yet',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          )
        else
          ...trips.map(
            (trip) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF21242A).withOpacity(0.4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Pallete.s),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          trip['name'],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      AppStatusChip(text: trip['status']),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _routeLine('assets/marker/marker-white.png', trip['pickup']),
                  const SizedBox(height: 6),
                  _routeLine(
                      'assets/marker/marker-orange.png', trip['destination']),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        trip['date'],
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      Text(
                        formatToKES(trip['price']),
                        style: const TextStyle(color: Pallete.color5),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // EARNINGS TAB
  Widget _earningsTab() {
    final List<Map<String, dynamic>> week = [
      {'day': 'Mon', 'value': 2800.0},
      {'day': 'Tue', 'value': 4100.0},
      {'day': 'Wed', 'value': 2400.0},
      {'day': 'Thu', 'value': 4900.0},
      {'day': 'Fri', 'value': 6000.0},
      {'day': 'Sat', 'value': 3700.0},
      {'day': 'Sun', 'value': 2600.0},
    ];
    final double max = week.fold(
        0, (value, item) => value > item['value'] ? value : item['value']);

    return ListView(
      padding: const EdgeInsets.all(0),
      children: [
        const Text(
          'This week',
          style: TextStyle(fontWeight: FontWeight.w100),
        ),
        const SizedBox(height: 12),
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
              Text(
                formatToKES(26500),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w200,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.trending_up_rounded,
                      size: 16, color: Color(0xFF35FE55)),
                  const SizedBox(width: 4),
                  Text(
                    '+12% vs last week',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Bar chart
        SizedBox(
          height: 160,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: week.map((item) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: 110.0 * ((item['value'] as double) / max),
                    width: 20,
                    decoration: BoxDecoration(
                      color: Pallete.color5.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['day'],
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),

        // Breakdown
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF21242A).withOpacity(0.4),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Pallete.s),
          ),
          child: Column(
            children: [
              _breakdownRow('Trip fares', formatToKES(22900)),
              _breakdownRow('Bonuses', formatToKES(1800)),
              _breakdownRow('Tips', formatToKES(1800)),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total'),
                  Text(
                    formatToKES(26500),
                    style: const TextStyle(color: Pallete.color5),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _breakdownRow(String label, String value) {
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

  Widget _routeLine(String marker, String address) {
    return Row(
      children: [
        Image.asset(marker, height: 18),
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

  Widget _actionButton(
      {required String text,
      required Color color,
      required Function()? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(text),
      ),
    );
  }
}
