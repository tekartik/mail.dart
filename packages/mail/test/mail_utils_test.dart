import 'package:tekartik_mail/mail.dart';
import 'package:tekartik_mail/utils/mail_utils.dart';
import 'package:test/test.dart';

void main() {
  group('mail_utils', () {
    test('validateEmail', () {
      expect(validateEmail('a@b.c'), isTrue);
      expect(validateEmail('1@2.3'), isTrue);
      expect(validateEmail('a@b'), isFalse);
    });
  });
}
