import 'dart:convert';

// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
// ignore: depend_on_referenced_packages
import 'package:tekartik_http/http_client.dart';

import 'tkmail_models.dart';

/// To set before creating the client.
var debugTkmailApi = false;

/// The main client
abstract class TkmailClient {
  Uri get uri;
  final _debug = debugTkmailApi;
  late final http.Client _client;

  TkmailClient({http.Client? client}) {
    _client = client ?? http.Client();
    initTkmailBuilders();
  }

  Future<Map> send(Uri uri, Map request) async {
    var body = jsonEncode(request);
    if (_debug) {
      print('send: $uri');
      print('      $body');
    }
    var resultText = await httpClientRead(_client, httpMethodPost, uri,
        headers: {
          httpHeaderContentType: httpContentTypeJson,
        },
        body: body);
    if (_debug) {
      print('recv: $resultText');
    }
    return jsonDecode(resultText) as Map;
  }

  /// Dispose the client
  void close() {
    _client.close();
  }
}
