import 'package:tekartik_mail_aws_ses_node/src/recipient_codec.dart';
import 'package:test/test.dart';

void main() {
  test('encode', () {
    expect(encodeName('指定'), '=?utf-8?B?5oyH5a6a?=');
  });
}
