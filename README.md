# Flutter Swap Dart — RFW sample

This fork keeps the original Flutter Swap packages and adds a Remote Flutter
Widgets (RFW) onboarding sample under `sample/`.

## Run the sample

1. Start the server:

   ```sh
   cd sample/server
   fvm dart pub get
   PORT=8080 fvm dart run bin/server.dart
   ```

2. Run the Android client in another terminal:

   ```sh
   cd sample/client
   fvm flutter pub get
   fvm flutter run -d emulator-5554 \
     --dart-define=RFW_BASE_URL=http://10.0.2.2:8080
   ```

The Android emulator reaches the host server through `10.0.2.2`.

## Runtime RFW flow

- `sample/server/lib/src/rfwtxt/screens/gopass.rfwtxt` is the default Gopass
  onboarding screen.
- The server reads and compiles the requested `.rfwtxt` file for every
  request. It does not cache a screen in memory.
- The client downloads the remote `onboarding` library at runtime. Its only
  compiled additions are stable native primitives in
  `sample/client/lib/src/onboarding_local_widgets.dart` for the phone field
  and SVG icons.
- The client advances Gopass every four seconds through `DynamicContent`; the
  server-defined dots can also select a page through RFW events. Input, social
  actions, and the Continue toast do not request or replace the root screen.
- Social controls and Continue use remote RFW Material `InkWell` widgets for
  native hover, press, and splash feedback.

Edit `gopass.rfwtxt` while the server is running, restart the client
application, and the changed onboarding is fetched without rebuilding the
Android client. Gopass remains the initial screen.

Use `GET /rfwtxt?screen=gopass&format=text` to inspect the editable source.
The default endpoint returns RFW's binary library format for transport.

See the focused instructions in [the client README](sample/client/README.md)
and [the server README](sample/server/README.md).
