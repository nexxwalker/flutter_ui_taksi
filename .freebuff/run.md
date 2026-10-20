# Run doc — flutter_ui_taksi (cloud VM preview)

This worktree is a Flutter/Dart project. There are no env files or API keys to
copy from the main checkout: maps render OpenStreetMap raster tiles, which need
no credential (see the Maps section below).

## 1. Reproduce the artifacts a fresh checkout needs

```bash
# Flutter 3.19.3 stable (same version as .github/workflows/main.yaml).
# If the SDK is missing, install it, then:
export PATH=$HOME/flutter/bin:$PATH
flutter config --enable-web      # once per SDK install
flutter precache --web           # once per SDK install
flutter pub get                  # resolves from the committed pubspec.lock

# Build the web artifact tree that the preview serves.
# This produces build/web (index.html + main.dart.js + canvaskit/ + assets/).
flutter build web --base-href / --web-renderer canvaskit
```

The preview serves the **prebuilt** `build/web` tree through a static HTTP
server — it does not run `flutter run` / the Dart dev compiler.

### Checks (same commands CI runs)

```bash
flutter analyze        # must report "No issues found!"
flutter test           # widget tests only; API integration tests skip
```

`test/api_test.dart` drives the real Worker in `api/`, so it needs a backend:

```bash
npm ci
(cd api && npx wrangler d1 execute food-delivery-db --local --file schema.sql)
(cd api && npx wrangler dev --port 8788 --ip 127.0.0.1 &)   # wait for /health
API_BASE_URL=http://127.0.0.1:8788 flutter test             # 16 tests, all green
```

## 2. Run the server

```bash
# Serve build/web on 0.0.0.0:3000 from this worktree root.
# Any static HTTP server works; the process used here is the one attached to
# the registered preview (pid recorded in the chat).
python3 -m http.server 3000 --directory build/web --bind 0.0.0.0
# or, if python3 is unavailable:
npx --yes http-server build/web -p 3000 -a 0.0.0.0 -c-1
```

- Bound to `0.0.0.0:3000`; the Freebuff preview panel reaches it through the
  VM preview hostname (the static server does not validate Host headers).
- Log used for this run: `.freebuff/preview.log`; listener pid in
  `.freebuff/preview.pid` (server process detached).
- stdin is detached, so hot reload does not apply — rebuild `build/web` and
  restart the server to pick up code changes.
- Stop it by killing the listener pid on port 3000.

## Maps

Maps are rendered by `flutter_map` on OpenStreetMap raster tiles
(`https://tile.openstreetmap.org/{z}/{x}/{y}.png`). No API key is involved, so
the web bundle ships no credential: do not reintroduce a `maps.googleapis.com`
script in `web/index.html` or a key placeholder in the Android manifest.

- Tiles: OpenStreetMap, attribution shown on the map, filtered into the app's
  dark basemap by `MapTiles.darkLayer` (`lib/config/map_tiles.dart`). Both maps
  use it, so the tile source and colour treatment only change in one place.
- Routes: OSRM public server (`router.project-osrm.org`), key-free.
- Pin reverse geocoding: Nominatim (best effort; falls back to "Nyeri, Kenya").

Browsers need network access to `tile.openstreetmap.org`, `router.project-osrm.org`
and `nominatim.openstreetmap.org` for tiles, routes and pin labels.

OpenStreetMap blocks scripts that send a generic user agent (`Python-urllib`,
empty UA, …) with a 403 "Access blocked" tile, so manual checks must identify
themselves, e.g. `curl -A "flutter_ui_taksi/1.0 (dev check)"`. CARTO's dark
basemap is not an alternative: its tiles now require an API key even though the
endpoint may still answer without one.

`test/map_component_test.dart` renders the map with an in-memory tile provider,
so widget tests need no network; `test/map_tiles_test.dart` checks the filter's
rendered output.
