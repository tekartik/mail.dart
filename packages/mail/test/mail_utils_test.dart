import 'package:tekartik_mail/utils/mail_utils.dart';
import 'package:test/test.dart';

void main() {
  group('mail_utils', () {
    test('validateEmail', () {
      expect(validateEmail('a@b.c'), isTrue);
      expect(validateEmail('1@2.3'), isTrue);
      expect(validateEmail('a@b'), isFalse);
    });
    test('validateEmail case insensitive', () {
      expect(validateEmail('alex@Tekartik.com'), isTrue);
      expect(validateEmail('ALEX@TEKARTIK.COM'), isTrue);
      expect(validateEmail('alex@gmail.Com'), isTrue);
    });
    test('validateEmail whole value', () {
      expect(validateEmail('garbage before x@y.co and after'), isFalse);
      expect(validateEmail('x@y.co and after'), isFalse);
      expect(validateEmail('before x@y.co'), isFalse);
      expect(validateEmail(' x@y.co'), isFalse);
      expect(validateEmail('x@y.co\n'), isFalse);
      expect(validateEmail('x@y.co\nz'), isFalse);
      expect(validateEmail(''), isFalse);
    });
  });
}
