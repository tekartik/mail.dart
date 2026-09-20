---
name: tekartik-mail-tk-api
description: >-
  Use when reading or writing the tkmail http wire format of tekartik_mail_tk:
  ApiSendMailRequest, ApiSendMailResponse, ApiMailMessage, ApiMailRecipient,
  ApiMailAttachment, initTkmailBuilders, the TkmailClient base class and its
  send/close, SendMailResultFromApi, debugTkmailApi, and the
  toApiMailMessage / toApiMailRecipient / toApiMailAttachment /
  toMailRecipient / toMailAttachment cv extensions — including implementing
  the server side of the endpoint.
---

# Tkmail wire API and client base (tekartik_mail_tk)

`tekartik_mail_tk` sends mail through a small http endpoint of your own: the
client posts a json `ApiSendMailRequest` and reads back an
`ApiSendMailResponse`. The models are `cv` models, and extensions convert
them to and from the `tekartik_mail` `MailMessage` on both sides. Concrete
clients live in the `tekartik-mail-tk-aws-ses` and
`tekartik-mail-tk-contaktly` skills of this package.

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
* Imports, pick the smallest that fits:
  * `package:tekartik_mail_tk/mail.dart` — only re-exports
    `package:tekartik_mail/mail.dart`, for code that just uses a
    `MailService`.
  * `package:tekartik_mail_tk/mail_tk.dart` — the http api: the models
    above, `initTkmailBuilders`, `TkmailClient`, `debugTkmailApi`,
    `SendMailResultFromApi` and the conversion extensions, plus the
    `tekartik_mail` model.
  * Never import `package:tekartik_mail_tk/src/...`.
* Call `initTkmailBuilders()` once before decoding a map into a model
  (`map.cv<ApiSendMailRequest>()`). It is idempotent, and the `TkmailClient`
  constructor already calls it, so only a server or a test needs it
  explicitly. Decoding needs `package:cv/cv.dart` imported for the `cv<T>()`
  and `toMap()` extensions.
* Wire shape: `{"message": {"from": {"email", "name"}, "to": [...], "cc":
  [...], "bcc": [...], "replyTo": [...], "subject", "text", "html",
  "attachments": [{"mimeType", "filename", "base64Content"}]}}`, and the
  response is `{"messageId": "..."}`. Note `ApiMailAttachment.contentType`
  is the Dart field name but the json key is `mimeType`.
* Conversions (all extension methods, import `mail_tk.dart`):
  `MailMessage.toApiMailMessage()`, `MailRecipient.toApiMailRecipient()`,
  `MailAttachment.toApiMailAttachment()` (base64 encodes the bytes) on the
  sending side; `ApiMailRecipient.toMailRecipient()` and
  `ApiMailAttachment.toMailAttachment()` (base64 decodes) on the receiving
  side. There is no `ApiMailMessage.toMailMessage()`: rebuild the
  `MailMessage` field by field, as in the first example.
* `TkmailClient` is abstract: subclass it, override the `uri` getter, and use
  the inherited `send(uri, map)` which POSTs json and returns the decoded
  `Map`. Its constructor takes an optional `client:` `package:http` `Client`
  (handy to inject a mock). Call `close()` when done to close that http
  client.
* `send` throws on a non 2xx status (it goes through `httpClientRead` of
  `tekartik_http`); it does not wrap errors in a typed exception.
* `SendMailResultFromApi(response)` adapts an `ApiSendMailResponse` to the
  `SendMailResult` returned by `MailService.sendMail`; `messageId` is
  whatever the server put in the response, possibly null.
* Set the top level `debugTkmailApi = true` BEFORE constructing the client
  to print the request uri, the sent json and the received json — the flag
  is captured at construction time. It logs mail content, keep it off in
  production.
* Nothing here validates or authenticates: the transport is plain json over
  http. Never put AWS or account credentials in `ApiSendMailRequest` unless
  the endpoint is yours and https (the aws_ses variant does exactly that,
  see `tekartik-mail-tk-aws-ses`).
* Testing: the package tests just fill the models
  (`ApiSendMailRequest()..fillModel(CvFillOptions(collectionSize: 1,
  valueStart: 0))`) and compare `toMap()`; do the same for a custom model,
  and inject a fake `http.Client` into a `TkmailClient` subclass for
  client tests. Run `dart test`.

## Examples

### Server side: turn a request into a MailMessage and send it

```dart
import 'package:cv/cv.dart';
import 'package:tekartik_mail_tk/mail_tk.dart';

/// Handles a POSTed tkmail body with any concrete [MailService].
Future<Map<String, Object?>> handleSendMail(
  MailService service,
  Map<String, Object?> body,
) async {
  initTkmailBuilders();
  var apiMessage = body.cv<ApiSendMailRequest>().message.v!;
  var message = MailMessage(
    from: apiMessage.from.v?.toMailRecipient(),
    to: apiMessage.to.v?.map((e) => e.toMailRecipient()).toList(),
    cc: apiMessage.cc.v?.map((e) => e.toMailRecipient()).toList(),
    bcc: apiMessage.bcc.v?.map((e) => e.toMailRecipient()).toList(),
    replyTo: apiMessage.replyTo.v?.map((e) => e.toMailRecipient()).toList(),
    subject: apiMessage.subject.v!,
    text: apiMessage.text.v,
    html: apiMessage.html.v,
    attachments: apiMessage.attachments.v
        ?.map((e) => e.toMailAttachment())
        .toList(),
  );
  var result = await service.sendMail(message);
  return (ApiSendMailResponse()..messageId.v = result.messageId).toMap();
}
```

### A custom client for your own endpoint

```dart
import 'package:cv/cv.dart';
import 'package:tekartik_mail_tk/mail_tk.dart';

/// Posts the plain tkmail request to a single endpoint.
class MyTkmailClient extends TkmailClient {
  @override
  final Uri uri;

  MyTkmailClient({required this.uri, super.client});

  Future<ApiSendMailResponse> sendEmail(ApiSendMailRequest request) async {
    var response = await send(uri, request.toMap());
    return response.cv<ApiSendMailResponse>();
  }
}
```

### A MailService on top of that client

```dart
import 'package:tekartik_mail/mail_mixin.dart';
import 'package:tekartik_mail_tk/mail_tk.dart';

/// Any client exposing sendEmail can back a MailService.
class MyTkmailMailService with MailServiceMixin implements MailService {
  final Future<ApiSendMailResponse> Function(ApiSendMailRequest request)
  sendEmail;

  MyTkmailMailService(this.sendEmail);

  @override
  bool get supportAttachments => true;

  @override
  Future<SendMailResult> sendMail(MailMessage message) async {
    var request = ApiSendMailRequest()..message.v = message.toApiMailMessage();
    return SendMailResultFromApi(await sendEmail(request));
  }
}
```

### Model round trip in a test

```dart
import 'package:cv/cv.dart';
import 'package:tekartik_mail_tk/mail_tk.dart';
import 'package:test/test.dart';

void main() {
  initTkmailBuilders();
  test('message round trip', () {
    var message = MailMessage(
      from: MailRecipient(email: 'from@example.com', name: 'From'),
      to: [MailRecipient(email: 'to@example.com')],
      subject: 'Hello',
      text: 'Body',
    );
    var map = (ApiSendMailRequest()..message.v = message.toApiMailMessage())
        .toMap();
    expect((map['message'] as Map)['subject'], 'Hello');
    var decoded = map.cv<ApiSendMailRequest>();
    expect(
      decoded.message.v!.from.v!.toMailRecipient(),
      MailRecipient(email: 'from@example.com', name: 'From'),
    );
  });
}
```
