import 'package:tekartik_mail/mail.dart';
import 'package:test/test.dart';

void main() {
  group('model', () {});

  test('MailRecipient', () {
    expect(MailRecipient(email: 'test'), MailRecipient(email: 'test'));
    expect(MailRecipient(email: 'test'), isNot(MailRecipient(email: 'test2')));
    expect(
      MailRecipient(email: 'test'),
      isNot(MailRecipient(email: 'test', name: 'Name')),
    );
    expect(
      MailRecipient(email: 'test', name: 'Name'),
      MailRecipient(email: 'test', name: 'Name'),
    );
    expect(
      MailRecipient(email: 'test', name: 'Name2'),
      isNot(MailRecipient(email: 'test', name: 'Name')),
    );
    expect(
      MailRecipient(email: 'test', name: 'Name'),
      isNot(MailRecipient(email: 'test2', name: 'Name')),
    );
    expect(MailRecipient(email: 'test1').toString(), 'test1');
    expect(
      MailRecipient(email: 'test1', name: 'test2').toString(),
      'test2 <test1>',
    );
  });
}
