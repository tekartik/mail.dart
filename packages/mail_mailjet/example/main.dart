// ignore_for_file: avoid_print

import 'dart:io';

import 'package:tekartik_mail_mailjet/mail_mailjet.dart';

Future<void> main() async {
  var env = Platform.environment;
  var apiKey = env['MJ_APIKEY_PUBLIC'];
  var apiSecret = env['MJ_APIKEY_PRIVATE'];
  var from = env['MJ_FROM']; // a sender validated in Mailjet
  var to = env['MJ_TO'];
  if ([apiKey, apiSecret, from, to].any((value) => value?.isEmpty ?? true)) {
    stderr.writeln('Set MJ_APIKEY_PUBLIC, MJ_APIKEY_PRIVATE, MJ_FROM, MJ_TO');
    exitCode = 64;
    return;
  }
  var client = MailjetClient(apiKey: apiKey!, apiSecret: apiSecret!);
  var service = MailjetMailService(client: client);
  try {
    var result = await service.sendMail(
      MailMessage(
        from: MailRecipient(email: from!, name: 'Example'),
        to: [MailRecipient(email: to!)],
        subject: 'Hello',
        text: 'Hello from Mailjet.',
        html: '<p>Hello from <b>Mailjet</b>.</p>',
      ),
    );
    print('sent: ${result.messageId}');
  } finally {
    client.close();
  }
}
