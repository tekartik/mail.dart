import 'dart:convert';

import 'package:tekartik_mail/mail.dart';
// ignore: implementation_imports
import 'package:tekartik_mail/src/mixin.dart';
import 'package:tekartik_mailjet/mailjet.dart' as mailjet;

/// Reply to not supported yet.
class MailjetMailService with MailServiceMixin implements MailService {
  /// Mailjet client.
  final mailjet.MailjetClient client;

  /// Attachments are supported.
  @override
  bool get supportAttachments => true;

  /// Mailjet mail service.
  MailjetMailService({required this.client});

  @override
  Future<SendMailResult> sendMail(MailMessage message) async {
    var request = mailjet.CvMailjetSendEmailRequest()
      ..messages.v = [
        mailjet.CvMailjetMessage()
          ..subject.v = message.subject
          ..from.v = message.from!.toMailjetRecipient()
          ..to.v = message.to?.map((e) => e.toMailjetRecipient()).toList()
          ..cc.v = message.cc?.map((e) => e.toMailjetRecipient()).toList()
          ..bcc.v = message.bcc?.map((e) => e.toMailjetRecipient()).toList()
          ..htmlPart.v = message.html
          ..textPart.v = message.text
          ..attachments.v = message.attachments
              ?.map((e) => e.toMailjetAttachment())
              .toList(),
      ];

    var response = await client.sendEmail(request);

    return SendMailResultMailjet(response);
  }
}

/// Mailjet recipient extension.
extension MailjetRecipientExt on MailRecipient {
  /// Convert to Mailjet recipient.
  mailjet.CvMailjetRecipient toMailjetRecipient() {
    return mailjet.CvMailjetRecipient()
      ..email.v = email
      ..name.v = name;
  }
}

/// Mailjet attachment extension.
extension MailjetAttachmentExt on MailAttachment {
  /// Convert to Mailjet attachment.
  mailjet.CvMailjetAttachment toMailjetAttachment() {
    return mailjet.CvMailjetAttachment()
      ..base64Content.v = base64Encode(content)
      ..contentType.v = mimeType
      ..filename.v = filename;
  }
}

/// Send mail result for Mailjet.
class SendMailResultMailjet implements SendMailResult {
  /// Mailjet response.
  final mailjet.CvMailjetSendEmailResponse response;

  /// Send mail result for Mailjet.
  SendMailResultMailjet(this.response);

  @override
  String? get messageId =>
      response.messages.v?.firstOrNull?.to.v?.firstOrNull?.messageId.v;
}
