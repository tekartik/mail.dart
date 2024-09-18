import 'dart:convert';

import 'package:tekartik_mail/mail.dart';
// ignore: implementation_imports
import 'package:tekartik_mail_tk/src/tkmail_models.dart';

/// Api extension on MailRecipient
extension MailRecipientApiExt on MailRecipient {
  /// Convert to api mail recipient
  ApiMailRecipient toApiMailRecipient() {
    return ApiMailRecipient()
      ..email.v = email
      ..name.v = name;
  }
}

/// Api extension on MailAttachment
extension MailAttachmentExt on MailAttachment {
  /// Convert to api mail attachment
  ApiMailAttachment toApiMailAttachment() {
    return ApiMailAttachment()
      ..base64Content.v = base64Encode(content)
      ..contentType.v = mimeType
      ..filename.v = filename;
  }
}

/// Send mail result from api
class SendMailResultFromApi implements SendMailResult {
  /// Api response
  final ApiSendMailResponse response;

  /// Constructor
  SendMailResultFromApi(this.response);

  @override
  String? get messageId => response.messageId.v;

  @override
  String toString() => 'SendMailResult($messageId)';
}
