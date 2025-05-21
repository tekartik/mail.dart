import 'package:cv/cv.dart';
import 'package:tekartik_mail_tk/src/tkmail_models.dart';

var _builderInitialized = false;

/// Initialize the builders
void initTkmailContaktlyBuilders() {
  if (!_builderInitialized) {
    _builderInitialized = true;
    cvAddConstructor(ApiCredentialsAwsSes.new);
    cvAddConstructor(ApiServiceAwsSes.new);

    cvAddConstructors([
      ApiSendMailRequestContaktly.new,
      ApiSendMailQueryContaktly.new,
      ApiSendMailResponseContaktly.new,
      ApiSendMailResultContaktly.new,
      ApiGetTimestampRequestContaktly.new,
      ApiGetTimestampResponseContaktly.new,
      ApiGetTimestampResultContaktly.new,
      ApiErrorContaktly.new,
    ]);
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
class ApiSendMailQueryContaktly extends CvModelBase {
  /// Timestamp
  final timestamp = CvField<String>('timestamp');

  /// Service id
  final serviceId = CvField<String>('serviceId');

  /// Message
  final message = CvModelField<ApiMailMessage>('message');

  /// Enc
  final enc = CvField<String>('enc');

  @override
  CvFields get fields => [timestamp, serviceId, message, enc];
}

/// Base request
abstract class ApiRequestBaseContaktly extends CvModelBase {
  /// Target app
  final app = CvField<String>('app');

  /// Command
  final command = CvField<String>('command');

  @override
  CvFields get fields => [app, command];
}

/// Request to get timestamp
class ApiGetTimestampRequestContaktly extends ApiRequestBaseContaktly {
  @override
  CvFields get fields => [...super.fields];
}

/// Request to send mail
class ApiSendMailRequestContaktly extends ApiRequestBaseContaktly {
  /// The message
  late final query = CvModelField<ApiSendMailQueryContaktly>('data');

  @override
  CvFields get fields => [...super.fields, query];
}

/// Base response
abstract class ApiResponseBaseContaktly extends CvModelBase {
  /// Error
  late final error = CvModelField<ApiErrorContaktly>('error');

  @override
  CvFields get fields => [error];
}

/// Response to send mail
class ApiSendMailResponseContaktly extends ApiResponseBaseContaktly {
  /// The message
  late final result = CvModelField<ApiSendMailResultContaktly>('result');

  @override
  CvFields get fields => [...super.fields, result];
}

/// Result to send mail
class ApiSendMailResultContaktly extends CvModelBase {
  /// Message id
  late final messageId = CvField<String>('messageId');

  @override
  CvFields get fields => [messageId];
}

/// Response to get timestamp
class ApiGetTimestampResponseContaktly extends ApiResponseBaseContaktly {
  /// The message
  late final result = CvModelField<ApiGetTimestampResultContaktly>('result');

  @override
  CvFields get fields => [...super.fields, result];
}

/// Result to send mail
class ApiGetTimestampResultContaktly extends CvModelBase {
  /// Message id
  late final timestamp = CvField<String>('timestamp');

  @override
  CvFields get fields => [timestamp];
}

/// Error
class ApiErrorContaktly extends CvModelBase {
  /// Error code
  late final code = CvField<String>('code');

  /// Error message
  late final message = CvField<String>('message');

  /// Error details
  late final details = CvModelField<CvMapModel>('details');

  @override
  late final CvFields fields = [code, message, details];
}
