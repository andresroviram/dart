import 'dart:async';
import 'dart:typed_data';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rfw/rfw.dart';

import 'onboarding_local_widgets.dart';

typedef RemoteLibraryLoader = Future<http.Response> Function(Uri uri);

class RfwOnboardingApp extends StatefulWidget {
  const RfwOnboardingApp({
    super.key,
    required this.baseUrl,
    this.loader,
    this.pagerInterval = const Duration(seconds: 4),
  });

  final String baseUrl;
  final RemoteLibraryLoader? loader;
  final Duration? pagerInterval;

  @override
  State<RfwOnboardingApp> createState() => _RfwOnboardingAppState();
}

class _RfwOnboardingAppState extends State<RfwOnboardingApp> {
  static const _coreName = LibraryName(<String>['core', 'widgets']);
  static const _localName = LibraryName(<String>['gopass', 'local']);
  static const _remoteName = LibraryName(<String>['onboarding']);

  final Runtime _runtime = Runtime();
  final DynamicContent _data = DynamicContent();

  Timer? _pagerTimer;
  var _screen = 'gopass';
  var _revision = 0;
  var _pagerPage = 3;
  var _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _runtime
      ..update(_coreName, createCoreWidgets())
      ..update(const LibraryName(<String>['material', 'widgets']),
          createMaterialWidgets())
      ..update(_localName, createOnboardingLocalWidgets());
    _data.update('form', <String, Object>{'phone': ''});
    _data.update('interaction', <String, Object>{'message': ''});
    _data.update('onboarding', <String, Object>{
      'page': _pagerPage,
      'previousPage': _pagerPage,
      'direction': 'forward',
    });
    _loadScreen(_screen);
  }

  @override
  void dispose() {
    _pagerTimer?.cancel();
    _runtime.dispose();
    super.dispose();
  }

  Uri _screenUri(String screen) {
    return Uri.parse('${widget.baseUrl}/rfwtxt').replace(
      queryParameters: <String, String>{'screen': screen},
    );
  }

  Future<void> _loadScreen(String screen) async {
    final wasReady = !_loading && _error == null;
    if (!wasReady) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final response = await (widget.loader ?? http.get)(_screenUri(screen));
      if (response.statusCode != 200) {
        throw StateError('Unable to load remote UI (${response.statusCode}).');
      }

      _runtime.update(_remoteName, decodeLibraryBlob(_bytes(response)));
      if (!mounted) {
        return;
      }

      setState(() {
        _screen = screen;
        _revision++;
        _loading = false;
        _error = null;
      });
      _configurePager(screen);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _error = error;
      });
    }
  }

  Uint8List _bytes(http.Response response) {
    return Uint8List.fromList(response.bodyBytes);
  }

  void _onEvent(String name, DynamicMap arguments) {
    switch (name) {
      case 'openScreen':
        final screen = arguments['screen'];
        if (screen is String) {
          _loadScreen(screen);
        }
      case 'showAction':
        final message = arguments['message'];
        if (message is String) {
          _data.update('interaction', <String, Object>{'message': message});
        }
      case 'showToast':
        final message = arguments['message'];
        if (message is String) {
          BotToast.showText(text: message);
        }
      case 'setPage':
        final page = arguments['page'];
        if (page is int && page >= 1 && page <= 4) {
          _setPagerPage(
            page,
            direction: page > _pagerPage ? 'forward' : 'backward',
          );
          _configurePager(_screen);
        }
      case 'phoneChanged':
        final value = arguments['value'];
        if (value is String) {
          _data.update('form', <String, Object>{'phone': value});
        }
    }
  }

  void _configurePager(String screen) {
    _pagerTimer?.cancel();
    if (screen != 'gopass' || widget.pagerInterval == null) {
      return;
    }

    _pagerTimer = Timer.periodic(widget.pagerInterval!, (_) {
      if (!mounted || _screen != 'gopass') {
        return;
      }
      _setPagerPage(
        _pagerPage == 4 ? 1 : _pagerPage + 1,
        direction: 'forward',
      );
    });
  }

  void _setPagerPage(int page, {required String direction}) {
    if (page == _pagerPage) {
      return;
    }

    final previousPage = _pagerPage;
    _pagerPage = page;
    _data.update('onboarding', <String, Object>{
      'page': page,
      'previousPage': previousPage,
      'direction': direction,
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gopass',
      builder: BotToastInit(),
      home: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error case final error?) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Unable to load the remote interface.\n$error'),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadScreen(_screen),
      child: RemoteWidget(
        key: ValueKey<int>(_revision),
        runtime: _runtime,
        data: _data,
        widget: const FullyQualifiedWidgetName(_remoteName, 'root'),
        onEvent: _onEvent,
      ),
    );
  }
}
