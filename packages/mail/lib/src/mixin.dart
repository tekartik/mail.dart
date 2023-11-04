import 'mail_api.dart';

mixin MailServiceMixin implements MailService {
  @override
  bool get supportAttachments => false;
}
