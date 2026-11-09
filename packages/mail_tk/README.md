# tekartik_mail_tk

The client side of a tkmail endpoint: a `MailService` (`tekartik_mail`) that
POSTs each mail as json to an http endpoint of your own, which sends it. Two
flavours:

* `aws_ses`: the endpoint relays the mail to AWS SES with the region and
  credentials given in each request
  (`package:tekartik_mail_tk/mail_aws_ses.dart`);
* `contaktly`: a contaktly endpoint, a timestamp then a signed request
  (`package:tekartik_mail_tk/mail_contaktly.dart`).

## Getting started

Git package, not on pub.dev:

```yaml
dependencies:
  tekartik_mail_tk:
    git:
      url: https://github.com/tekartik/mail.dart
      path: packages/mail_tk
```

```dart
import 'dart:io';

import 'package:tekartik_mail_tk/mail_aws_ses.dart';

Future<void> main() async {
  var env = Platform.environment;
  var client = TkmailClientAwsSes(uri: Uri.parse('https://mail.example.com/api'));
  MailService service = TkmailAwsSesMailService(
    client: client,
    options: TkmailAwsSesMailServiceOptions(
      region: 'eu-west-1',
      credentials: TkmailAwsSesCredentials(
        accessKeyId: env['AWS_ACCESS_KEY_ID']!,
        secretAccessKey: env['AWS_SECRET_ACCESS_KEY']!,
      ),
    ),
  );
  try {
    var result = await service.sendMail(
      MailMessage(
        from: MailRecipient(email: 'no-reply@example.com'),
        to: [MailRecipient(email: 'user@example.com')],
        subject: 'Hello',
        text: 'Hello from tkmail',
      ),
    );
    print(result.messageId);
  } finally {
    client.close();
  }
}
```

Platforms: any Dart with `package:http` (VM, node, Flutter, web). The aws_ses
flavour carries AWS credentials: use it from a server only.
[example/main.dart](example/main.dart) sends one mail.

## Common pitfalls

* The aws_ses flavour sends the AWS key id and secret in every request
  body: an https endpoint you own only, and an IAM user limited to SES.
* `debugTkmailApi = true` (set before creating the client) prints the json
  sent and received: the mail content in clear, the `secretAccessKey` as
  `***`.
* Errors: a non 2xx answer throws an `HttpClientException`
  (`package:tekartik_http/http_client.dart`); a contaktly error answer
  throws the `ApiErrorContaktly` model, which is not an `Exception`.
* `supportAttachments` says `false`, yet both flavours send the
  attachments.
* `client.close()` also closes the `client:` http client you passed.

More: the skills [tekartik-mail-tk-api](skills/tekartik-mail-tk-api/SKILL.md),
[tekartik-mail-tk-aws-ses](skills/tekartik-mail-tk-aws-ses/SKILL.md) and
[tekartik-mail-tk-contaktly](skills/tekartik-mail-tk-contaktly/SKILL.md).
