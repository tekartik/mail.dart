import 'package:cv/cv.dart';

var _builderInitialized = false;
void initTkmailBuilders() {
  if (!_builderInitialized) {
    _builderInitialized = true;
    cvAddConstructor(ApiSendMailResponse.new);
    cvAddConstructor(ApiSendMailRequest.new);
    cvAddConstructor(ApiMailMessage.new);
    cvAddConstructor(ApiMailRecipient.new);
    cvAddConstructor(ApiMailAttachment.new);
  }
}

class ApiSendMailResponse extends CvModelBase {
  late final messageId = CvField<String>('messageId');

  @override
  List<CvField<Object?>> get fields => [messageId];
}

class ApiSendMailRequest extends CvModelBase {
  late final message = CvModelField<ApiMailMessage>('message');

  @override
  List<CvField<Object?>> get fields => [message];
}

class ApiMailMessage extends CvModelBase {
  late final from = CvModelField<ApiMailRecipient>('from');
  late final to = CvModelListField<ApiMailRecipient>('to');
  late final cc = CvModelListField<ApiMailRecipient>('cc');
  late final bcc = CvModelListField<ApiMailRecipient>('bcc');
  late final replyTo = CvModelListField<ApiMailRecipient>('replyTo');
  late final subject = CvField<String>('subject');
  late final text = CvField<String>('text');
  late final html = CvField<String>('html');
  late final attachments = CvModelListField<ApiMailAttachment>('attachments');
  @override
  late final fields = [
    from,
    to,
    cc,
    bcc,
    subject,
    text,
    html,
    attachments,
    replyTo
  ];
}

class ApiMailAttachment extends CvModelBase {
  late final contentType = CvField<String>('mimeType');
  late final filename = CvField<String>('filename');
  late final base64Content = CvField<String>('base64Content');
  @override
  late final fields = [contentType, filename, base64Content];
}

class ApiMailRecipient extends CvModelBase {
  late final email = CvField<String>('email');
  late final name = CvField<String>('name');
  @override
  late final fields = [email, name];
}
