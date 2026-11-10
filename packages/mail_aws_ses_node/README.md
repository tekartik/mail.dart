# tekartik_mail_aws_ses_node

The [tekartik_mail](../mail) `MailService` on AWS SES for Dart compiled to
JavaScript and run by Node.js (a cloud function, a node server), on top of
[tekartik_aws_ses_node](https://github.com/tekartik/amazon_node.dart) and
the `@aws-sdk/client-ses` npm module. For the Dart VM or Flutter use
`tekartik_mail_aws_ses` (same repository, pure Dart).

## Getting started

Not on pub.dev, add it as a git dependency:

```yaml
dependencies:
  tekartik_mail_aws_ses_node:
    git:
      url: https://github.com/tekartik/mail.dart
      path: packages/mail_aws_ses_node
```

and `@aws-sdk/client-ses` to the `package.json` of the node app.

```dart
import 'package:tekartik_mail_aws_ses_node/mail_aws_ses_node.dart';

Future<String?> sendWelcome(String accessKeyId, String secretAccessKey) async {
  var service = AwsSesMailService(
    options: AwsSesMailServiceOptions(
      region: 'eu-west-1',
      credentials: AwsSesCredentials(
        accessKeyId: accessKeyId,
        secretAccessKey: secretAccessKey,
      ),
    ),
  );
  var result = await service.sendMail(
    MailMessage(
      from: MailRecipient(email: 'no-reply@example.com', name: 'Example'),
      to: [MailRecipient(email: 'someone@example.com')],
      subject: 'Welcome',
      text: 'Welcome on board.',
    ),
  );
  return result.messageId;
}
```

Read the credentials from the function configuration or the environment,
never from the source.

## Platforms

Node.js only (dart2js). On the Dart VM or in a browser, `sendMail` throws an
`UnsupportedError`.

## Common pitfalls

* `from` is required and must be a verified SES identity of the region.
* Display names are encoded (RFC 2047), any language is fine.
* Attachments are supported (`supportAttachments` is true): the mail is
  then sent as a raw MIME message, an address or a mime type holding a
  CR/LF is rejected (`AwsSesException`).
* Build the service once and reuse it: the SES client is created on the
  first `sendMail`.
