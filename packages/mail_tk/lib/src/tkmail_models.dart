import 'package:cv/cv.dart';

var _builderInitialized = false;

/// Initialize the builders
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

/// Response to send mail
class ApiSendMailResponse extends CvModelBase {
  /// The message id
  late final messageId = CvField<String>('messageId');

  @override
  CvFields get fields => [messageId];
}

/// Request to send mail
class ApiSendMailRequest extends CvModelBase {
  /// The message
  late final message = CvModelField<ApiMailMessage>('message');

  @override
  CvFields get fields => [message];
}

/// Mail message
class ApiMailMessage extends CvModelBase {
  /// From
  late final from = CvModelField<ApiMailRecipient>('from');

  /// To
  late final to = CvModelListField<ApiMailRecipient>('to');

  /// Cc
  late final cc = CvModelListField<ApiMailRecipient>('cc');

  /// Bcc
  late final bcc = CvModelListField<ApiMailRecipient>('bcc');

  /// Reply to
  late final replyTo = CvModelListField<ApiMailRecipient>('replyTo');

  /// Subject
  late final subject = CvField<String>('subject');

  /// Text
  late final text = CvField<String>('text');

  /// Html
  late final html = CvField<String>('html');

  /// Attachments
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

/// Mail attachment
class ApiMailAttachment extends CvModelBase {
  /// Mime type
  late final contentType = CvField<String>('mimeType');

  /// Filename
  late final filename = CvField<String>('filename');

  /// Base64 content
  late final base64Content = CvField<String>('base64Content');
  @override
  late final fields = [contentType, filename, base64Content];
}

/// Mail recipient
class ApiMailRecipient extends CvModelBase {
  /// Email
  late final email = CvField<String>('email');

  /// Name
  late final name = CvField<String>('name');
  @override
  late final fields = [email, name];
}
