import 'dart:io';

import 'package:tekartik_mail_tk/mail_aws_ses.dart';

/// Sends one mail through a tkmail aws_ses endpoint of your own.
///
/// ```sh
/// TKMAIL_URI=https://mail.example.com/api AWS_REGION=eu-west-1 \
///   AWS_ACCESS_KEY_ID=... AWS_SECRET_ACCESS_KEY=... \
///   MAIL_FROM=me@example.com MAIL_TO=you@example.com \
///   dart run example/main.dart
/// ```
Future<void> main() async {
  var env = Platform.environment;
  String? value(String name) =>
      (env[name]?.isNotEmpty ?? false) ? env[name] : null;
  var uri = value('TKMAIL_URI');
  var accessKeyId = value('AWS_ACCESS_KEY_ID');
  var secretAccessKey = value('AWS_SECRET_ACCESS_KEY');
  var from = value('MAIL_FROM');
  var to = value('MAIL_TO');
  if (uri == null ||
      accessKeyId == null ||
      secretAccessKey == null ||
      from == null ||
      to == null) {
    stderr.writeln(
      'Set TKMAIL_URI, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, MAIL_FROM '
      'and MAIL_TO (AWS_REGION optional)',
    );
    exitCode = 64;
    return;
  }
  var client = TkmailClientAwsSes(uri: Uri.parse(uri));
  MailService service = TkmailAwsSesMailService(
    client: client,
    options: TkmailAwsSesMailServiceOptions(
      region: value('AWS_REGION') ?? 'eu-west-1',
      credentials: TkmailAwsSesCredentials(
        accessKeyId: accessKeyId,
        secretAccessKey: secretAccessKey,
      ),
    ),
  );
  try {
    var result = await service.sendMail(
      MailMessage(
        from: MailRecipient(email: from),
        to: [MailRecipient(email: to)],
        subject: 'Hello',
        text: 'Hello from tekartik_mail_tk',
      ),
    );
    stdout.writeln('sent: ${result.messageId}');
  } finally {
    client.close();
  }
}
