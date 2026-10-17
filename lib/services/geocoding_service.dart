import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Reverse geocodes [point] with Nominatim, the OpenStreetMap geocoder.
/// It needs no API key, so it works from the web build as well.
///
/// Returns `null` when the service is unreachable or has no useful street for
/// the point; callers should fall back to a generic label.
Future<String?> reverseGeocode(LatLng point) async {
  final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
    'format': 'jsonv2',
    'lat': point.latitude.toStringAsFixed(6),
    'lon': point.longitude.toStringAsFixed(6),
    'zoom': '18',
  });

  try {
    final response = await http.get(uri);
    if (response.statusCode != 200) return null;

    final data = json.decode(response.body);
    if (data is! Map<String, dynamic>) return null;

    final address = data['address'];
    if (address is Map<String, dynamic>) {
      for (final key in const [
        'road',
        'pedestrian',
        'footway',
        'residential',
        'suburb',
        'town',
      ]) {
        final value = address[key];
        if (value is String && value.isNotEmpty) return value;
      }
    }

    final displayName = data['display_name'];
    return displayName is String && displayName.isNotEmpty ? displayName : null;
  } catch (_) {
    // Best-effort label only: a network failure must not break pin dragging.
    return null;
  }
}
