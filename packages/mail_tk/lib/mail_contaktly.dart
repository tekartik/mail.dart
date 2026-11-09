/// The contaktly flavour as a `MailService`: [TkmailContaktlyMailService]
/// asks a timestamp then posts the signed mail to a contaktly endpoint
/// ([TkmailClientContaktly]).
library;

export 'package:tekartik_mail/mail.dart';
export 'package:tekartik_mail_tk/src/mail/mail_contaktly.dart'
    show TkmailContaktlyMailService, TkmailContaktlyServiceOptions;
export 'package:tekartik_mail_tk/src/tkmail_client_contaktly.dart'
    show TkmailClientContaktly;
