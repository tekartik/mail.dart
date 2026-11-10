import 'package:tekartik_mail_aws_ses_node/mail_aws_ses_node.dart';
import 'package:test/test.dart';

void main() {
  test('supportAttachments', () {
    // sendMail sends the attachments (raw MIME), as tekartik_mail_aws_ses.
    var service = AwsSesMailService(
      options: AwsSesMailServiceOptions(
        region: 'us-east-1',
        credentials: AwsSesCredentials(
          accessKeyId: 'dummy_id',
          secretAccessKey: 'dummy_secret',
        ),
      ),
    );
    expect(service.supportAttachments, isTrue);
  });
}
