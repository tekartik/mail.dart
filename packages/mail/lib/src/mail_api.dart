// TODO: Put public facing types in this file.

import 'dart:typed_data';

/// Mail message.
class MailMessage {
  final MailRecipient? from;
  final List<MailRecipient>? to;
  final List<MailRecipient>? cc;
  final List<MailRecipient>? bcc;
  final List<MailRecipient>? replyTo;
  final String subject;
  final String? text;
  final String? html;
  final List<MailAttachment>? attachments;

  MailMessage({
    required this.from,
    this.to,
    this.cc,
    this.bcc,
    required this.subject,
    this.text,
    this.html,
    this.attachments,
    this.replyTo,
  });
}

/// Abstract mail service
abstract class MailService {
  /// Not all services might support attachments...
  bool get supportAttachments;

  /// Send an email.
  Future<SendMailResult> sendMail(MailMessage message);
}

/// Send mail response.
abstract class SendMailResult {
  String? get messageId;
}

/// Attachment.
class MailAttachment {
  final String mimeType;
  final String filename;
  final Uint8List content;

  MailAttachment(
      {required this.mimeType, required this.filename, required this.content});
}
/*
// {
// // //           "Email": "passenger@mailjet.com",
// // //           "MessageID": "1234567890987654321",
// // //           "MessageHref": "https://api.mailjet.com/v3/message/1234567890987654321"
// // //         }
class CvMailjetRecipientResponse extends CvModelBase {
  late final email = CvField<String>('Email');
  late final messageId = CvField<String>('MessageID');
  late final messageHref = CvField<String>('MessageHref');
  @override
  CvFields get fields => [email, messageId, messageHref];
}

//curl -s \
// 	-X POST \
// 	--user "$MJ_APIKEY_PUBLIC:$MJ_APIKEY_PRIVATE" \
// 	https://api.mailjet.com/v3.1/send \
// 	-H 'Content-Type: application/json' \
// 	-d '{
// 		"Messages":[
// 				{
// 						"From": {
// 								"Email": "$SENDER_EMAIL",
// 								"Name": "Me"
// 						},
// 						"To": [
// 								{
// 										"Email": "$RECIPIENT_EMAIL",
// 										"Name": "You"
// 								}
// 						],
// 						"Subject": "My first Mailjet Email!",
// 						"TextPart": "Greetings from Mailjet!",
// 						"HTMLPart": "<h3>Dear passenger 1, welcome to <a href=\"https://www.mailjet.com/\">Mailjet</a>!</h3><br />May the delivery force be with you!"
// 				}
// 		]
// 	}'
class CvMailjetSendEmailRequest extends CvModelBase {
  late final messages = CvModelListField<CvMailjetMessage>('Messages');

  @override
  CvFields get fields => [messages];
}

// {
// // 						"From": {
// // 								"Email": "$SENDER_EMAIL",
// // 								"Name": "Me"
// // 						},
// // 						"To": [
// // 								{
// // 										"Email": "$RECIPIENT_EMAIL",
// // 										"Name": "You"
// // 								}
// // 						],
// // 						"Subject": "My first Mailjet Email!",
// // 						"TextPart": "Greetings from Mailjet!",
// // 						"HTMLPart": "<h3>Dear passenger 1, welcome to <a href=\"https://www.mailjet.com/\">Mailjet</a>!</h3><br />May the delivery force be with you!"
// // "TextPart": "Dear passenger 1, welcome to Mailjet! May the delivery force be with you!",
// 						"HTMLPart": "<h3>Dear passenger 1, welcome to <a href=\"https://www.mailjet.com/\">Mailjet</a>!</h3><br />May the delivery force be with you!",
// 						"Attachments": [
// 								{
// 										"ContentType": "text/plain",
// 										"Filename": "test.txt",
// 										"Base64Content": "VGhpcyBpcyB5b3VyIGF0dGFjaGVkIGZpbGUhISEK"
// 								}
// 						]
// // 				}
class CvMailjetMessage extends CvModelBase {
  late final from = CvModelField<CvMailjetRecipient>('From');
  late final to = CvModelListField<CvMailjetRecipient>('To');
  late final cc = CvModelListField<CvMailjetRecipient>('Cc');
  late final bcc = CvModelListField<CvMailjetRecipient>('Bcc');
  late final subject = CvField<String>('Subject');
  late final textPart = CvField<String>('TextPart');
  late final htmlPart = CvField<String>('HTMLPart');
  late final attachments = CvModelListField<CvMailjetAttachment>('Attachments');
  @override
  late final fields = [
    from,
    to,
    cc,
    bcc,
    subject,
    textPart,
    htmlPart,
    attachments
  ];
}

/// "Attachments": [
// 								{
// 										"ContentType": "text/plain",
// 										"Filename": "test.txt",
// 										"Base64Content": "VGhpcyBpcyB5b3VyIGF0dGFjaGVkIGZpbGUhISEK"
// 								}
// 						]
class MailAttachment  {
  final String mimeType = CvField<String>('ContentType');
  late final filename = CvField<String>('Filename');
  late final base64Content = CvField<String>('Base64Content');
  @override
  late final fields = [contentType, filename, base64Content];
}
*/

/// Mail recipient.
class MailRecipient {
  final String email;
  final String? name;

  MailRecipient({required this.email, this.name});

  @override
  String toString() {
    if (name?.isNotEmpty ?? false) {
      return '$name <$email>';
    } else {
      return email;
    }
  }

  @override
  int get hashCode => email.hashCode + (name?.hashCode ?? 0);

  @override
  bool operator ==(Object other) {
    if (other is MailRecipient) {
      return email == other.email && name == other.name;
    }
    return false;
  }
}
