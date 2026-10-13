import 'package:tekartik_mail_tk/mail_tk_aws_ses.dart';
import 'package:tekartik_mail_tk/mail_tk_contaklty.dart';
import 'package:test/test.dart';

void main() {
  test('ApiCredentialsAwsSes shared by aws_ses and contaktly', () {
    // Importing both libraries used to be an ambiguous import compile error.
    initTkmailContaktlyBuilders();
    initTkmailAwsSesBuilders();
    var credentials = ApiCredentialsAwsSes()
      ..accessKeyId.v = 'id'
      ..secretAccessKey.v = 'secret';
    expect(credentials.toMap(), {
      'accessKeyId': 'id',
      'secretAccessKey': 'secret',
    });
  });
}
