import 'dart:convert';

// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
// ignore: depend_on_referenced_packages
import 'package:tekartik_http/http_client.dart';

import 'tkmail_models.dart';

/// To set before creating the client.
var debugTkmailApi = false;

void _log(Object? message) {
  // ignore: avoid_print
  print(message);
}

/// The main client
abstract class TkmailClient {
  /// The uri
  Uri get uri;
  final _debug = debugTkmailApi;
  late final http.Client _client;

  /// Constructor
  TkmailClient({http.Client? client}) {
    _client = client ?? http.Client();
    initTkmailBuilders();
  }

  /// Send a request
  Future<Map> send(Uri uri, Map request) async {
    var body = jsonEncode(request);
    if (_debug) {
      // ignore: avoid_print
      _log('send: $uri');
      _log('      $body');
    }
    var resultText = await httpClientRead(
      _client,
      httpMethodPost,
      uri,
      headers: {httpHeaderContentType: httpContentTypeJson},
      body: body,
    );
    if (_debug) {
      _log('recv: $resultText');
    }
    return jsonDecode(resultText) as Map;
  }

  /// Dispose the client
  void close() {
    _client.close();
  }
}
