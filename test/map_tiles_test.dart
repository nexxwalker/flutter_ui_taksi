import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_taksi/config/map_tiles.dart';

void main() {
  testWidgets('dark filter turns a light surface into dark pixels',
      (tester) async {
    final boundaryKey = GlobalKey();

    await tester.pumpWidget(
      RepaintBoundary(
        key: boundaryKey,
        // RGB(200, 200, 200) stands in for the tone of an OSM road.
        child: const ColorFiltered(
          colorFilter: MapTiles.darkFilter,
          child: SizedBox(
            width: 40,
            height: 40,
            child: ColoredBox(color: Color.fromARGB(255, 200, 200, 200)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final boundary =
        boundaryKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;

    // `toImage` needs the real rasterizer, so it cannot run on the fake test
    // clock.
    ui.Image? image;
    ByteData? data;
    await tester.runAsync(() async {
      image = await boundary.toImage();
      data = await image!.toByteData(format: ui.ImageByteFormat.rawRgba);
    });
    expect(data, isNotNull);

    final offset =
        ((image!.height ~/ 2) * image!.width + image!.width ~/ 2) * 4;
    final pixels = data!;
    final r = pixels.getUint8(offset);
    final g = pixels.getUint8(offset + 1);
    final b = pixels.getUint8(offset + 2);

    // The filter maps RGB(200, 200, 200) to a neutral ~70, so the map reads
    // dark instead of paper-white.
    expect(r, inInclusiveRange(60, 80), reason: 'red channel was $r');
    expect(g, inInclusiveRange(60, 80), reason: 'green channel was $g');
    expect(b, inInclusiveRange(60, 80), reason: 'blue channel was $b');
  });
}
