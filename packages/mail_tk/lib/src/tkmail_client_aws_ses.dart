import 'package:cv/cv.dart';
import 'package:path/path.dart';
// ignore: depend_on_referenced_packages
// ignore: depend_on_referenced_packages
// ignore: depend_on_referenced_packages
import 'package:tekartik_mail_tk/src/tkmail_client.dart';
import 'package:tekartik_mail_tk/src/tkmail_models_aws_ses.dart';

import 'constants_aws_ses.dart';
import 'tkmail_models.dart';

/// The main client
class TkmailClientAwsSes extends TkmailClient {
  @override
  final Uri uri;

  /// Constructor
  TkmailClientAwsSes({super.client, required this.uri}) {
    initTkmailAwsSesBuilders();
  }

  Uri get _sendMailUri =>
      uri.replace(path: url.join(uri.path, commandSendMailAwsSes));

  /// The main way to send an email
  Future<ApiSendMailResponse> sendEmail(
    ApiSendMailRequestAwsSes request,
  ) async {
    var result = await send(_sendMailUri, request.toMap());
    return result.cv<ApiSendMailResponse>();
  }
}
