---
name: tekartik-mail-aws-ses-setup
description: >-
  Use when sending email with Amazon SES from pure Dart (VM, Flutter, server)
  through tekartik_mail_aws_ses: MailServiceAwsSes, MailServiceOptionsAwsSes,
  MailCredentialsAwsSes (accessKeyId, secretAccessKey, sessionToken),
  SendMailResultAwsSes, the package:tekartik_mail_aws_ses/mail_aws_ses.dart
  import, the SES v2 outbound-emails endpoint signed with aws_signature_v4,
  attachments, service.close(), and unit tests with MockAWSHttpClient.
---

# AWS SES mail service (tekartik_mail_aws_ses)

`tekartik_mail_aws_ses` implements the `tekartik_mail` `MailService`
interface on top of the Amazon SES v2 `SendEmail` REST endpoint, signing each
request with `package:aws_signature_v4`. It is pure Dart (no AWS SDK, no
node): it runs on the Dart VM, on a server and in Flutter.

## Guidelines

* Dependency (git, not on pub.dev):
  ```yaml
  dependencies:
    tekartik_mail_aws_ses:
      git:
        url: https://github.com/tekartik/mail.dart
        path: packages/mail_aws_ses
  ```
  It pulls `tekartik_mail`, `aws_signature_v4` and `aws_common`.
* One import does everything:
  `package:tekartik_mail_aws_ses/mail_aws_ses.dart` re-exports
  `package:tekartik_mail/mail.dart` (`MailMessage`, `MailRecipient`,
  `MailAttachment`, `MailService`, `SendMailResult`) and adds
  `MailServiceAwsSes`, `MailServiceOptionsAwsSes`, `MailCredentialsAwsSes`
  and `SendMailResultAwsSes`. Do not import `src/`.
* Build the service once and keep it: `MailServiceAwsSes(options:
  MailServiceOptionsAwsSes(region: ..., credentials:
  MailCredentialsAwsSes(accessKeyId: ..., secretAccessKey: ...,
  sessionToken: ...)))`. `sessionToken` is optional (only for STS / temporary credentials; it is
  sent as `X-Amz-Security-Token`). Type your app fields as `MailService` so
  the backend stays swappable.
* Never hardcode `accessKeyId` / `secretAccessKey`: read them from the
  environment (`Platform.environment`), a secret manager or a config file
  kept out of git. There is no AWS credential-chain lookup here — whatever
  you pass is what gets signed.
* `region` picks the endpoint,
  `https://email.<region>.amazonaws.com/v2/email/outbound-emails`. It must be
  a region where the sending identity is verified.
* `close()` closes the underlying `AWSHttpClient`; call it when the service
  is no longer needed (end of a CLI run, dispose of a provider). The service
  stays usable for many `sendMail` calls before that.
* `message.from` must NOT be null: `sendMail` dereferences it
  (`message.from!`) to fill `FromEmailAddress`, and the address must be a
  verified SES identity. `to`, `cc`, `bcc` and `replyTo` are only sent when
  non-null and non-empty. In the SES sandbox every recipient must be
  verified too.
* Recipients are serialized as `email` alone, or as
  `=?utf-8?B?<base64>?= <email>` when `name` is set — RFC 2047, so non-ASCII
  display names are safe. Subject, text and html are sent with charset
  `UTF-8`.
* `supportAttachments` is `true`: `MailAttachment` entries go to the SES
  `Content.Simple.Attachments` list as `FileName` / `ContentType` /
  `RawContent` (base64). Keep the total message under the SES 40 MB raw
  limit, base64 included.
* Both `text` and `html` are optional but SES rejects an empty body; always
  set at least one.
* On HTTP 2xx `sendMail` returns a `SendMailResultAwsSes` whose `messageId`
  is the SES `MessageId`. On anything else it throws a plain `Exception`
  carrying the status code and the raw response body (`AccessDenied`,
  `MessageRejected`, throttling...). Catch `Exception`, log the message, and
  retry with backoff on throttling; there is no typed error class.
