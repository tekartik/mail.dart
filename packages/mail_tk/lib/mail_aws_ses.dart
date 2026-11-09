/// The aws_ses flavour as a `MailService`: [TkmailAwsSesMailService] posts
/// each mail, with the AWS region and credentials, to a tkmail endpoint
/// ([TkmailClientAwsSes]) that relays it to SES. Server side only.
library;

export 'package:tekartik_mail/mail.dart';
export 'package:tekartik_mail_tk/mail_tk_aws_ses.dart' show TkmailClientAwsSes;
export 'package:tekartik_mail_tk/src/mail/mail_aws_ses.dart'
    show
        TkmailAwsSesMailService,
        TkmailAwsSesMailServiceOptions,
        TkmailAwsSesCredentials;
