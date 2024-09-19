import 'package:cv/cv.dart';
import 'package:tekartik_mail_tk/src/tkmail_models.dart';

var _builderInitialized = false;

/// Initialize the builders
void initTkmailAwsSesBuilders() {
  if (!_builderInitialized) {
    _builderInitialized = true;
    cvAddConstructor(ApiCredentialsAwsSes.new);
    cvAddConstructor(ApiServiceAwsSes.new);
    cvAddConstructor(ApiSendMailRequestAwsSes.new);
    initTkmailBuilders();
  }
}

/// Credentials for AWS SES
class ApiCredentialsAwsSes extends CvModelBase {
  /// Access key id
  late final accessKeyId = CvField<String>('accessKeyId');

  /// Secret access key
  late final secretAccessKey = CvField<String>('secretAccessKey');

  @override
  CvFields get fields => [accessKeyId, secretAccessKey];
}

/// Service for AWS SES
class ApiServiceAwsSes extends CvModelBase {
  /// Credentials
  late final credentials = CvModelField<ApiCredentialsAwsSes>('credentials');

  /// AWS region
  late final region = CvField<String>('region');

  @override
  CvFields get fields => [credentials, region];
}

/// Request to send mail
class ApiSendMailRequestAwsSes extends ApiSendMailRequest {
  /// Service
  late final service = CvModelField<ApiServiceAwsSes>('service');

  @override
  CvFields get fields => [service, ...super.fields];
}
