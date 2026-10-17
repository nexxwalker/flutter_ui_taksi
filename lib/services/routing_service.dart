import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Road geometry between [origin] and [destination] from the public OSRM demo
/// server. OSRM needs no API key, so nothing secret is shipped to the browser.
Future<List<LatLng>> getRoute(LatLng origin, LatLng destination) async {
  final uri = Uri.parse(
    'https://router.project-osrm.org/route/v1/driving/'
    '${origin.longitude},${origin.latitude};'
    '${destination.longitude},${destination.latitude}'
    '?overview=full&geometries=polyline',
  );

  final response = await http.get(uri);
  if (response.statusCode != 200) {
    throw Exception('Routing request failed with ${response.statusCode}');
  }

  final data = json.decode(response.body);
  if (data is! Map<String, dynamic>) {
    throw Exception('Routing returned an unexpected payload');
  }

  final routes = data['routes'];
  if (routes is! List || routes.isEmpty) {
    throw Exception('No route found between the two points');
  }

  final geometry = (routes.first as Map<String, dynamic>)['geometry'];
  if (geometry is! String) {
    throw Exception('Routing response contained no geometry');
  }

  return decodePolyline(geometry);
}

/// Decodes an encoded polyline (the format used by OSRM and the Google
/// Directions API) into coordinates.
List<LatLng> decodePolyline(String encoded) {
  final List<LatLng> polyline = [];
  int index = 0, len = encoded.length;
  int lat = 0, lng = 0;

  while (index < len) {
    int b, shift = 0, result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    final int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lat += dlat;

    shift = 0;
    result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    final int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lng += dlng;

    polyline.add(LatLng(lat / 1E5, lng / 1E5));
  }
  return polyline;
}
