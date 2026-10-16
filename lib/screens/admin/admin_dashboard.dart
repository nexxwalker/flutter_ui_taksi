import 'package:flutter/material.dart';
import 'package:flutter_ui_taksi/config/pallete.dart';
import 'package:flutter_ui_taksi/config/routes.dart';
import 'package:flutter_ui_taksi/utils/currency.dart';

import '../../widget/widget.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.all(20).copyWith(top: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Admin panel',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w100,
                          ),
                        ),
                        Text(
                          'Fleet overview for today',
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
                    Tab(text: 'Overview'),
                    Tab(text: 'Drivers'),
                    Tab(text: 'Rides'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: TabBarView(
                  children: [
                    const _OverviewTab(),
                    _DriversTab(),
                    const _RidesTab(),
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

// ---------------------------------------------------------------------------
// OVERVIEW
// ---------------------------------------------------------------------------
class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  static const List<Map<String, dynamic>> stats = [
    {
      'label': 'Rides today',
      'value': '148',
      'icon': Icons.route_rounded,
      'color': Color(0xFFFE6B35),
    },
    {
      'label': 'Active drivers',
      'value': '62',
      'icon': Icons.drive_eta_rounded,
      'color': Color(0xFF35FE55),
    },
    {
      'label': 'New clients',
      'value': '37',
      'icon': Icons.person_add_rounded,
      'color': Color(0xFF35DAFE),
    },
    {
      'label': 'Revenue today',
      'value': '48,600 KES',
      'icon': Icons.payments_rounded,
      'color': Color(0xFFFE3535),
    },
  ];

  static const List<Map<String, dynamic>> activity = [
    {
      'icon': Icons.check_circle_rounded,
      'title': 'Trip TK-2038 completed',
      'subtitle': 'Peter Hetfield • 600 KES',
      'time': '2m',
      'color': Color(0xFF35FE55),
    },
    {
      'icon': Icons.person_add_rounded,
      'title': 'New driver registered',
      'subtitle': 'Andi Wijaya • Toyota Avanza',
      'time': '18m',
      'color': Color(0xFF35DAFE),
    },
    {
      'icon': Icons.cancel_rounded,
      'title': 'Trip TK-2036 cancelled',
      'subtitle': 'Client cancelled after 4 min',
      'time': '34m',
      'color': Color(0xFFFE3535),
    },
    {
      'icon': Icons.star_rounded,
      'title': 'New 5 star rating',
      'subtitle': 'Peter Hetfield • Trip TK-2031',
      'time': '1h',
      'color': Color(0xFFFE6B35),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(0),
      children: [
        // Stats
        GridView.builder(
          padding: const EdgeInsets.all(0),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stats.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 1.7,
          ),
          itemBuilder: (context, index) {
            final item = stats[index];

            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: (item['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Pallete.s),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(item['icon'], color: item['color'], size: 22),
                  const Spacer(),
                  Text(
                    item['value'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item['label'],
                    style: Theme.of(context).textTheme.labelSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 24),

        // Live activity
        const Text(
          'Live activity',
          style: TextStyle(fontWeight: FontWeight.w100),
        ),
        const SizedBox(height: 12),
        ...activity.map(
          (item) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF21242A).withOpacity(0.4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Pallete.s),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item['icon'], color: item['color'], size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['title']),
                      Text(
                        item['subtitle'],
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
                Text(
                  item['time'],
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// DRIVERS
// ---------------------------------------------------------------------------
class _DriversTab extends StatefulWidget {
  @override
  State<_DriversTab> createState() => _DriversTabState();
}

class _DriversTabState extends State<_DriversTab>
    with AutomaticKeepAliveClientMixin {
  final List<Map<String, dynamic>> drivers = [
    {
      'name': 'Peter Hetfield',
      'vehicle': 'Hyundai Kona SUV',
      'plate': '5UMH719',
      'rating': 4.9,
      'status': 'Active',
    },
    {
      'name': 'Andi Wijaya',
      'vehicle': 'Toyota Avanza',
      'plate': 'KH 1821 OP',
      'rating': 4.7,
      'status': 'Pending',
    },
    {
      'name': 'Sinta Dewi',
      'vehicle': 'Honda Brio',
      'plate': 'KH 9034 RT',
      'rating': 4.8,
      'status': 'Pending',
    },
    {
      'name': 'Budi Santoso',
      'vehicle': 'Daihatsu Xenia',
      'plate': 'KH 4412 QW',
      'rating': 3.9,
      'status': 'Suspended',
    },
  ];

  void updateStatus(int index, String status) {
    setState(() {
      drivers[index]['status'] = status;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${drivers[index]['name']} is now $status'),
        backgroundColor: Pallete.black2,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ListView.builder(
      padding: const EdgeInsets.all(0),
      itemCount: drivers.length,
      itemBuilder: (context, index) {
        final driver = drivers[index];
        final String status = driver['status'];

        return Container(
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
                        Text(driver['name']),
                        Text(
                          '${driver['vehicle']} • ${driver['plate']}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                  AppStatusChip(text: status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 16, color: Pallete.color5),
                      const SizedBox(width: 4),
                      Text(
                        '${driver['rating']}',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                  if (status == 'Pending')
                    Row(
                      children: [
                        _driverAction(
                          text: 'REJECT',
                          color: const Color(0xFFFE3535),
                          onTap: () => updateStatus(index, 'Rejected'),
                        ),
                        const SizedBox(width: 8),
                        _driverAction(
                          text: 'APPROVE',
                          color: const Color(0xFF35FE55),
                          onTap: () => updateStatus(index, 'Active'),
                        ),
                      ],
                    )
                  else if (status == 'Active')
                    _driverAction(
                      text: 'SUSPEND',
                      color: const Color(0xFFFE3535),
                      onTap: () => updateStatus(index, 'Suspended'),
                    )
                  else if (status == 'Suspended')
                    _driverAction(
                      text: 'REINSTATE',
                      color: const Color(0xFF35FE55),
                      onTap: () => updateStatus(index, 'Active'),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _driverAction(
      {required String text,
      required Color color,
      required Function()? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color),
        ),
        child: Text(
          text,
          style: TextStyle(color: color, fontSize: 12),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// RIDES
// ---------------------------------------------------------------------------
class _RidesTab extends StatelessWidget {
  const _RidesTab();

  static const List<Map<String, dynamic>> rides = [
    {
      'id': 'TK-2043',
      'rider': 'Maya Lestari',
      'driver': 'Peter Hetfield',
      'pickup': 'Chaka Road, Nyeri',
      'destination': 'Kenyatta Avenue, Nyeri',
      'price': 350.0,
      'status': 'Ongoing',
    },
    {
      'id': 'TK-2042',
      'rider': 'Budi Santoso',
      'driver': 'Andi Wijaya',
      'pickup': 'Gakere Road, Nyeri',
      'destination': 'Nyeri County Referral Hospital',
      'price': 600.0,
      'status': 'Pending',
    },
    {
      'id': 'TK-2038',
      'rider': 'Rina Saputra',
      'driver': 'Peter Hetfield',
      'pickup': 'Kenyatta Avenue, Nyeri',
      'destination': 'Nyeri County Referral Hospital',
      'price': 600.0,
      'status': 'Completed',
    },
    {
      'id': 'TK-2036',
      'rider': 'Andi Wijaya',
      'driver': 'Sinta Dewi',
      'pickup': 'Nyeri County Referral Hospital',
      'destination': 'Gakere Road, Nyeri',
      'price': 350.0,
      'status': 'Cancelled',
    },
    {
      'id': 'TK-2031',
      'rider': 'Sinta Dewi',
      'driver': 'Peter Hetfield',
      'pickup': 'Gakere Road, Nyeri',
      'destination': 'Chaka Road, Nyeri',
      'price': 350.0,
      'status': 'Completed',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(0),
      itemCount: rides.length,
      itemBuilder: (context, index) {
        final ride = rides[index];

        return Container(
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
                  Text(
                    ride['id'],
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  AppStatusChip(text: ride['status']),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Image.asset('assets/marker/marker-white.png', height: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ride['pickup'],
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Image.asset('assets/marker/marker-orange.png', height: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ride['destination'],
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${ride['rider']} → ${ride['driver']}',
                      style: Theme.of(context).textTheme.labelSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    formatToKES(ride['price']),
                    style: const TextStyle(color: Pallete.color5),
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
