import 'package:tekartik_mail/mail_mixin.dart';
import 'package:tekartik_mail_tk/mail_tk_aws_ses.dart';

import 'package:tekartik_mail_tk/src/tkmail_models_aws_ses.dart';

/// Service credentials.
class TkmailAwsSesCredentials {
  /// Access key id.
  final String accessKeyId;

  /// Secret access key.
  final String secretAccessKey;

  /// Constructor.
  TkmailAwsSesCredentials({
    required this.accessKeyId,
    required this.secretAccessKey,
  });
}

/// Service options.
class TkmailAwsSesMailServiceOptions {
  /// AWS region.
  final String region;

  /// Service credentials.
  final TkmailAwsSesCredentials credentials;

  /// Constructor.
  TkmailAwsSesMailServiceOptions({
    required this.region,
    required this.credentials,
  });
}

/// Http api
class TkmailAwsSesMailService with MailServiceMixin implements MailService {
  /// Service options.
  final TkmailAwsSesMailServiceOptions options;

  /// AWS SES client.
  final TkmailClientAwsSes client;

  /// Constructor.
  TkmailAwsSesMailService({required this.client, required this.options});

  @override
  Future<SendMailResult> sendMail(MailMessage message) async {
    var request =
        ApiSendMailRequestAwsSes()
          ..service.v =
              (ApiServiceAwsSes()
                ..region.v = options.region
                ..credentials.v =
                    (ApiCredentialsAwsSes()
                      ..accessKeyId.v = options.credentials.accessKeyId
                      ..secretAccessKey.v =
                          options.credentials.secretAccessKey))
          ..message.v = message.toApiMailMessage();

    var response = await client.sendEmail(request);

    return SendMailResultFromApi(response);
  }
}
