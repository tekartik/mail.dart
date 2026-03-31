import 'package:tekartik_aws_ses_node/aws_ses_node.dart' as aws;
import 'package:tekartik_mail/mail.dart';
// ignore: implementation_imports
import 'package:tekartik_mail/src/mixin.dart';
import 'package:tekartik_mail_aws_ses_node/src/recipient_codec.dart';

/// Service credentials.
class AwsSesCredentials {
  /// Access key ID.
  final String accessKeyId;

  /// Secret access key.
  final String secretAccessKey;

  /// Service credentials.
  AwsSesCredentials({required this.accessKeyId, required this.secretAccessKey});
}

/// Service options.
class AwsSesMailServiceOptions {
  /// Region.
  final String region;

  /// Credentials.
  final AwsSesCredentials credentials;

  /// Service options.
  AwsSesMailServiceOptions({required this.region, required this.credentials});
}

final _awsSes = aws.awsSes;

/// AWS SES mail service.
class AwsSesMailService with MailServiceMixin implements MailService {
  /// Service options.
  final AwsSesMailServiceOptions options;
  aws.AwsSesClient? _client;

  aws.AwsSesClient _initClient() {
    _client ??= _awsSes.sesClient(
      region: options.region,
      credentials: aws.AwsCredentials(
        accessKeyId: options.credentials.accessKeyId,
        secretAccessKey: options.credentials.secretAccessKey,
      ),
    );
    return _client!;
  }

  /// AWS SES mail service.
  AwsSesMailService({required this.options});

  @override
  Future<SendMailResult> sendMail(MailMessage message) async {
    var client = _initClient();
    var response = await client.sendMail(
      aws.AwsSesMessage(
        from: message.from!.toAwsRecipient(),
        to: message.to?.map((e) => e.toAwsRecipient()).toList(),
        cc: message.cc?.map((e) => e.toAwsRecipient()).toList(),
        bcc: message.bcc?.map((e) => e.toAwsRecipient()).toList(),
        html: message.html?.toAwsSesContent(),
        text: message.text?.toAwsSesContent(),
        subject: message.subject.toAwsSesContent(),
        replyTo: message.replyTo?.map((e) => e.toAwsRecipient()).toList(),
        attachments: message.attachments
            ?.map(
              (e) => aws.AwsSesAttachment(
                mimeType: e.mimeType,
                filename: e.filename,
                content: e.content,
              ),
            )
            .toList(),
      ),
    );
    return SendMailResultSes(response);
  }
}

/// AWS SES mail recipient extension.
extension AwsMailRecipientExt on MailRecipient {
  /// Convert to AWS recipient.
  String toAwsRecipient() {
    if (name == null) {
      return email;
    } else {
      return '${encodeName(name!)} <$email>';
    }
  }
}

/// AWS SES mail content extension.
extension AwsMailContentExt on String {
  /// Convert to AWS SES content.
  aws.AwsSesContent toAwsSesContent() => aws.AwsSesContent(data: this);
}

/// Send mail result for SES.
class SendMailResultSes implements SendMailResult {
  /// SES result.
  final aws.AwsSesSendMailResult result;

  /// Send mail result for SES.
  SendMailResultSes(this.result);

  @override
  String? get messageId => result.messageId;

  @override
  String toString() => 'SendMailResultSes($messageId)';
}
