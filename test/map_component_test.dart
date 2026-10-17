import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_taksi/screens/pick_up/components/map_component.dart';

/// 1x1 transparent PNG, so tiles resolve without touching the network.
final Uint8List _transparentPixel = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
  0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
]);

class _MemoryTileProvider extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      MemoryImage(_transparentPixel);
}

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(width: 400, height: 400, child: child),
    ),
  );
}

bool _isAsset(Widget widget, String asset) =>
    widget is Image &&
    widget.image is AssetImage &&
    (widget.image as AssetImage).assetName == asset;

void main() {
  testWidgets('map renders OpenStreetMap tiles with no API key',
      (tester) async {
    await tester.pumpWidget(
      _wrap(MapComponent(tileProvider: _MemoryTileProvider())),
    );
    await tester.pump(const Duration(milliseconds: 100));

    final tileLayer = tester.widget<TileLayer>(find.byType(TileLayer));
    expect(tileLayer.urlTemplate, MapComponent.tileUrlTemplate);
    expect(tileLayer.urlTemplate, contains('tile.openstreetmap.org'));
    expect(tileLayer.urlTemplate, isNot(contains('key')));
    expect(find.text(MapComponent.attribution), findsOneWidget);
  });

  testWidgets('pins added through the shared key are drawn on the map',
      (tester) async {
    await tester.pumpWidget(
      _wrap(MapComponent(
        key: MapComponent.mapComponentKey,
        tileProvider: _MemoryTileProvider(),
      )),
    );
    await tester.pump(const Duration(milliseconds: 100));

    MapComponent.mapComponentKey.currentState!.addMarker();
    await tester.pump();

    expect(
      find.byWidgetPredicate(
        (widget) => _isAsset(widget, 'assets/marker/marker-pin-white.png'),
      ),
      findsOneWidget,
    );

    MapComponent.mapComponentKey.currentState!.addDraggableMarker();
    await tester.pump();

    expect(
      find.byWidgetPredicate(
        (widget) => _isAsset(widget, 'assets/marker/marker-pin-orange.png'),
      ),
      findsOneWidget,
    );
    // The destination pin is the draggable one.
    expect(
      find.ancestor(
        of: find.byWidgetPredicate(
          (widget) => _isAsset(widget, 'assets/marker/marker-pin-orange.png'),
        ),
        matching: find.byType(GestureDetector),
      ),
      findsWidgets,
    );
  });
}
