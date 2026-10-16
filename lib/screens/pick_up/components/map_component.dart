import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_ui_taksi/config/pallete.dart';
import 'package:flutter_ui_taksi/services/google_map_service.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../utils/marker.dart';

class MapComponent extends StatefulWidget {
  final Function(LatLng, String)? onDragMyPosition;
  final Function(LatLng, String)? onDragDestinatePosition;
  const MapComponent(
      {super.key, this.onDragMyPosition, this.onDragDestinatePosition});

  // Menambahkan GlobalKey untuk mengakses state widget ini dari luar
  // ignore: library_private_types_in_public_api
  static final GlobalKey<_MapComponentState> mapComponentKey =
      GlobalKey<_MapComponentState>();

  @override
  State<MapComponent> createState() => _MapComponentState();
}

class _MapComponentState extends State<MapComponent> {
  late GoogleMapController mapController;
  final LatLng _initialMarkerPosition = const LatLng(-0.4197, 36.9476); // Nyeri town centre

  Set<Marker> _markers = {};
  String? _mapStyle;
  bool myLocationInit = false;
  double iconSize = 70;
  double _mapRotation = 0.0;

  // Tambahkan variabel polyline
  Set<Polyline> _polylines = {};

  Future<List<LatLng>> drawRoute(LatLng origin, LatLng destination) async {
    final routeCoordinates = await getRoute(origin, destination);

    setState(() {
      _polylines.clear();

      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          color: Pallete.color5, // Warna rute
          width: 3, // Ketebalan garis
          points: routeCoordinates, // Koordinat jalur
        ),
      );
    });

    // Pindahkan kamera agar mencakup jalur
    // mapController.animateCamera(
    //   CameraUpdate.newLatLngBounds(
    //     LatLngBounds(
    //       southwest: routeCoordinates.first,
    //       northeast: routeCoordinates.last,
    //     ),
    //     50, // Padding
    //   ),
    // );
    // ignore: empty_catches
    return routeCoordinates;
  }

  void _updateMarkerRotation(double newRotation) {
    setState(() {
      _markers = _markers.map((marker) {
        if (marker.markerId == const MarkerId('riderMarker')) {
          // Sesuaikan rotasi marker
          return marker.copyWith(rotationParam: 360 - newRotation + 130);
        }
        return marker;
      }).toSet();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
  }

  Future<void> _loadMapStyle() async {
    _mapStyle = await DefaultAssetBundle.of(context)
        .loadString('assets/map_style.json');
    setState(() {});
  }

  void addMarker({double iconSize = 100.0}) async {
    final BitmapDescriptor customIcon = await getResizedIcon(
      'assets/marker/marker-pin-white.png', // Path gambar ikon
      iconSize, // Ukuran ikon
    );

    setState(() {
      myLocationInit = true;
      _markers.add(
        Marker(
          anchor: const Offset(0.5, 0.5),
          markerId: const MarkerId('myLocationMarker'),
          position: _initialMarkerPosition,
          icon: customIcon,
        ),
      );
    });

    changeMarkerPosition(_initialMarkerPosition);

    // Pindahkan kamera ke posisi baru
    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(_initialMarkerPosition, 15.0),
    );
  }

  void addDraggableMarker() async {
    final BitmapDescriptor customIcon = await getResizedIcon(
      'assets/marker/marker-pin-orange.png', // Path gambar ikon
      100, // Ukuran ikon
    );

    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId('destinationMarker'),
          position: _initialMarkerPosition,
          anchor: const Offset(0.5, 0.5),

          icon: customIcon,
          draggable: true, // Aktifkan dragging
          onDragEnd: (newPositions) {
            setState(() {
              // Update posisi marker tanpa menambah marker baru
              _markers = _markers.map((marker) {
                if (marker.markerId == const MarkerId('destinationMarker')) {
                  // Update posisi marker yang digerakkan
                  return marker.copyWith(positionParam: newPositions);
                }
                return marker;
              }).toSet();
            });

            // Ambil informasi dari koordinat baru
            placemarkFromCoordinates(
                    newPositions.latitude, newPositions.longitude)
                .then((placemarks) {
              var output = 'No results found.';
              if (placemarks.isNotEmpty) {
                output = placemarks[0].street ?? 'Street not found';
              }

              if (widget.onDragDestinatePosition != null) {
                widget.onDragDestinatePosition!(newPositions, output);
              }
            });
          },
        ),
      );
    });

    // Pindahkan kamera ke posisi baru
    _moveCameraWithOffset(_initialMarkerPosition, zoom: 15, offset: -0.007);
  }

  void addRiderMarker() async {
    final BitmapDescriptor customIcon = await getResizedIcon(
      'assets/marker/car-icon.png', // Path gambar ikon
      80, // Ukuran ikon
    );

    LatLng position = const LatLng(-0.4102, 36.9554); // Driver approaching from Nairobi Road

    setState(() {
      _markers.add(
        Marker(
            markerId: const MarkerId('riderMarker'),
            position: position,
            icon: customIcon,
            anchor: const Offset(0.5, 0.5),
            rotation: 280),
      );
    });

    _moveCameraWithOffset(position, zoom: 15, offset: -0.007);

    if (myLocation != null) {
      final route = await drawRoute(position, myLocation!);
      moveMarkerAlongRoute(
          route, const MarkerId('riderMarker')); // Gerakkan marker
    }
  }

  Future<void> moveMarkerAlongRoute(
      List<LatLng> route, MarkerId markerId) async {
    const int duration = 120; // Durasi total animasi dalam detik (2 menit)
    if (route.isEmpty || route.length < 2) return;

    double totalDistance = 0.0;
    for (int i = 0; i < route.length - 1; i++) {
      totalDistance += _calculateDistance(route[i], route[i + 1]);
    }

    for (int i = 0; i < route.length - 1; i++) {
      LatLng start = route[i];
      LatLng end = route[i + 1];

      double segmentDistance = _calculateDistance(start, end);
      int segmentDuration =
          ((segmentDistance / totalDistance) * duration * 1000).toInt();
      final int steps = segmentDuration ~/ 16; // 16ms per frame (60 FPS)

      // Hitung rotasi berdasarkan arah
      double rotation = _calculateBearing(start, end);

      for (int step = 0; step < steps; step++) {
        final double t = step / steps;
        final LatLng interpolatedPosition = LatLng(
          start.latitude + (end.latitude - start.latitude) * t,
          start.longitude + (end.longitude - start.longitude) * t,
        );

        // Update posisi marker dan polyline
        setState(() {
          _markers = _markers.map((marker) {
            if (marker.markerId == markerId) {
              return marker.copyWith(
                positionParam: interpolatedPosition,
                rotationParam: rotation,
              );
            }
            return marker;
          }).toSet();

          // Perbarui polyline
          _polylines = _polylines.map((polyline) {
            if (polyline.polylineId.value == 'route') {
              // Perbarui rute dengan sisa jalur
              final remainingRoute = route.sublist(i);
              return polyline.copyWith(pointsParam: remainingRoute);
            }
            return polyline;
          }).toSet();
        });

        await Future.delayed(const Duration(milliseconds: 16));
      }
    }

    // Pastikan marker berada di titik akhir
    setState(() {
      _markers = _markers.map((marker) {
        if (marker.markerId == markerId) {
          return marker.copyWith(
            positionParam: route.last,
            rotationParam:
                _calculateBearing(route[route.length - 2], route.last),
          );
        }
        return marker;
      }).toSet();

      // Hapus rute (opsional)
      _polylines = _polylines.map((polyline) {
        if (polyline.polylineId.value == 'route') {
          return polyline.copyWith(pointsParam: []);
        }
        return polyline;
      }).toSet();
    });
  }

  double _calculateBearing(LatLng start, LatLng end) {
    final double startLat = _degreesToRadians(start.latitude);
    final double startLng = _degreesToRadians(start.longitude);
    final double endLat = _degreesToRadians(end.latitude);
    final double endLng = _degreesToRadians(end.longitude);

    final double dLng = endLng - startLng;
    final double y = sin(dLng) * cos(endLat);
    final double x =
        cos(startLat) * sin(endLat) - sin(startLat) * cos(endLat) * cos(dLng);
    final double bearing = atan2(y, x);

    return (_radiansToDegrees(bearing) + 360) % 360;
  }

  double _radiansToDegrees(double radians) {
    return radians * 50 / pi;
  }

  double _calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371; // Radius bumi dalam kilometer
    final double dLat = _degreesToRadians(end.latitude - start.latitude);
    final double dLng = _degreesToRadians(end.longitude - start.longitude);

    final double a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_degreesToRadians(start.latitude)) *
            cos(_degreesToRadians(end.latitude)) *
            (sin(dLng / 2) * sin(dLng / 2));
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 50;
  }

  void changeMarkerPosition(LatLng newPosition) async {
    if (!myLocationInit) {
      addMarker();
      return;
    }

    final BitmapDescriptor customIcon = await getResizedIcon(
      'assets/marker/marker-pin-white.png', // Path gambar ikon
      iconSize, // Ukuran ikon
    );
    setState(() {
      // Buat marker baru dengan posisi yang diperbarui
      final updatedMarker = Marker(
        markerId: const MarkerId('myLocationMarker'),
        position: newPosition,
        anchor: const Offset(0.5, 0.5),
        icon: customIcon, // Gunakan ikon yang sama
        draggable: true, // Pastikan draggable tetap aktif jika dibutuhkan
        onDragEnd: (newPositions) {
          setState(() {
            // Update posisi marker tanpa menambah marker baru
            _markers = _markers.map((marker) {
              if (marker.markerId == const MarkerId('myLocationMarker')) {
                // Update posisi marker yang digerakkan
                return marker.copyWith(positionParam: newPositions);
              }
              return marker;
            }).toSet();
          });

          // Ambil informasi dari koordinat baru
          placemarkFromCoordinates(
                  newPositions.latitude, newPositions.longitude)
              .then((placemarks) {
            var output = 'No results found.';
            if (placemarks.isNotEmpty) {
              output = placemarks[0].street ?? 'Street not found';
            }
            if (widget.onDragMyPosition != null) {
              widget.onDragMyPosition!(newPositions, output);
            }
          });
        },
      );

      // Hapus marker lama dan tambahkan yang baru
      _markers.removeWhere(
          (marker) => marker.markerId == const MarkerId('myLocationMarker'));
      _markers.add(updatedMarker);

      // Pindahkan kamera ke posisi baru
      _moveCameraWithOffset(newPosition);
    });
  }

  void _moveCameraWithOffset(LatLng newPosition,
      {double zoom = 18, double offset = -0.0007}) {
    // Hitung offset berdasarkan latitude
    final LatLng adjustedPosition = LatLng(
      newPosition.latitude + offset, // Tambahkan offset ke latitude
      newPosition.longitude, // Longitude tetap
    );

    // Animasi kamera ke posisi yang disesuaikan
    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(adjustedPosition, zoom),
    );
  }

  late final LatLng? myLocation;
  late final LatLng? myDestination;

  void pinMarker(String markerId) async {
    final BitmapDescriptor customIcon = await getResizedIcon(
      markerId == 'myLocationMarker'
          ? 'assets/marker/marker-white.png'
          : 'assets/marker/marker-orange.png', // Path gambar ikon
      100, // Ukuran ikon
    );

    setState(() {
      final position = _markers
          .firstWhere(
            (marker) => marker.markerId == MarkerId(markerId),
          )
          .position;
      final updatedMarker = Marker(
          markerId: MarkerId(markerId),
          icon: customIcon,
          draggable: false,
          anchor: const Offset(0.5, 0.5),
          position: position);

      _markers.removeWhere((marker) => marker.markerId == MarkerId(markerId));
      _markers.add(updatedMarker);

      if (markerId == 'myLocationMarker') {
        myLocation = position;
      } else {
        myDestination = position;
      }

      _moveCameraWithOffset(position);
    });

    if (myLocation != null && myDestination != null) {
      drawRoute(myLocation!, myDestination!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _initialMarkerPosition,
          zoom: 15.0,
        ),
        style: _mapStyle,
        markers: _markers,
        polylines: _polylines,
        onCameraMove: (CameraPosition position) {
          setState(() {
            _mapRotation = position.bearing; // Simpan rotasi
            _updateMarkerRotation(_mapRotation); // Perbarui marker
          });
        },
      ),
    );
  }
}
