import 'mail_api.dart';

/// Mail service mixin.
mixin MailServiceMixin implements MailService {
  @override
  bool get supportAttachments => false;
}
