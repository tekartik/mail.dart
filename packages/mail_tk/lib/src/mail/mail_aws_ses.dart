import 'package:tekartik_mail/mail.dart';
// ignore: implementation_imports
import 'package:tekartik_mail/src/mixin.dart';
import 'package:tekartik_mail_tk/src/mail/mail.dart';
import 'package:tekartik_mail_tk/src/tkmail_models_aws_ses.dart';
import 'package:tekartik_mail_tk/mail_tk_aws_ses.dart';

/// Service credentials.
class TkmailAwsSesCredentials {
  final String accessKeyId;
  final String secretAccessKey;

  TkmailAwsSesCredentials(
      {required this.accessKeyId, required this.secretAccessKey});
}

/// Service options.
class TkmailAwsSesMailServiceOptions {
  final String region;
  final TkmailAwsSesCredentials credentials;

  TkmailAwsSesMailServiceOptions(
      {required this.region, required this.credentials});
}

/// Http api
class TkmailAwsSesMailService with MailServiceMixin implements MailService {
  final TkmailAwsSesMailServiceOptions options;
  final TkmailClientAwsSes client;

  /// Attachments are not supported.
  @override
  bool get supportAttachments => true;

  TkmailAwsSesMailService({required this.client, required this.options});

  @override
  Future<SendMailResult> sendMail(MailMessage message) async {
    var request = ApiSendMailRequestAwsSes()
      ..service.v = (ApiServiceAwsSes()
        ..region.v = options.region
        ..credentials.v = (ApiCredentialsAwsSes()
          ..accessKeyId.v = options.credentials.accessKeyId
          ..secretAccessKey.v = options.credentials.secretAccessKey))
      ..message.v = (ApiMailMessage()
        ..subject.v = message.subject
        ..from.v = message.from.toApiMailRecipient()
        ..to.v = message.to?.map((e) => e.toApiMailRecipient()).toList()
        ..cc.v = message.cc?.map((e) => e.toApiMailRecipient()).toList()
        ..bcc.v = message.bcc?.map((e) => e.toApiMailRecipient()).toList()
        ..replyTo.v =
            message.replyTo?.map((e) => e.toApiMailRecipient()).toList()
        ..html.v = message.html
        ..text.v = message.text
        ..attachments.v =
            message.attachments?.map((e) => e.toApiMailAttachment()).toList());

    var response = await client.sendEmail(request);

    return SendMailResultFromApi(response);
  }
}
