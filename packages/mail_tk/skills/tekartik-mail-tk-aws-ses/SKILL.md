---
name: tekartik-mail-tk-aws-ses
description: >-
  Use when sending mail through a tkmail http endpoint backed by AWS SES with
  tekartik_mail_tk: TkmailAwsSesMailService, TkmailAwsSesMailServiceOptions,
  TkmailAwsSesCredentials, TkmailClientAwsSes, ApiSendMailRequestAwsSes,
  ApiCredentialsAwsSes, initTkmailAwsSesBuilders, commandSendMailAwsSes, and
  the package:tekartik_mail_tk/mail_aws_ses.dart and mail_tk_aws_ses.dart
  imports.
---

# Tkmail AWS SES client (tekartik_mail_tk)

The `aws_ses` flavour of `tekartik_mail_tk` posts a `MailMessage` plus the
AWS region and credentials to a tkmail endpoint of your own, which relays it
to SES. The wire model and the `TkmailClient` base are described in the
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
* Two imports, do not mix them up:
  * `package:tekartik_mail_tk/mail_aws_ses.dart` — what a sender needs:
    `TkmailAwsSesMailService`, `TkmailAwsSesMailServiceOptions`,
    `TkmailAwsSesCredentials`, `TkmailClientAwsSes` and the `tekartik_mail`
    model.
  * `package:tekartik_mail_tk/mail_tk_aws_ses.dart` — the wire level:
    everything from `mail_tk.dart` plus `ApiSendMailRequestAwsSes`,
    `ApiCredentialsAwsSes`, `initTkmailAwsSesBuilders` and
    `commandSendMailAwsSes`. Use it for a raw request or for the server
    side.
* Wiring: `TkmailClientAwsSes(uri: Uri.parse('https://host/base'))` then
  `TkmailAwsSesMailService(client: client, options:
  TkmailAwsSesMailServiceOptions(region: ..., credentials:
  TkmailAwsSesCredentials(accessKeyId: ..., secretAccessKey: ...)))`.
  Expose the result as a `MailService`.
* The client POSTs to `<uri path>/send_mail` (`commandSendMailAwsSes`), so
  `uri` is the base of the api, without the command. `client.close()`
  releases the http client; the service has no `close()`.
* The request body carries `service: {region, credentials: {accessKeyId,
  secretAccessKey}}` next to `message`. The AWS keys travel to your
  endpoint: use https, keep the endpoint private, and use a dedicated SES
  only IAM user. Read the keys from configuration, never hardcode them.
* `supportAttachments` is not overridden, so it reports `false` (from
  `MailServiceMixin`), yet attachments ARE serialized (base64) and sent.
  Do not gate attaching on `supportAttachments` with this backend.
* `message.from` is optional here (it is mapped with `from?.`), so the
  endpoint may define the sender; everything else maps one to one, including
  `replyTo`, which this backend does forward.
* `sendMail` returns a `SendMailResultFromApi` whose `messageId` is the
  `messageId` of the endpoint response. Http errors (non 2xx) are thrown,
  not returned.
* Raw requests: `initTkmailAwsSesBuilders()` (it also calls
  `initTkmailBuilders()`), build an `ApiSendMailRequestAwsSes`, then
  `client.sendEmail(request)` which returns an `ApiSendMailResponse`.
  `ApiServiceAwsSes` (the `service` field type) is NOT exported: read it
  through `request.service.v` with `var`, create it with
  `request.service.create({})`, and never name the type.
* `ApiCredentialsAwsSes` is exported by both `mail_tk_aws_ses.dart` and
  `mail_tk_contaklty.dart` as two distinct classes; importing both libraries
  in the same file is ambiguous. Pick one flavour per file.
* Debugging and tests: set `debugTkmailApi = true` before creating the
  client to log the json, and inject a fake `package:http` `Client` with
  `TkmailClientAwsSes(uri: ..., client: fakeClient)` to test without a
  server.

## Examples

### Send through the tkmail endpoint

