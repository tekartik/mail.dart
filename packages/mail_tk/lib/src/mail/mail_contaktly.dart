import 'package:cv/cv.dart';
import 'package:tekartik_mail/mail_mixin.dart';
import 'package:tekartik_mail_tk/mail_tk_contaklty.dart';
import 'package:tekartik_mail_tk/src/constants_contaktly.dart';
import 'package:tekartik_mail_tk/src/tkmail_client_contaktly.dart';

/// Service options.
class TkmailContaktlyServiceOptions {
  /// Service id.
  final String serviceId;

  /// Enc paths
  final List<String> encPaths;

  /// Encryptor
  final String Function(List<Object?> values) encode;

  /// Constructor.
  TkmailContaktlyServiceOptions({
    required this.serviceId,
    required this.encPaths,
    required this.encode,
  });
}

/// Http api
class TkmailContaktlyMailService with MailServiceMixin implements MailService {
  /// Service options.
  final TkmailContaktlyServiceOptions options;

  /// AWS SES client.
  final TkmailClientContaktly client;

  /// Constructor.
  TkmailContaktlyMailService({required this.client, required this.options});

  @override
  Future<SendMailResult> sendMail(MailMessage message) async {
    var getTimestampRequest = ApiGetTimestampRequestContaktly()
      ..app.v = client.app
      ..command.v = commandContaktlyGetTimestamp;
    var timestamp = (await client.getTimestamp(
      getTimestampRequest,
    )).timestamp.v!;
    var query = ApiSendMailQueryContaktly()
      ..serviceId.v = options.serviceId
      ..timestamp.v = timestamp
      ..message.v = message.toApiMailMessage();
    query.enc.v = options.encode(
      options.encPaths
          .map((path) => query.valueAtPath(keyPartsFromString(path)))
          .toList(),
    );
    var request = ApiSendMailRequestContaktly()
      ..app.v = client.app
      ..command.v = commandContaktlySendEmail
      ..query.v = query;

    var response = await client.sendEmail(request);

    return SendMailResultFromApi(response);
  }
}
