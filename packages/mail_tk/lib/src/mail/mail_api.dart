import 'dart:convert';

import 'package:tekartik_mail/mail.dart';
// ignore: implementation_imports
import 'package:tekartik_mail_tk/src/tkmail_models.dart';

/// Api extension on ApiMailRecipient
extension ApiMailRecipientExt on ApiMailRecipient {
  /// Convert to mail recipient
  MailRecipient toMailRecipient() {
    return MailRecipient(email: email.v!, name: name.v);
  }
}

/// Api extension on MailMessage
extension MailMessageApiExt on MailMessage {
  /// Convert to api mail message
  ApiMailMessage toApiMailMessage() => ApiMailMessage()
    ..subject.v = subject
    ..from.v = from?.toApiMailRecipient()
    ..to.v = to?.map((e) => e.toApiMailRecipient()).toList()
    ..cc.v = cc?.map((e) => e.toApiMailRecipient()).toList()
    ..bcc.v = bcc?.map((e) => e.toApiMailRecipient()).toList()
    ..replyTo.v = replyTo?.map((e) => e.toApiMailRecipient()).toList()
    ..html.v = html
    ..text.v = text
    ..attachments.v = attachments?.map((e) => e.toApiMailAttachment()).toList();
}

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
extension MailAttachmentApiExt on MailAttachment {
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
