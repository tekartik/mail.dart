import 'package:tekartik_mail/mail.dart';
import 'package:tekartik_mail_aws_ses_node/src/mail_aws_ses_node.dart';
import 'package:test/test.dart';

void main() {
  test('toAwsRecipient', () {
    expect(MailRecipient(email: 'a@b.co').toAwsRecipient(), 'a@b.co');
    // An empty name is no name (an empty encoded word is invalid).
    expect(MailRecipient(email: 'a@b.co', name: '').toAwsRecipient(), 'a@b.co');
    expect(
      MailRecipient(email: 'a@b.co', name: 'Al').toAwsRecipient(),
      '=?utf-8?B?QWw=?= <a@b.co>',
    );
  });
}
