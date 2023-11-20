import 'package:cv/cv.dart';
import 'package:tekartik_mail_tk/src/tkmail_models.dart';

var _builderInitialized = false;
void initTkmailAwsSesBuilders() {
  if (!_builderInitialized) {
    _builderInitialized = true;
    cvAddConstructor(ApiCredentialsAwsSes.new);
    cvAddConstructor(ApiServiceAwsSes.new);
    cvAddConstructor(ApiSendMailRequestAwsSes.new);
    initTkmailBuilders();
  }
}

class ApiCredentialsAwsSes extends CvModelBase {
  late final accessKeyId = CvField<String>('accessKeyId');
  late final secretAccessKey = CvField<String>('secretAccessKey');

  @override
  List<CvField<Object?>> get fields => [accessKeyId, secretAccessKey];
}

class ApiServiceAwsSes extends CvModelBase {
  late final credentials = CvModelField<ApiCredentialsAwsSes>('credentials');
  late final region = CvField<String>('region');

  @override
  List<CvField<Object?>> get fields => [credentials, region];
}

class ApiSendMailRequestAwsSes extends ApiSendMailRequest {
  late final service = CvModelField<ApiServiceAwsSes>('service');

  @override
  List<CvField<Object?>> get fields => [service, ...super.fields];
}
