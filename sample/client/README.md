# RFW Android client

The client hosts a `Runtime`, the core RFW widgets, and a small local widget
library. The onboarding layout itself is loaded from the server at runtime.

## Run

Start `sample/server` first, then run:

```sh
fvm flutter pub get
fvm flutter run -d emulator-5554 \
  --dart-define=RFW_BASE_URL=http://10.0.2.2:8080
```

`RFW_BASE_URL` defaults to `http://10.0.2.2:8080`, which is the Android
emulator alias for the local host machine. Supply another value for a device
or a remote server.

## Interaction boundary

`app_rfwtxt.dart` downloads the `onboarding` library and advances the pager
every four seconds by updating `DynamicContent`. The server-defined dots emit a
`setPage` event and the RFW copy animates in the matching direction. Continue
emits `showToast`, handled by `BotToast.showText`. Neither interaction performs
an HTTP request or replaces the root screen.

The client registers RFW's `material.widgets` library. This lets the remote
screen use `InkWell` for native hover, press, and splash feedback while keeping
the controls themselves server-defined.

`PhoneNumberField` is compiled locally because it bridges to Flutter's native
`TextField`. It sends its value back through the remote `phoneChanged` event;
the screen source decides how that value is displayed. SVG assets use
`flutter_svg`.

## Runtime-change check

1. Edit `../server/lib/src/rfwtxt/screens/gopass.rfwtxt`.
2. Restart the installed client app; do not rebuild it.
3. Inspect the updated Gopass onboarding.

The updated remote UI is displayed from the server. Gopass is always the
initial remote screen.

![Gopass running on Android](docs/gopass-android.png)
