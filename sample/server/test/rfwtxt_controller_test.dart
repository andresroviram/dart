import 'dart:typed_data';

import 'package:shelf/shelf.dart';
import 'package:swap/swap.dart';
import 'package:swap_server_sample/src/app.dart';
import 'package:test/test.dart';

void main() {
  test('serves the Gopass source as a runtime RFW library', () async {
    final response = await ServerApp().build()(
      Request('GET', Uri.parse('http://localhost/rfwtxt?screen=gopass')),
    );

    expect(response.statusCode, 200);
    expect(response.headers['content-type'], 'application/rfw');
    expect(
      decodeLibraryBlob(await _bytes(response)),
      isA<RemoteWidgetLibrary>(),
    );
  });

  test('exposes an alternate remote interface without changing the client',
      () async {
    final response = await ServerApp().build()(
      Request('GET', Uri.parse('http://localhost/rfwtxt?screen=alternate')),
    );

    expect(response.statusCode, 200);
    expect(response.headers['content-type'], 'application/rfw');
    expect(
      decodeLibraryBlob(await _bytes(response)),
      isA<RemoteWidgetLibrary>(),
    );
  });

  test('returns the editable rfwtxt source when requested', () async {
    final response = await ServerApp().build()(
      Request(
        'GET',
        Uri.parse('http://localhost/rfwtxt?screen=gopass&format=text'),
      ),
    );

    expect(response.statusCode, 200);
    expect(response.headers['content-type'], startsWith('application/rfwtxt'));
    expect(await response.readAsString(), contains('widget GopassOnboarding'));
  });
}

Future<Uint8List> _bytes(Response response) async {
  return response.read().fold<Uint8List>(
        Uint8List(0),
        (Uint8List bytes, List<int> chunk) =>
            Uint8List.fromList(<int>[...bytes, ...chunk]),
      );
}
