/// If you use the Http API, this is enough.
library;

export 'package:tekartik_mail/mail.dart';
export 'src/tkmail_client.dart' show TkmailClient, debugTkmailApi;
export 'src/tkmail_models.dart'
    show
        ApiSendMailRequest,
        ApiSendMailResponse,
        ApiMailAttachment,
        ApiMailMessage,
        ApiMailRecipient,
        initTkmailBuilders;
