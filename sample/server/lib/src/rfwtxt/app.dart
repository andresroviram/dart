import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:swap/swap.dart';

class RfwtxtController {
  static const _screens = <String>{'gopass', 'alternate'};

  Router get router {
    final result = Router();

    result.get('/', _serveScreen);

    return result;
  }

  Future<Response> _serveScreen(Request request) async {
    final screen = request.url.queryParameters['screen'] ?? 'gopass';
    if (!_screens.contains(screen)) {
      return Response.notFound('Unknown remote screen.');
    }

    final source = await File('lib/src/rfwtxt/screens/$screen.rfwtxt')
        .readAsString();

    if (request.url.queryParameters['format'] == 'text') {
      return Response.ok(
        source,
        headers: const <String, String>{'Content-Type': 'application/rfwtxt'},
      );
    }

    return Response.ok(
      encodeLibraryBlob(parseLibraryFile(source)),
      headers: const <String, String>{'Content-Type': 'application/rfw'},
    );
  }
}
