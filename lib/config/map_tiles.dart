import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

/// Key-free OpenStreetMap raster tiles, filtered into the dark basemap the
/// original app design used. No tile key and no extra tile host are involved.
class MapTiles {
  const MapTiles._();

  static const String urlTemplate =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  static const String attribution = '© OpenStreetMap contributors';

  /// Inverts the light basemap, rotates the hue back by 180° (so rivers stay
  /// blue and parks green), lifts the brightness and pulls 30% of the
  /// saturation out. Street names end up light on a near-black map, which is
  /// how the rest of the dark UI reads.
  static const ColorFilter darkFilter = ColorFilter.matrix(<double>[
    0.333153, -1.19806, -0.120697, 0, 266.688, //
    -0.356767, -0.508136, -0.120697, 0, 266.688,
    -0.356767, -1.19806, 0.569223, 0, 266.688,
    0, 0, 0, 1, 0,
  ]);

  /// The tile layer with [darkFilter] applied. Pins, routes and the attribution
  /// are separate layers, so they keep their true colours.
  static Widget darkLayer({TileProvider? tileProvider}) {
    return ColorFiltered(
      colorFilter: darkFilter,
      child: TileLayer(
        urlTemplate: urlTemplate,
        userAgentPackageName: 'flutter_ui_taksi',
        maxNativeZoom: 19,
        tileProvider: tileProvider,
      ),
    );
  }
}
