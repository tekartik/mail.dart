---
name: tekartik-mail-aws-ses-node-setup
description: >-
  Use when sending email from Node.js (cloud functions, node server) with AWS
  SES through tekartik_mail_aws_ses_node: AwsSesMailService,
  AwsSesMailServiceOptions, AwsSesCredentials (accessKeyId, secretAccessKey),
  the package:tekartik_mail_aws_ses_node/mail_aws_ses_node.dart import, the
  @aws-sdk/client-ses npm requirement, AwsSesException, attachments and the
  supportAttachments caveat, and picking it over the pure-Dart SES package.
---

# AWS SES on Node (tekartik_mail_aws_ses_node)

`tekartik_mail_aws_ses_node` implements the `tekartik_mail` `MailService`
interface on top of `tekartik_aws_ses_node`, which wraps the
`@aws-sdk/client-ses` npm module. It only runs in Dart compiled to JavaScript
for Node.js — typically a Firebase / cloud function.

## Guidelines

* Dependency (git, not on pub.dev):
  ```yaml
  dependencies:
    tekartik_mail_aws_ses_node:
      git:
        url: https://github.com/tekartik/mail.dart
        path: packages/mail_aws_ses_node
  ```
  It pulls `tekartik_mail` and `tekartik_aws_ses_node`
  (`https://github.com/tekartik/amazon_node.dart`, `path: packages/aws_ses_node`).
* Runtime prerequisites: the code must be compiled to JS and run on Node,
  and `@aws-sdk/client-ses` must be installed in the node app's
  `package.json` (it is `require`d on first send). On the Dart VM, in a
  browser or in a plain `dart test` run, building the client throws
  `UnsupportedError('awsSes only for node')` — nothing in this package is
  usable there. Pick `tekartik_mail_aws_ses` (same repo,
  `path: packages/mail_aws_ses`) for a pure-Dart VM/Flutter target instead.
* Single import: `package:tekartik_mail_aws_ses_node/mail_aws_ses_node.dart`
  re-exports `package:tekartik_mail/mail.dart` (`MailMessage`,
  `MailRecipient`, `MailAttachment`, `MailService`, `SendMailResult`) and
  adds exactly three names: `AwsSesMailService`, `AwsSesMailServiceOptions`
  and `AwsSesCredentials`. Do not import `src/`.
* Construct with
  `AwsSesMailService(options: AwsSesMailServiceOptions(region: ...,
  credentials: AwsSesCredentials(accessKeyId: ..., secretAccessKey: ...)))`.
  There is no session token and no credential chain: pass explicit keys,
  read from the function config / environment, never hardcoded in source.
* The underlying SES client is created lazily on the first `sendMail` and
  cached in the service, so build the service once (a lazy global or a
  provider) and reuse it. There is no `close()`.
* `message.from` must not be null — `sendMail` dereferences it — and must be
  a verified SES identity in `region`. `to`, `cc`, `bcc`, `replyTo` are
  passed through only when non-null. Recipients with a `name` are encoded
  RFC 2047 (`=?utf-8?B?...?= <email>`), so accented display names are safe;
  a recipient with a null name is sent as the bare address.
* Subject, `text` and `html` are sent as UTF-8 SES content. Set at least one
  of `text` / `html`.
* Attachments caveat: `AwsSesMailService` does NOT override
  `supportAttachments`, so it reports `false` (from `MailServiceMixin`),
  yet `sendMail` does forward `message.attachments` to SES as
  `AwsSesAttachment`. Do not gate attaching on `supportAttachments` with
  this backend — attach unconditionally, or test the concrete type.
* Errors: failures surface as `AwsSesException` (from
  `package:tekartik_aws_ses_node/aws_ses_node.dart`), whose `message` holds
  the SES error text. Catch `AwsSesException` only if you declare
  `tekartik_aws_ses_node` in your own pubspec; otherwise catch `Exception`.
* `sendMail` returns a `SendMailResult` (the concrete `SendMailResultSes` is
  not exported); read `messageId`, which may be null when SES did not return
  one. Type your app fields as `MailService` so the same code can run on
  another backend.
* Testing: there is no fake here. Unit-test your mail-building code against
  a hand written `MailService` (see the `tekartik_mail` package) and keep
  `AwsSesMailService` for a node integration test only. The package's own
  `dart test` run only covers the recipient encoder.

## Examples

### Build the service once and send

```dart
import 'package:tekartik_mail_aws_ses_node/mail_aws_ses_node.dart';

AwsSesMailService? _service;

/// Lazy singleton, credentials coming from the function configuration.
AwsSesMailService getMailService({
  required String region,
  required String accessKeyId,
  required String secretAccessKey,
}) {
  return _service ??= AwsSesMailService(
    options: AwsSesMailServiceOptions(
      region: region,
      credentials: AwsSesCredentials(
        accessKeyId: accessKeyId,
        secretAccessKey: secretAccessKey,
      ),
    ),
  );
}

Future<String?> sendWelcome(MailService service, String email) async {
  var result = await service.sendMail(
    MailMessage(
      from: MailRecipient(email: 'no-reply@example.com', name: 'Example'),
      to: [MailRecipient(email: email)],
      replyTo: [MailRecipient(email: 'support@example.com')],
      subject: 'Welcome',
      text: 'Welcome on board.',
      html: '<p>Welcome on board.</p>',
    ),
  );
  return result.messageId;
}
```

### Attachments (ignore supportAttachments here)

```dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:tekartik_mail_aws_ses_node/mail_aws_ses_node.dart';

Future<SendMailResult> sendCsvReport(
  AwsSesMailService service,
  String to,
  String csv,
) {
  // service.supportAttachments is false, yet attachments are sent.
  return service.sendMail(
    MailMessage(
      from: MailRecipient(email: 'reports@example.com', name: 'Rapports'),
      to: [MailRecipient(email: to)],
      subject: 'Daily report',
      text: 'The report is attached.',
      attachments: [
        MailAttachment(
          mimeType: 'text/csv',
          filename: 'report.csv',
          content: Uint8List.fromList(utf8.encode(csv)),
        ),
      ],
    ),
  );
}
```

### Handling SES errors with the typed exception

```dart
import 'package:tekartik_aws_ses_node/aws_ses_node.dart' show AwsSesException;
import 'package:tekartik_mail_aws_ses_node/mail_aws_ses_node.dart';

/// Returns the message id, or null when SES rejected the mail.
Future<String?> trySend(MailService service, MailMessage message) async {
  try {
    var result = await service.sendMail(message);
    return result.messageId;
  } on AwsSesException catch (e) {
    print('SES rejected the message: ${e.message}');
    return null;
  } on Exception catch (e) {
    // UnsupportedError('awsSes only for node') is an Error, not an
    // Exception: it means the code is not running on node at all.
    print('send failed: $e');
    return null;
  }
}
```
