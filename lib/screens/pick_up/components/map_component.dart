import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_ui_taksi/config/pallete.dart';
import 'package:flutter_ui_taksi/services/geocoding_service.dart';
import 'package:flutter_ui_taksi/services/routing_service.dart';
import 'package:latlong2/latlong.dart';

/// A single pin drawn on the map. Mutable so drags and the rider animation can
/// move it in place.
class _MapPin {
  _MapPin({
    required this.point,
    required this.asset,
    required this.size,
    this.rotation = 0,
    this.draggable = false,
  });

  LatLng point;
  final String asset;
  final double size;
  double rotation;
  bool draggable;
}

/// OpenStreetMap-backed map. Raster tiles come straight from
/// `tile.openstreetmap.org`, which serves them without any API key, so the web
/// bundle carries no credential that could be scraped from it.
class MapComponent extends StatefulWidget {
  final Function(LatLng, String)? onDragMyPosition;
  final Function(LatLng, String)? onDragDestinatePosition;

  /// Overridable so widget tests can render tiles without network access.
  final TileProvider? tileProvider;

  const MapComponent({
    super.key,
    this.onDragMyPosition,
    this.onDragDestinatePosition,
    this.tileProvider,
  });

  /// Required attribution for using OpenStreetMap tiles.
  static const String attribution = '© OpenStreetMap contributors';

  static const String tileUrlTemplate =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  // GlobalKey so the pick up screen can drive the map from outside.
  // ignore: library_private_types_in_public_api
  static final GlobalKey<_MapComponentState> mapComponentKey =
      GlobalKey<_MapComponentState>();

  @override
  State<MapComponent> createState() => _MapComponentState();
}

class _MapComponentState extends State<MapComponent> {
  static const LatLng _initialMarkerPosition =
      LatLng(-0.4197, 36.9476); // Nyeri town centre
  static const LatLng _riderStart =
      LatLng(-0.4102, 36.9554); // approaching from Nairobi Road

  static const String _myLocationId = 'myLocationMarker';
  static const String _destinationId = 'destinationMarker';
  static const String _riderId = 'riderMarker';

  final MapController _mapController = MapController();
  final Map<String, _MapPin> _pins = {};
  List<LatLng> _route = const [];
  bool _mapReady = false;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _moveCamera(LatLng center, {double zoom = 15, double latOffset = 0}) {
    if (!_mapReady) return;
    _mapController.move(
      LatLng(center.latitude + latOffset, center.longitude),
      zoom,
    );
  }

  /// Puts the "my location" pin on the map at the town centre.
  void addMarker() {
    setState(() {
      _pins[_myLocationId] = _MapPin(
        point: _initialMarkerPosition,
        asset: 'assets/marker/marker-pin-white.png',
        size: 70,
      );
    });
    _moveCamera(_initialMarkerPosition, latOffset: -0.0007);
  }

  /// Puts a draggable destination pin on the map.
  void addDraggableMarker() {
    setState(() {
      _pins[_destinationId] = _MapPin(
        point: _initialMarkerPosition,
        asset: 'assets/marker/marker-pin-orange.png',
        size: 100,
        draggable: true,
      );
    });
    _moveCamera(_initialMarkerPosition, latOffset: -0.007);
  }

  /// Places the approaching rider and animates it to [myLocation] when known.
  Future<void> addRiderMarker() async {
    setState(() {
      _pins[_riderId] = _MapPin(
        point: _riderStart,
        asset: 'assets/marker/car-icon.png',
        size: 80,
        rotation: 280,
      );
    });
    _moveCamera(_riderStart, latOffset: -0.007);

    final LatLng? myLocation = _pins[_myLocationId]?.point;
    if (myLocation == null) return;

    try {
      final route = await drawRoute(_riderStart, myLocation);
      await moveMarkerAlongRoute(route, _riderId);
    } catch (error) {
      // The rider simply stays parked when routing is unavailable.
      debugPrint('Rider route unavailable: $error');
    }
  }

  /// Moves the "my location" pin, or adds it when it is not on the map yet.
  void changeMarkerPosition(LatLng newPosition) {
    final pin = _pins[_myLocationId];
    if (pin == null) {
      addMarker();
      return;
    }

    setState(() => pin.point = newPosition);
    _moveCamera(newPosition, latOffset: -0.0007);
  }

  /// Freezes the dragged pin in place and draws the route once both pin types
  /// are known.
  void pinMarker(String markerId) {
    final pin = _pins[markerId];
    if (pin == null) return;

    setState(() => pin.draggable = false);
    _moveCamera(pin.point, latOffset: -0.0007);

    final LatLng? myLocation = _pins[_myLocationId]?.point;
    final LatLng? destination = _pins[_destinationId]?.point;
    if (myLocation != null && destination != null) {
      drawRoute(myLocation, destination);
    }
  }

  Future<List<LatLng>> drawRoute(LatLng origin, LatLng destination) async {
    final route = await getRoute(origin, destination);
    if (!mounted) return route;

    setState(() => _route = route);
    return route;
  }

