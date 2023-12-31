import 'dart:convert';

import 'package:tekartik_mail/mail.dart';
// ignore: implementation_imports
import 'package:tekartik_mail_tk/src/tkmail_models.dart';

extension MailjetRecipientExt on MailRecipient {
  ApiMailRecipient toApiMailRecipient() {
    return ApiMailRecipient()
      ..email.v = email
      ..name.v = name;
  }
}

extension MailAttachmentExt on MailAttachment {
  ApiMailAttachment toApiMailAttachment() {
    return ApiMailAttachment()
      ..base64Content.v = base64Encode(content)
      ..contentType.v = mimeType
      ..filename.v = filename;
  }
}

class SendMailResultFromApi implements SendMailResult {
  final ApiSendMailResponse response;

  SendMailResultFromApi(this.response);

  @override
  String? get messageId => response.messageId.v;

  @override
  String toString() => 'SendMailResult($messageId)';
}
