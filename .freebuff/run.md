# Run doc — flutter_ui_taksi (cloud VM preview)

This worktree is a Flutter/Dart project. There are no env files to copy from the
main checkout: the Google Maps API key placeholders live in
`android/app/src/main/AndroidManifest.xml` and
`lib/services/google_map_service.dart` and are only used by mobile targets.

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
- Log used for this run: `.freebuff/preview-36f2d113-2636-4344-b220-6a1c4eb571e3.log`
  (server process detached; listener pid recorded in the chat).
- stdin is detached, so hot reload does not apply — rebuild `build/web` and
  restart the server to pick up code changes.
- Stop it by killing the listener pid on port 3000.

Known runtime limitation in the browser: Google Maps tiles need a real Maps JS
API key, so the map areas render without tiles; the rest of the UI (rides,
roles, driver/admin screens, and the food/delivery/groceries flows wired
through the API stub) works.
