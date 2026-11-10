/// Mail service on the Mailjet http api: [MailjetMailService] built on a
/// [MailjetClient] (api key and secret).
library;

export 'package:tekartik_mail/mail.dart';
export 'package:tekartik_mailjet/mailjet.dart'
    show MailjetClient, MailjetCredentials;
export 'src/mail_mailjet.dart' show MailjetMailService;