* Testing: pass `client:` an `AWSHttpClient`. `MockAWSHttpClient` from
  `package:aws_common/testing.dart` lets you capture the signed
  `AWSHttpRequest` and return a canned `AWSHttpResponse` without touching
  the network — that is how the package tests itself (`dart test`).
* For a Node/Cloud Functions target using the AWS JS SDK instead, use the
  `tekartik_mail_aws_ses_node` package; for the abstract model and mixins
  used here, see `tekartik_mail`.

## Examples

### Send a mail from a CLI, credentials from the environment

```dart
import 'dart:io';

import 'package:tekartik_mail_aws_ses/mail_aws_ses.dart';

Future<void> main() async {
  var env = Platform.environment;
  var service = MailServiceAwsSes(
    options: MailServiceOptionsAwsSes(
      region: env['AWS_REGION'] ?? 'eu-west-1',
      credentials: MailCredentialsAwsSes(
        accessKeyId: env['AWS_ACCESS_KEY_ID']!,
        secretAccessKey: env['AWS_SECRET_ACCESS_KEY']!,
        sessionToken: env['AWS_SESSION_TOKEN'],
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
        text: 'Hello from SES.',
        html: '<p>Hello from <b>SES</b>.</p>',
      ),
    );
    stdout.writeln('sent: ${result.messageId}');
  } on Exception catch (e) {
    stderr.writeln('send failed: $e');
    exitCode = 1;
  } finally {
    service.close();
  }
}
```

### Send with an attachment

```dart
import 'dart:io';

import 'package:tekartik_mail_aws_ses/mail_aws_ses.dart';

Future<SendMailResult> sendReport(
  MailServiceAwsSes service,
  String to,
  File report,
) async {
  return service.sendMail(
    MailMessage(
      from: MailRecipient(email: 'reports@example.com', name: 'Rapports'),
      to: [MailRecipient(email: to)],
      subject: 'Daily report',
      text: 'The report is attached.',
      attachments: [
        MailAttachment(
          mimeType: 'application/pdf',
          filename: 'report.pdf',
          content: await report.readAsBytes(),
        ),
      ],
    ),
  );
}
```

### Unit test without network access

```dart
import 'dart:convert';

import 'package:aws_common/aws_common.dart';
import 'package:aws_common/testing.dart';
import 'package:tekartik_mail_aws_ses/mail_aws_ses.dart';
import 'package:test/test.dart';

void main() {
  test('sendMail', () async {
    AWSHttpRequest? sentRequest;
    var client = MockAWSHttpClient((request, isCancelled) async {
      sentRequest = request;
      return AWSHttpResponse(
        statusCode: 200,
        body: utf8.encode('{"MessageId": "test-msg-id"}'),
      );
    });
    var service = MailServiceAwsSes(
      options: MailServiceOptionsAwsSes(
        region: 'us-east-1',
        credentials: MailCredentialsAwsSes(
          accessKeyId: 'dummy-key-id',
          secretAccessKey: 'dummy-secret',
        ),
      ),
      client: client,
    );
    var result = await service.sendMail(
      MailMessage(
        from: MailRecipient(email: 'sender@example.com'),
        to: [MailRecipient(email: 'to@example.com')],
        subject: 'Hello',
        text: 'Body',
      ),
    );
    expect(result.messageId, 'test-msg-id');
    expect(
      sentRequest!.uri.toString(),
      'https://email.us-east-1.amazonaws.com/v2/email/outbound-emails',
    );
    expect(sentRequest!.headers, contains('Authorization'));
  });
}
```

### Turn an SES failure into a typed result

```dart
import 'package:tekartik_mail_aws_ses/mail_aws_ses.dart';

/// Sends and never throws, for a background queue.
Future<String?> trySend(MailService service, MailMessage message) async {
  try {
    var result = await service.sendMail(message);
    return result.messageId; // null when SES did not return an id.
  } on Exception catch (e) {
    // The message text holds the SES status code and raw body.
    print('SES send failed: $e');
    return null;
  }
}
```
