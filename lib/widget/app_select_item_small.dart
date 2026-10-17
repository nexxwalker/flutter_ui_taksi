import 'package:flutter/material.dart';
import 'package:flutter_ui_taksi/widget/app_svg_icon.dart';
import 'package:latlong2/latlong.dart';

import '../config/pallete.dart';

class AppSelectItemSmall extends StatefulWidget {
  final List<Map<String, dynamic>> item;
  final Function(LatLng, String)? onTap;
  const AppSelectItemSmall({super.key, required this.item, this.onTap});

  @override
  State<AppSelectItemSmall> createState() => _AppSelectItemSmallState();
}

class _AppSelectItemSmallState extends State<AppSelectItemSmall> {
  // final List<Map<String, dynamic>> category = [
  //   {'id': 1, 'name': 'Soccer'},
  //   {'id': 2, 'name': 'Basketball', 'icon': 'image 4.png'},
  //   {'id': 3, 'name': 'Football', 'icon': 'image 2.png'},
  //   {'id': 4, 'name': 'Baseball', 'icon': 'baseball_26be 1.png'},
  //   {'id': 5, 'name': 'Tennis', 'icon': 'image 7.png'},
  //   {'id': 6, 'name': 'Volleyball', 'icon': 'image 1.png'},
  // ];

  int activeIds = 0;

  void toggleItemById(int id) {
    setState(() {
      activeIds = id;
    });

    if (widget.onTap != null) {
      final items = widget.item.firstWhere(
        (item) => item['id'] == id,
        orElse: () => {}, // Jika tidak ditemukan, kembalikan objek kosong
      );

      widget.onTap!(
        LatLng(items['position']['lat'], items['position']['lng']),
        items['address'],
      ); // Contoh callback dengan parameter dan return
      // print("Callback result: $result"); // Log hasil return
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: widget.item.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final item = widget.item[index];
          final isActive = activeIds == (item['id']); // Status aktif

          EdgeInsets margin = EdgeInsets.only(
            left: index == 0 ? 20 : 0,
            right: index == widget.item.length - 1 ? 20 : 0,
          );

          return GestureDetector(
            onTap: () => toggleItemById(item['id']),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              margin: margin,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Pallete.s),
                  gradient: LinearGradient(
                    colors: [
                      isActive
                          ? Pallete.s
                          : const Color(0xFF21242A).withOpacity(0.6),
                      isActive
                          ? Pallete.s
                          : const Color(0xFF21242A).withOpacity(0.6)
                    ], // Warna gradien
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    if (item['icon'] != null) ...[
                      AppSvgIcon(
                        '${item['icon']}',
                        width: 12,
                        height: 12,
                      ),
                    ],
                    if (item['icon'] != null) ...[
                      const SizedBox(width: 8),
                    ],
                    Text(
                      item['name'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
