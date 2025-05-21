import 'package:cv/cv.dart';
import 'package:tekartik_mail_tk/mail_tk_contaklty.dart';

/// The main client
class TkmailClientContaktly extends TkmailClient {
  /// The app name
  final String app;
  @override
  final Uri uri;

  /// Constructor
  TkmailClientContaktly({super.client, required this.uri, required this.app}) {
    initTkmailContaktlyBuilders();
  }

  /// The main way to send an email
  Future<ApiSendMailResponse> sendEmail(
    ApiSendMailRequestContaktly request,
  ) async {
    var response = await send(uri, request.toMap());
    var responseContaktly = response.cv<ApiSendMailResponseContaktly>();
    if (responseContaktly.error.isNotNull) {
      throw responseContaktly.error.v!;
    }
    return ApiSendMailResponse()
      ..messageId.v = responseContaktly.result.v!.messageId.v;
  }

  /// The main way to send an email
  Future<ApiGetTimestampResultContaktly> getTimestamp(
    ApiGetTimestampRequestContaktly request,
  ) async {
    var response = await send(uri, request.toMap());
    var responseContaktly = response.cv<ApiGetTimestampResponseContaktly>();
    if (responseContaktly.error.isNotNull) {
      throw responseContaktly.error.v!;
    }
    return responseContaktly.result.v!;
  }
}
