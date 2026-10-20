import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_ui_taksi/config/pallete.dart';
import 'package:flutter_ui_taksi/config/routes.dart';
import 'package:flutter_ui_taksi/screens/pick_up/components/map_component.dart';
import 'package:flutter_ui_taksi/services/api_service.dart';
import 'package:flutter_ui_taksi/utils/color.dart';
import 'package:flutter_ui_taksi/utils/currency.dart';
import 'package:latlong2/latlong.dart';

import '../widget/widget.dart';

class HomePage extends StatelessWidget {
  final ApiService? api;

  /// Overridable so widget tests can render the map without network access.
  final TileProvider? tileProvider;

  const HomePage({super.key, this.api, this.tileProvider});

  @override
  Widget build(BuildContext context) {
    final api = this.api ?? ApiService.forWeb();
    final List<Map<String, dynamic>> items = [
      {
        'title': 'Need a ride?',
        'subtitle': 'Find me a ride now',
        'color': 'FE6B35',
        'image': 'assets/car.png',
        'route': Routes.pickUp,
      },
      {
        'title': 'Need groceries?',
        'subtitle': 'Buy me Groceries!',
        'color': '35FE55',
        'image': 'assets/fruits.png',
        'route': Routes.groceries,
      },
      {
        'title': 'Need a delivery?',
        'subtitle': 'Let’s deliver!',
        'color': '35DAFE',
        'image': 'assets/motorcycle.png',
        'route': Routes.delivery,
      },
      {
        'title': 'Hmm... Hungry?!',
        'subtitle': 'YUM \nYUM',
        'color': 'FE3535',
        'image': 'assets/pizza.png',
        'route': Routes.food,
      },
    ];

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
                  onTap: () => Navigator.pushNamed(context, Routes.roles),
                  icon: const AppSvgIcon('person'),
                ),
                const SizedBox(width: 16),
                const AppButtonIcon(
                  icon: AppSvgIcon('notifications'),
                  isNotify: true,
                ),
                const SizedBox(width: 14),
                const Expanded(
                    child: AppTextSearch(
                  hintText: 'Where to ..?',
                  suffixIcon: AppSvgIcon(
                    'search',
                    width: 17,
                    height: 17,
                  ),
                ))
              ],
            ),
            const SizedBox(height: 12),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(0),
                children: [
                  // Title
                  const Text(
                    'Good Evening Peyman',
                    style: TextStyle(fontWeight: FontWeight.w100),
                  ),
                  const SizedBox(height: 12),

                  // Money
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
                              formatToKES(5264),
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.w200),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'IS YOUR CURRENT BALANCE',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w200),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              '+ ADD TO BALANCE',
                              style: TextStyle(
                                  color: Pallete.color5,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w200),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Recomended
                  GridView.builder(
                    padding: const EdgeInsets.all(0),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 1.6,
                    ),
                    itemBuilder: (context, index) {
                      final item = items[index];

                      return AppRecomendedCard(
                        item: item,
                        onTap: () => Navigator.pushNamed(
                          context,
                          item['route'],
                          arguments: {'api': api},
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Pay Banner
                  const AppBanner(),

                  const SizedBox(height: 24),

                  const Text(
                    'Active services around you',
                    style: TextStyle(fontWeight: FontWeight.w100),
                  ),
                  const SizedBox(height: 12),

                  // Maps
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: MapSmallComponent(tileProvider: tileProvider),
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

class AppBanner extends StatelessWidget {
  const AppBanner({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 10, bottom: 10),
          height: 90,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: Pallete.gradientColor, // Warna gradien
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(23), // Membulatkan sudut
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/phone.png', height: 120),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'PAY IN A BLINK!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 7),
                Text('ACTIVATE TAKSI CRED NOW!'),
              ],
            ),
          ],
        )
      ],
    );
  }
}

class MapSmallComponent extends StatefulWidget {
  final TileProvider? tileProvider;

  const MapSmallComponent({super.key, this.tileProvider});

  @override
  State<MapSmallComponent> createState() => _MapSmallComponentState();
}

class _MapSmallComponentState extends State<MapSmallComponent> {
  static const LatLng _initialPosition =
      LatLng(-0.4197, 36.9476); // Nyeri town centre

  static const double _iconSize = 32;

  final List<LatLng> _markerPositions = [];

  @override
  void initState() {
    super.initState();
    _addMarkersAround(_initialPosition);
  }

  void _addMarkersAround(LatLng center) {
    const double maxOffset =
        0.006; // Jarak maksimum offset untuk penyebaran marker
    final Random random = Random();

    for (int i = 0; i < 16; i++) {
      // Menghasilkan offset acak dalam rentang yang lebih besar untuk membuat posisi marker lebih tersebar
      double randomLat =
          center.latitude + (random.nextDouble() * maxOffset * 2) - maxOffset;
      double randomLng =
          center.longitude + (random.nextDouble() * maxOffset * 2) - maxOffset;

      _markerPositions.add(LatLng(randomLat, randomLng));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 159,
      child: FlutterMap(
        options: const MapOptions(
          initialCenter: _initialPosition,
          initialZoom: 15,
          minZoom: 3,
          maxZoom: 19,
          backgroundColor: Pallete.black2,
          // Rotation would rotate markers away from the pin anchor.
          interactionOptions: InteractionOptions(
            flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: MapComponent.tileUrlTemplate,
            userAgentPackageName: 'flutter_ui_taksi',
            maxNativeZoom: 19,
            tileProvider: widget.tileProvider,
          ),
          CircleLayer(
            circles: [
              CircleMarker(
                point: _initialPosition,
                radius: 100, // Radius dalam meter
                useRadiusInMeter: true,
                color: Colors.orange.withOpacity(0.3),
                borderColor: Colors.orange,
                borderStrokeWidth: 2,
              ),
            ],
          ),
          MarkerLayer(
            markers: [
              for (int i = 0; i < _markerPositions.length; i++)
                Marker(
                  point: _markerPositions[i],
                  width: _iconSize,
                  height: _iconSize,
                  child: Image.asset(
                    i % 2 == 0
                        ? 'assets/marker/marker-orange.png'
                        : 'assets/marker/marker-green.png',
                    width: _iconSize,
                    height: _iconSize,
                    filterQuality: FilterQuality.high,
                  ),
                ),
            ],
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              color: Pallete.black2.withOpacity(0.7),
              child: const Text(
                MapComponent.attribution,
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: TextStyle(fontSize: 10, color: Pallete.grey1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppRecomendedCard extends StatelessWidget {
  const AppRecomendedCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  final Map<String, dynamic> item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              item['title'],
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(height: 4),
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 20, left: 60, right: 27),
                margin: const EdgeInsets.only(left: 20),
                height: 82,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: hexToColor(item['color']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Pallete.s),
                ),
              ),
              Positioned(
                left: 0,
                top: 10,
                child: Row(
                  children: [
                    Image.asset(
                      item['image'],
                      fit: BoxFit.cover,
                      height: 62,
                    ),
                    const SizedBox(width: 20),
                    SizedBox(width: 70, child: Text(item['subtitle'])),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
