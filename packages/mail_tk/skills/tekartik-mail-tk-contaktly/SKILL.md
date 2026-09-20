---
name: tekartik-mail-tk-contaktly
description: >-
  Use when sending mail through the contaktly tkmail endpoint of
  tekartik_mail_tk: TkmailContaktlyMailService, TkmailContaktlyServiceOptions
  (serviceId, encPaths, encode), TkmailClientContaktly (uri, app),
  ApiSendMailRequestContaktly, ApiSendMailQueryContaktly, ApiErrorContaktly,
  initTkmailContaktlyBuilders, commandContaktlySendEmail, and the
  package:tekartik_mail_tk/mail_contaktly.dart and mail_tk_contaklty.dart
  imports.
---

# Tkmail contaktly client (tekartik_mail_tk)

The `contaktly` flavour of `tekartik_mail_tk` sends mail through a single
contaktly endpoint: the client first asks the server for a timestamp, then
posts the message with a signature (`enc`) computed over selected fields.
The shared wire model and client base are described in the
`tekartik-mail-tk-api` skill: [api](../tekartik-mail-tk-api/SKILL.md).

## Guidelines

* Dependency (git, not on pub.dev):
  ```yaml
  dependencies:
    tekartik_mail_tk:
      git:
        url: https://github.com/tekartik/mail.dart
        path: packages/mail_tk
      version: '>1.0.1'
  ```
* Imports (mind the typo in the second file name, it is the real name):
  * `package:tekartik_mail_tk/mail_contaktly.dart` — what a sender needs:
    `TkmailContaktlyMailService`, `TkmailContaktlyServiceOptions`,
    `TkmailClientContaktly` and the `tekartik_mail` model.
  * `package:tekartik_mail_tk/mail_tk_contaklty.dart` — the wire level:
    everything from `mail_tk.dart` plus `ApiSendMailRequestContaktly`,
    `ApiSendMailQueryContaktly`, `ApiSendMailResponseContaktly`,
    `ApiSendMailResultContaktly`, `ApiGetTimestampRequestContaktly`,
    `ApiGetTimestampResponseContaktly`, `ApiGetTimestampResultContaktly`,
    `ApiErrorContaktly`, `ApiCredentialsAwsSes`, `initTkmailContaktlyBuilders`
    and `commandContaktlySendEmail`. It does NOT export
    `TkmailClientContaktly` (it exports `TkmailClientAwsSes` instead), so
    import `mail_contaktly.dart` as well when you need the client type.
  * Never import both `mail_tk_contaklty.dart` and `mail_tk_aws_ses.dart` in
    the same file: both export a different `ApiCredentialsAwsSes`.
* Wiring: `TkmailClientContaktly(uri: <the single endpoint uri>, app:
  '<app name>')`, then `TkmailContaktlyMailService(client: client, options:
  TkmailContaktlyServiceOptions(serviceId: ..., encPaths: [...], encode:
  ...))`. Every command is POSTed to that same `uri` (no path is appended);
  the body carries `app`, `command` and `data`.
* `encPaths` are dot separated paths inside the `ApiSendMailQueryContaktly`
  model (`'timestamp'`, `'serviceId'`, `'message.subject'`,
  `'message.to.0.email'`; an integer part is a list index). The values found
  at those paths, in that order, are passed to
  `encode(List<Object?> values)`, whose returned string is sent as the `enc`
  field. Implement `encode` with the signing algorithm the server expects
  (usually an hmac over the joined values with a shared secret) and keep the
  secret out of the source.
* Each `sendMail` performs two http round trips: a timestamp request
  (`command: 'timestamp'`) whose result is signed, then the send
  (`commandContaktlySendEmail`, `'sendemail'`). The timestamp command
  constant is not exported; the service handles the handshake, so prefer the
  service over raw calls.
* Errors: on a response carrying `error`, the client THROWS the
  `ApiErrorContaktly` model itself, which is a `CvModelBase`, not an
  `Exception`. Catch it with `on ApiErrorContaktly catch (e)` and read
  `e.code.v`, `e.message.v`, `e.details.v`; a bare `on Exception` will NOT
  catch it. Transport errors (non 2xx) are thrown by the http layer.
* `sendMail` returns a `SendMailResultFromApi`; `messageId` comes from the
  contaktly `result.messageId`.
* `supportAttachments` is not overridden, so it reports `false` (from
  `MailServiceMixin`), yet `attachments` (and `replyTo`, `cc`, `bcc`) are
  serialized and sent. Do not gate attaching on `supportAttachments` here.
* `initTkmailContaktlyBuilders()` is called by the `TkmailClientContaktly`
  constructor; call it explicitly only when you decode models without a
  client (tests, server side).
* Lifecycle and debugging: reuse one client, `client.close()` when done; set
  `debugTkmailApi = true` before creating it to log the json exchanged (mail
  content included, so not in production). Inject a fake `package:http`
  `Client` with `TkmailClientContaktly(uri: ..., app: ..., client: fake)` to
  test without a server.

## Examples

### Build the service

```dart
import 'dart:convert';

import 'package:tekartik_mail_tk/mail_contaktly.dart';

/// Replace with the signature algorithm the endpoint expects.
String signValues(List<Object?> values, String secret) =>
    base64Encode(utf8.encode([secret, ...values].join('|')));

MailService buildMailService({
  required Uri uri,
  required String app,
  required String serviceId,
  required String secret,
}) {
  var client = TkmailClientContaktly(uri: uri, app: app);
  return TkmailContaktlyMailService(
    client: client,
    options: TkmailContaktlyServiceOptions(
      serviceId: serviceId,
      // Paths inside the query model, signed in this order.
      encPaths: ['timestamp', 'serviceId', 'message.subject'],
      encode: (values) => signValues(values, secret),
    ),
  );
}
```

### Send and handle a contaktly error

```dart
import 'package:tekartik_mail_tk/mail_contaktly.dart';
import 'package:tekartik_mail_tk/mail_tk_contaklty.dart'
    show ApiErrorContaktly;

/// Returns the message id, or null when contaktly refused the mail.
Future<String?> sendNotification(MailService service, String to) async {
  try {
    var result = await service.sendMail(
      MailMessage(
        from: MailRecipient(email: 'no-reply@example.com', name: 'Example'),
        to: [MailRecipient(email: to)],
        subject: 'Notification',
        text: 'Something happened.',
        html: '<p>Something happened.</p>',
      ),
    );
    return result.messageId;
  } on ApiErrorContaktly catch (e) {
    // Not an Exception: `on Exception` would miss it.
    print('contaktly error ${e.code.v}: ${e.message.v}');
    return null;
  }
}
```

### Full CLI run, with the client closed at the end

```dart
import 'dart:io';

import 'package:tekartik_mail_tk/mail_contaktly.dart';

Future<void> main(List<String> args) async {
  var env = Platform.environment;
  var client = TkmailClientContaktly(
    uri: Uri.parse(env['TKMAIL_URI']!),
    app: 'my_app',
  );
  var service = TkmailContaktlyMailService(
    client: client,
    options: TkmailContaktlyServiceOptions(
      serviceId: env['TKMAIL_SERVICE_ID']!,
      encPaths: ['timestamp', 'serviceId'],
      encode: (values) => values.join('-'), // demo only, sign for real
    ),
  );
  try {
    var result = await service.sendMail(
      MailMessage(
        from: MailRecipient(email: 'no-reply@example.com'),
        to: [MailRecipient(email: args.first)],
        subject: 'Hello',
        text: 'Hello from contaktly.',
      ),
    );
    stdout.writeln('sent: ${result.messageId}');
  } finally {
    client.close();
  }
}
```