  void _dragPin(String markerId, Offset delta) {
    final pin = _pins[markerId];
    if (pin == null || !_mapReady) return;

    final camera = _mapController.camera;
    final screenPoint = camera.latLngToScreenPoint(pin.point);
    final moved = camera.pointToLatLng(
      screenPoint + Point<double>(delta.dx, delta.dy),
    );

    setState(() => pin.point = moved);
  }

  Future<void> _releasePin(String markerId) async {
    final pin = _pins[markerId];
    if (pin == null) return;

    final label = await reverseGeocode(pin.point) ?? 'Nyeri, Kenya';
    if (!mounted) return;

    if (markerId == _myLocationId) {
      widget.onDragMyPosition?.call(pin.point, label);
    } else {
      widget.onDragDestinatePosition?.call(pin.point, label);
    }
  }

  /// Animates a pin along [route], keeping its heading in step with the road.
  Future<void> moveMarkerAlongRoute(
    List<LatLng> route,
    String markerId, {
    Duration duration = const Duration(seconds: 120),
  }) async {
    final pin = _pins[markerId];
    if (pin == null || route.length < 2) return;

    final legs = <_RouteLeg>[];
    double totalDistance = 0;
    for (var i = 0; i < route.length - 1; i++) {
      final distance = _distanceKm(route[i], route[i + 1]);
      totalDistance += distance;
      legs.add(_RouteLeg(
        start: route[i],
        end: route[i + 1],
        distance: distance,
        bearing: _bearing(route[i], route[i + 1]),
      ));
    }
    if (totalDistance == 0) return;

    for (final leg in legs) {
      final segment = duration.inMilliseconds * (leg.distance / totalDistance);
      final steps = max(1, segment ~/ 16); // ~60 FPS

      for (var step = 0; step < steps; step++) {
        if (!mounted) return;
        final t = step / steps;
        setState(() {
          pin.point = LatLng(
            leg.start.latitude + (leg.end.latitude - leg.start.latitude) * t,
            leg.start.longitude + (leg.end.longitude - leg.start.longitude) * t,
          );
          pin.rotation = leg.bearing;
        });
        await Future.delayed(const Duration(milliseconds: 16));
      }
    }

    if (!mounted) return;
    setState(() {
      pin.point = route.last;
      if (legs.isNotEmpty) pin.rotation = legs.last.bearing;
    });
  }

  double _distanceKm(LatLng start, LatLng end) {
    const double earthRadiusKm = 6371;
    final dLat = _toRadians(end.latitude - start.latitude);
    final dLng = _toRadians(end.longitude - start.longitude);
    final a = pow(sin(dLat / 2), 2) +
        cos(_toRadians(start.latitude)) *
            cos(_toRadians(end.latitude)) *
            pow(sin(dLng / 2), 2);
    return earthRadiusKm * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _bearing(LatLng start, LatLng end) {
    final startLat = _toRadians(start.latitude);
    final endLat = _toRadians(end.latitude);
    final dLng = _toRadians(end.longitude - start.longitude);
    final y = sin(dLng) * cos(endLat);
    final x = cos(startLat) * sin(endLat) -
        sin(startLat) * cos(endLat) * cos(dLng);
    return (_toDegrees(atan2(y, x)) + 360) % 360;
  }

  double _toRadians(double degrees) => degrees * pi / 180;

  double _toDegrees(double radians) => radians * 180 / pi;

  Marker _buildMarker(String markerId, _MapPin pin) {
    final image = Image.asset(
      pin.asset,
      width: pin.size,
      height: pin.size,
      filterQuality: FilterQuality.high,
    );
    final icon = pin.rotation == 0
        ? image
        : Transform.rotate(angle: _toRadians(pin.rotation), child: image);

    return Marker(
      point: pin.point,
      width: pin.size,
      height: pin.size,
      child: pin.draggable
          ? GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (details) => _dragPin(markerId, details.delta),
              onPanEnd: (_) => _releasePin(markerId),
              child: icon,
            )
          : icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _initialMarkerPosition,
        initialZoom: 15,
        minZoom: 3,
        maxZoom: 19,
        backgroundColor: Pallete.black2,
        // Rotation would rotate markers away from the pin anchor; disable it.
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
        onMapReady: () => setState(() => _mapReady = true),
      ),
      children: [
        TileLayer(
          urlTemplate: MapComponent.tileUrlTemplate,
          userAgentPackageName: 'flutter_ui_taksi',
          maxNativeZoom: 19,
          tileProvider: widget.tileProvider,
        ),
        if (_route.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _route,
                color: Pallete.color5,
                strokeWidth: 3,
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            for (final entry in _pins.entries)
              _buildMarker(entry.key, entry.value),
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
    );
  }
}

class _RouteLeg {
  _RouteLeg({
    required this.start,
    required this.end,
    required this.distance,
    required this.bearing,
  });

  final LatLng start;
  final LatLng end;
  final double distance;
  final double bearing;
}