```dart
import 'dart:io';

import 'package:tekartik_mail_tk/mail_aws_ses.dart';

Future<void> main() async {
  var env = Platform.environment;
  var client = TkmailClientAwsSes(
    uri: Uri.parse('https://mail.example.com/api'),
  );
  var service = TkmailAwsSesMailService(
    client: client,
    options: TkmailAwsSesMailServiceOptions(
      region: env['AWS_REGION'] ?? 'eu-west-1',
      credentials: TkmailAwsSesCredentials(
        accessKeyId: env['AWS_ACCESS_KEY_ID']!,
        secretAccessKey: env['AWS_SECRET_ACCESS_KEY']!,
      ),
    ),
  );
  try {
    var result = await service.sendMail(
      MailMessage(
        from: MailRecipient(email: 'no-reply@example.com', name: 'Example'),
        to: [MailRecipient(email: 'user@example.com')],
        replyTo: [MailRecipient(email: 'support@example.com')],
        subject: 'Hello',
        text: 'Hello from tkmail.',
        html: '<p>Hello from tkmail.</p>',
      ),
    );
    stdout.writeln('sent: ${result.messageId}');
  } finally {
    client.close();
  }
}
```

### Send an attachment (supportAttachments says false, it still works)

```dart
import 'dart:io';

import 'package:tekartik_mail_tk/mail_aws_ses.dart';

Future<SendMailResult> sendReport(
  TkmailAwsSesMailService service,
  String to,
  File pdf,
) {
  return service.sendMail(
    MailMessage(
      from: MailRecipient(email: 'reports@example.com'),
      to: [MailRecipient(email: to)],
      subject: 'Daily report',
      text: 'The report is attached.',
      attachments: [
        MailAttachment(
          mimeType: 'application/pdf',
          filename: 'report.pdf',
          content: pdf.readAsBytesSync(),
        ),
      ],
    ),
  );
}
```

### Build the raw request yourself

```dart
import 'package:tekartik_mail_tk/mail_tk_aws_ses.dart';

Future<String?> sendRaw(
  TkmailClientAwsSes client, {
  required String region,
  required String accessKeyId,
  required String secretAccessKey,
  required MailMessage message,
}) async {
  initTkmailAwsSesBuilders();
  var request = ApiSendMailRequestAwsSes()
    ..message.v = message.toApiMailMessage();
  // ApiServiceAwsSes is not exported: fill the field through its value.
  request.service.v = request.service.create({})
    ..region.v = region
    ..credentials.v = (ApiCredentialsAwsSes()
      ..accessKeyId.v = accessKeyId
      ..secretAccessKey.v = secretAccessKey);
  var response = await client.sendEmail(request);
  return response.messageId.v;
}
```

### Server side: decode an incoming aws_ses request

```dart
import 'package:cv/cv.dart';
import 'package:tekartik_mail_tk/mail_tk_aws_ses.dart';

/// What the endpoint needs to relay the mail to SES itself.
({String region, String accessKeyId, String secretAccessKey, MailMessage mail})
parseRequest(Map<String, Object?> body) {
  initTkmailAwsSesBuilders();
  var request = body.cv<ApiSendMailRequestAwsSes>();
  var service = request.service.v!; // type not exported, keep `var`.
  var credentials = service.credentials.v!;
  var apiMessage = request.message.v!;
  return (
    region: service.region.v!,
    accessKeyId: credentials.accessKeyId.v!,
    secretAccessKey: credentials.secretAccessKey.v!,
    mail: MailMessage(
      from: apiMessage.from.v?.toMailRecipient(),
      to: apiMessage.to.v?.map((e) => e.toMailRecipient()).toList(),
      replyTo: apiMessage.replyTo.v?.map((e) => e.toMailRecipient()).toList(),
      subject: apiMessage.subject.v!,
      text: apiMessage.text.v,
      html: apiMessage.html.v,
      attachments: apiMessage.attachments.v
          ?.map((e) => e.toMailAttachment())
          .toList(),
    ),
  );
}
```
