# tekartik_mail_mailjet

A `MailService` (`tekartik_mail`) sending through the Mailjet v3.1 HTTP api
(`tekartik_mailjet`): build a `MailMessage`, `sendMail` it, swap the backend
without touching the app code.

## Getting started

Git package, not on pub.dev:

```yaml
dependencies:
  tekartik_mail_mailjet:
    git:
      url: https://github.com/tekartik/mail.dart
      path: packages/mail_mailjet
```

Send one email, the keys read from the environment
([example/main.dart](example/main.dart)):

```dart
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
```

## Platforms

Everywhere `package:http` runs (Dart VM, Flutter, node). Keep the api secret
on a server: a browser or app shipping it gives it to every user.

## Common pitfalls

* `from` is required (`sendMail` throws without it) and must be a sender or
  domain validated in the Mailjet account.
* An error answer of Mailjet (401 bad keys, 400 invalid message, 429) throws
  an `HttpClientException` (`package:tekartik_http/http_client.dart`): catch
  it in background jobs.
* `replyTo` is ignored (not sent to Mailjet): replies go to `from`.
* `result.messageId` is the id of the first `to` recipient: null for a
  message sent with `cc` or `bcc` only.
* Attachments are supported (base64 in the request, Mailjet limits the
  message to 15 MB).
* `client.close()` also closes an `http.Client` you gave to `MailjetClient`.
* Templates and other Mailjet features: use `MailjetClient.sendEmail` with a
  `CvMailjetSendEmailRequest` (`package:tekartik_mailjet/mailjet.dart`).
* Never print or commit the api key and secret; `debugMailjet = true`
  (`tekartik_mailjet`) prints the messages sent.
