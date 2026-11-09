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

/// The keys whose value is a secret, never logged.
const _secretKeys = {'secretAccessKey'};

/// A copy of [value] with the secrets replaced by `***`, for the debug log.
Object? _redactSecrets(Object? value) {
  if (value is Map) {
    return {
      for (var entry in value.entries)
        entry.key: _secretKeys.contains(entry.key)
            ? '***'
            : _redactSecrets(entry.value),
    };
  } else if (value is List) {
    return value.map(_redactSecrets).toList();
  }
  return value;
}

/// The json over http client of a tkmail endpoint (the base of
/// `TkmailClientAwsSes` and `TkmailClientContaktly`).
///
/// A non 2xx answer throws an `HttpClientException`; [close] also closes the
/// `client` given to the constructor.
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
      _log('send: $uri');
      // Never the credentials (the AWS secret of the aws_ses flavour).
      _log('      ${jsonEncode(_redactSecrets(request))}');
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
