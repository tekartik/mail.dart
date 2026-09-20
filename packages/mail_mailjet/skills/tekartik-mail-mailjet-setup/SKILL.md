---
name: tekartik-mail-mailjet-setup
description: >-
  Use when sending email through the Mailjet v3.1 HTTP API with
  tekartik_mail_mailjet: MailjetMailService, MailjetClient,
  MailjetCredentials, the package:tekartik_mail_mailjet/mail_mailjet.dart
  import, api key / api secret setup, attachments, client.close(), the
  ignored replyTo caveat, and dropping to CvMailjetSendEmailRequest /
  CvMailjetMessage for Mailjet templates.
---

# Mailjet mail service (tekartik_mail_mailjet)

`tekartik_mail_mailjet` implements the `tekartik_mail` `MailService`
interface on top of `tekartik_mailjet`, which posts to the Mailjet
`https://api.mailjet.com/v3.1/send` endpoint with basic auth. It is plain
HTTP, so it runs anywhere `package:http` runs (VM, Flutter, server).

## Guidelines

* Dependency (git, not on pub.dev):
  ```yaml
  dependencies:
    tekartik_mail_mailjet:
      git:
        url: https://github.com/tekartik/mail.dart
        path: packages/mail_mailjet
  ```
  It pulls `tekartik_mail` and `tekartik_mailjet`
  (`https://github.com/alextekartik/http_apis.dart`, `path: packages/mailjet`).
* Single import: `package:tekartik_mail_mailjet/mail_mailjet.dart` re-exports
  `package:tekartik_mail/mail.dart` (`MailMessage`, `MailRecipient`,
  `MailAttachment`, `MailService`, `SendMailResult`), plus `MailjetClient`
  and `MailjetCredentials` from `tekartik_mailjet`, and adds
  `MailjetMailService`. Do not import `src/`.
* Two steps: build a `MailjetClient(apiKey: ..., apiSecret: ...)` then wrap
  it with `MailjetMailService(client: client)`. `MailjetClient` also has the
  (misspelled) `MailjetClient.widthCredentials(MailjetCredentials(apiKey,
  apiSecret), client: httpClient)` constructor taking positional credentials
  and an optional `package:http` `Client`.
* Keys are the Mailjet *API key* and *secret key* of the account: read them
  from the environment or a secret store, never hardcode them. The sender
  address must be a validated Mailjet sender or domain.
* Lifecycle: create the client once and reuse it; `client.close()` closes the
  underlying http client. `MailjetMailService` itself has no `close()` —
  close the `MailjetClient` you passed.
* `supportAttachments` is `true`. `MailAttachment` bytes are base64 encoded
  into the Mailjet `Attachments` entries (`ContentType`, `Filename`,
  `Base64Content`); Mailjet caps the total message size (15 MB by default),
  so send big files as links.
* `message.from` must NOT be null: `sendMail` dereferences it. `to`, `cc`,
  `bcc` map to the Mailjet `To` / `Cc` / `Bcc` lists; `subject` maps to
  `Subject`, `text` to `TextPart` and `html` to `HTMLPart`.
* Caveat: `replyTo` is silently ignored. The service does not fill it, and
  `CvMailjetMessage` in `tekartik_mailjet` has no `ReplyTo` field at all, so
  there is no workaround in these packages: use another backend (for
  instance `tekartik_mail_aws_ses`) when a reply-to address matters.
* `sendMail` returns a `SendMailResult` whose `messageId` is the
  `MessageID` of the first recipient of the first message in the Mailjet
  response. It is null when Mailjet reported an error status for the
  message, so treat a null `messageId` as a failure to investigate. The
  concrete result class is not exported, so the raw Mailjet response (per
  recipient `Status`) is only reachable by calling
  `MailjetClient.sendEmail` directly.
* Transport errors (non 2xx from Mailjet: 401 bad keys, 429 rate limit) are
  thrown by the http layer, not returned; wrap `sendMail` in a
  `try`/`catch (e)` in a background job.
