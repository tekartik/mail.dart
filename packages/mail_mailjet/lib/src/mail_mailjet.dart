import 'dart:convert';

import 'package:tekartik_mail/mail.dart';
// ignore: implementation_imports
import 'package:tekartik_mail/src/mixin.dart';
import 'package:tekartik_mailjet/mailjet.dart' as mailjet;

/// Reply to not supported yet.
class MailjetMailService with MailServiceMixin implements MailService {
  final mailjet.MailjetClient client;

  /// Attachments are supported.
  @override
  bool get supportAttachments => true;

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

extension MailjetRecipientExt on MailRecipient {
  mailjet.CvMailjetRecipient toMailjetRecipient() {
    return mailjet.CvMailjetRecipient()
      ..email.v = email
      ..name.v = name;
  }
}

extension MailjetAttachmentExt on MailAttachment {
  mailjet.CvMailjetAttachment toMailjetAttachment() {
    return mailjet.CvMailjetAttachment()
      ..base64Content.v = base64Encode(content)
      ..contentType.v = mimeType
      ..filename.v = filename;
  }
}

class SendMailResultMailjet implements SendMailResult {
  final mailjet.CvMailjetSendEmailResponse response;

  SendMailResultMailjet(this.response);

  @override
  String? get messageId =>
      response.messages.v?.firstOrNull?.to.v?.firstOrNull?.messageId.v;
}
