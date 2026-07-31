# RFW sample server

## Run

```sh
cd sample/server
fvm dart pub get
PORT=8080 fvm dart run bin/server.dart
```

## Remote screen endpoint

`GET /rfwtxt?screen=gopass` is the default onboarding response. The server
reads `lib/src/rfwtxt/screens/gopass.rfwtxt` for each request, parses it, and
returns an RFW binary library (`application/rfw`).

Available screens:

- `gopass` — the primary onboarding UI.
- `alternate` — a small independently interactive remote screen for proving a
  source update without rebuilding the Flutter client.

Pass `format=text` to read the source rather than the binary payload:

```sh
curl 'http://localhost:8080/rfwtxt?screen=gopass&format=text'
```

The inherited `/pagination` route remains as a Flutter Swap sample. It uses
the older server-side `Swap` mechanism and is intentionally not used by the
RFW onboarding: RFW pagination is local `state.page` in `gopass.rfwtxt`.