* Advanced Mailjet features (templates via `templateId` /
  `templateLanguage`) are not on `MailMessage`: build a
  `CvMailjetSendEmailRequest` with `CvMailjetMessage` /
  `CvMailjetRecipient` from `package:tekartik_mailjet/mailjet.dart` and call
  `client.sendEmail(request)`. Declare `tekartik_mailjet` in your own
  pubspec when you do. The cv builders are registered by the `MailjetClient`
  constructor (`initMailjetCvBuilders()` if you build models before that).
* Debugging: set the top level `debugMailjet = true` (from
  `package:tekartik_mailjet/mailjet.dart`) BEFORE creating the client to
  print the sent and received json. It logs message content, so keep it out
  of production.
* Testing: no fake is provided. Unit-test message building against your own
  `MailService` implementation (see the `tekartik_mail` package) and keep
  `MailjetMailService` for an integration test gated on real keys.

## Examples

### Send a mail

```dart
import 'dart:io';

import 'package:tekartik_mail_mailjet/mail_mailjet.dart';

Future<void> main() async {
  var env = Platform.environment;
  var client = MailjetClient(
    apiKey: env['MJ_APIKEY_PUBLIC']!,
    apiSecret: env['MJ_APIKEY_PRIVATE']!,
  );
  var service = MailjetMailService(client: client);
  try {
    var result = await service.sendMail(
      MailMessage(
        from: MailRecipient(email: 'no-reply@example.com', name: 'Example'),
        to: [MailRecipient(email: 'user@example.com', name: 'User')],
        subject: 'Hello',
        text: 'Hello from Mailjet.',
        html: '<p>Hello from <b>Mailjet</b>.</p>',
      ),
    );
    if (result.messageId == null) {
      stderr.writeln('mailjet did not accept the message');
      exitCode = 1;
    } else {
      stdout.writeln('sent: ${result.messageId}');
    }
  } finally {
    client.close();
  }
}
```

### Send with an attachment

```dart
import 'dart:io';

import 'package:tekartik_mail_mailjet/mail_mailjet.dart';

Future<SendMailResult> sendInvoice(
  MailjetMailService service,
  String to,
  File pdf,
) {
  return service.sendMail(
    MailMessage(
      from: MailRecipient(email: 'billing@example.com', name: 'Billing'),
      to: [MailRecipient(email: to)],
      bcc: [MailRecipient(email: 'archive@example.com')],
      subject: 'Your invoice',
      text: 'Your invoice is attached.',
      attachments: [
        MailAttachment(
          mimeType: 'application/pdf',
          filename: 'invoice.pdf',
          content: pdf.readAsBytesSync(),
        ),
      ],
    ),
  );
}
```

### Drop to the raw Mailjet request (template)

```dart
import 'package:tekartik_mailjet/mailjet.dart';

/// Sends a Mailjet template, which MailMessage cannot express.
Future<String?> sendTemplate(
  MailjetClient client, {
  required String to,
  required int templateId,
}) async {
  var request = CvMailjetSendEmailRequest()
    ..messages.v = [
      CvMailjetMessage()
        ..from.v = (CvMailjetRecipient()
          ..email.v = 'no-reply@example.com'
          ..name.v = 'Example')
        ..to.v = [CvMailjetRecipient()..email.v = to]
        ..subject.v = 'Hello'
        ..templateId.v = templateId
        ..templateLanguage.v = true,
    ];
  var response = await client.sendEmail(request);
  var first = response.messages.v?.firstOrNull;
  return first?.to.v?.firstOrNull?.messageId.v;
}
```

### Keep the app code backend agnostic

```dart
import 'package:tekartik_mail_mailjet/mail_mailjet.dart';

/// Only the composition root knows about Mailjet.
MailService buildMailService({
  required String apiKey,
  required String apiSecret,
}) {
  return MailjetMailService(
    client: MailjetClient(apiKey: apiKey, apiSecret: apiSecret),
  );
}

Future<void> notify(MailService service, String email, String body) async {
  await service.sendMail(
    MailMessage(
      from: MailRecipient(email: 'no-reply@example.com'),
      to: [MailRecipient(email: email)],
      subject: 'Notification',
      text: body,
    ),
  );
}
```
