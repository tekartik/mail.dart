import 'package:tekartik_aws_ses_node/aws_ses_node.dart' as aws;
import 'package:tekartik_mail/mail.dart';
// ignore: implementation_imports
import 'package:tekartik_mail/src/mixin.dart';

/// Service credentials.
class AwsSesCredentials {
  final String accessKeyId;
  final String secretAccessKey;

  AwsSesCredentials({required this.accessKeyId, required this.secretAccessKey});
}

/// Service options.
class AwsSesMailServiceOptions {
  final String region;
  final AwsSesCredentials credentials;

  AwsSesMailServiceOptions({required this.region, required this.credentials});
}

final _awsSes = aws.awsSes;

class AwsSesMailService with MailServiceMixin implements MailService {
  final AwsSesMailServiceOptions options;
  aws.AwsSesClient? _client;

  aws.AwsSesClient _initClient() {
    _client ??= _awsSes.sesClient(
        region: options.region,
        credentials: aws.AwsCredentials(
            accessKeyId: options.credentials.accessKeyId,
            secretAccessKey: options.credentials.secretAccessKey));
    return _client!;
  }

  AwsSesMailService({required this.options});

  @override
  Future<SendMailResult> sendMail(MailMessage message) async {
    var client = _initClient();
    var response = await client.sendMail(aws.AwsSesMessage(
      from: message.from.toAwsRecipient(),
      to: message.to?.map((e) => e.toAwsRecipient()).toList(),
      cc: message.cc?.map((e) => e.toAwsRecipient()).toList(),
      bcc: message.bcc?.map((e) => e.toAwsRecipient()).toList(),
      html: message.html?.toAwsSesContent(),
      text: message.text?.toAwsSesContent(),
      subject: message.subject.toAwsSesContent(),
      replyTo: message.replyTo?.map((e) => e.toAwsRecipient()).toList(),
    ));
    return SendMailResultSes(response);
  }
}

extension AwsMailRecipientExt on MailRecipient {
  String toAwsRecipient() {
    if (name == null) {
      return email;
    } else {
      return '$name <$email>';
    }
  }
}

extension AwsMailContentExt on String {
  aws.AwsSesContent toAwsSesContent() => aws.AwsSesContent(data: this);
}

class SendMailResultSes implements SendMailResult {
  final aws.AwsSesSendMailResult result;

  SendMailResultSes(this.result);

  @override
  String? get messageId => result.messageId;
}
