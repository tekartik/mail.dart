// TODO: Put public facing types in this file.

/// Abstract mail service
abstract class MailService {}

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
  List<CvField<Object?>> get fields => [email, messageId, messageHref];
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
  List<CvField<Object?>> get fields => [messages];
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
class MailRecipient {
  final String email;
  final String? name;

  MailRecipient({required this.email, required this.name});
}
