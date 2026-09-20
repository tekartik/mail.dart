---
name: tekartik-mail-api
description: >-
  Use when sending email through the abstract tekartik_mail API or when
  implementing/mocking a mail backend: MailService, sendMail, MailMessage
  (from, to, cc, bcc, replyTo, subject, text, html, attachments),
  MailRecipient, MailAttachment, SendMailResult.messageId, the
  MailServiceMixin and supportAttachments, validateEmail, and the
  package:tekartik_mail/mail.dart, mail_mixin.dart and utils/mail_utils.dart
  imports.
---

# Abstract mail API (tekartik_mail)

`tekartik_mail` is a tiny provider-agnostic email API: a `MailService`
interface, the message model it takes, and an email validation helper. It has
no dependency and no implementation of its own; concrete senders live in
separate packages (`tekartik_mail_aws_ses`, `tekartik_mail_aws_ses_node`,
`tekartik_mail_mailjet`, `tekartik_mail_tk`).

## Guidelines

* Dependency (git, not on pub.dev):
  ```yaml
  dependencies:
    tekartik_mail:
      git:
        url: https://github.com/tekartik/mail.dart
        path: packages/mail
  ```
* Imports:
  * `package:tekartik_mail/mail.dart` exports the whole model:
    `MailService`, `MailMessage`, `MailRecipient`, `MailAttachment`,
    `SendMailResult`. That is the only import application code needs.
  * `package:tekartik_mail/mail_mixin.dart` re-exports `mail.dart` and adds
    `MailServiceMixin`; import it (instead of `mail.dart`) when writing a
    `MailService` implementation.
  * `package:tekartik_mail/utils/mail_utils.dart` adds the standalone
    `validateEmail(String value)` function. It is not re-exported by
    `mail.dart`; import it explicitly.
* Write shared code against `MailService` and inject the concrete service at
  the edge of the app. `MailService` has exactly two members:
  `bool get supportAttachments` and
  `Future<SendMailResult> sendMail(MailMessage message)`.
* `MailMessage` is immutable and built entirely in its constructor; there are
  no setters and no `copyWith`. `from` and `subject` are the only required
  named parameters — `from` is required but nullable, so pass
  `from: null` explicitly when the backend defines the sender itself (some
  services do, e.g. a server-side template sender).
* `to`, `cc`, `bcc`, `replyTo` are `List<MailRecipient>?`: null and `[]` are
  both "none", but prefer null for "not set". Provide at least one of `text`
  and `html`; passing both lets the client pick.
* `MailRecipient(email: ..., name: ...)` has value equality on
  `(email, name)` and a `toString()` of `'Name <email>'`, or just `email`
  when `name` is null or empty. Use `toString()` when building a raw header,
  do not concatenate by hand.
* `MailAttachment(mimeType:, filename:, content:)` takes raw bytes as a
  `Uint8List` (`import 'dart:typed_data'`), never a base64 string: each
  backend encodes for its own wire format. Check `supportAttachments` before
  attaching anything — a service that returns false may silently drop them
  or throw.
* `SendMailResult` is abstract with a single nullable `messageId`; each
  implementation returns its own class. Never construct or `as`-cast it to a
  backend type in shared code, and treat a null `messageId` as "sent, id
  unknown" rather than a failure. Failures are thrown, not returned.
* Implementations: `class MyMailService with MailServiceMixin` gets
  `supportAttachments => false` for free and only has to implement
  `sendMail`; override `supportAttachments` when the backend does support
  them. The mixin has no `on` clause, so it applies to any class.
* `validateEmail` is a regex `hasMatch` and is NOT anchored: it accepts any
  string that *contains* an address, and it requires a dotted domain
  (`'a@b'` is false, `'a@b.c'` is true). Trim and reject whitespace yourself
  before trusting it, and use it for input hints only — never as proof that
  an address is deliverable.
* Testing: the package ships no fake. Write a small recording service with
  `MailServiceMixin` (see the last example) and assert on the captured
  `MailMessage`s instead of hitting a real provider. Run `dart test`.

## Examples

### A reusable in-memory service

```dart
import 'package:tekartik_mail/mail_mixin.dart';

/// Result of an in-memory send.
class MemorySendMailResult implements SendMailResult {
  @override
  final String? messageId;

  MemorySendMailResult(this.messageId);
}

/// Collects messages instead of sending them.
class MemoryMailService with MailServiceMixin {
  final sentMessages = <MailMessage>[];

  @override
  bool get supportAttachments => true;

  @override
  Future<SendMailResult> sendMail(MailMessage message) async {
    sentMessages.add(message);
    return MemorySendMailResult('memory-${sentMessages.length}');
  }
}
```

### Building and sending a message

```dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:tekartik_mail/mail.dart';

Future<String?> sendInvoice(
  MailService service,
  String customerEmail,
  String csv,
) async {
  var message = MailMessage(
    from: MailRecipient(email: 'no-reply@example.com', name: 'Example Shop'),
    to: [MailRecipient(email: customerEmail)],
    bcc: [MailRecipient(email: 'archive@example.com')],
    replyTo: [MailRecipient(email: 'support@example.com')],
    subject: 'Your invoice',
    text: 'Your invoice is attached.',
    html: '<p>Your invoice is attached.</p>',
    attachments: service.supportAttachments
        ? [
            MailAttachment(
              mimeType: 'text/csv',
              filename: 'invoice.csv',
              content: Uint8List.fromList(utf8.encode(csv)),
            ),
          ]
        : null,
  );
  var result = await service.sendMail(message);
  return result.messageId;
}
```

### Filtering user input before building recipients

```dart
import 'package:tekartik_mail/mail.dart';
import 'package:tekartik_mail/utils/mail_utils.dart';

/// Keeps only the entries that look like a single email address.
List<MailRecipient> parseRecipients(Iterable<String> input) {
  var recipients = <MailRecipient>[];
  for (var raw in input) {
    var email = raw.trim();
    if (email.isEmpty || email.contains(RegExp(r'\s'))) {
      continue; // validateEmail is not anchored, reject spaces first.
    }
    if (validateEmail(email)) {
      recipients.add(MailRecipient(email: email));
    }
  }
  return recipients;
}
```

### Testing code that sends mail

```dart
import 'package:tekartik_mail/mail_mixin.dart';
import 'package:test/test.dart';

class _RecordingMailService with MailServiceMixin {
  final sent = <MailMessage>[];

  @override
  Future<SendMailResult> sendMail(MailMessage message) async {
    sent.add(message);
    return _RecordingSendMailResult('test-${sent.length}');
  }
}

class _RecordingSendMailResult implements SendMailResult {
  @override
  final String? messageId;

  _RecordingSendMailResult(this.messageId);
}

void main() {
  test('sendMail', () async {
    var service = _RecordingMailService();
    var result = await service.sendMail(
      MailMessage(
        from: MailRecipient(email: 'from@example.com', name: 'From'),
        to: [MailRecipient(email: 'to@example.com')],
        subject: 'Hi',
        text: 'Hello',
      ),
    );
    expect(result.messageId, 'test-1');
    expect(service.supportAttachments, isFalse);
    var message = service.sent.single;
    expect(message.from.toString(), 'From <from@example.com>');
    expect(message.to!.single, MailRecipient(email: 'to@example.com'));
  });
}
```
