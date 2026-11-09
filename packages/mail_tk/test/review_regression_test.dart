import 'dart:async';
import 'dart:convert';

// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:http/testing.dart';
import 'package:tekartik_mail_tk/mail_aws_ses.dart';
import 'package:tekartik_mail_tk/mail_tk.dart';
import 'package:test/test.dart';

void main() {
  test('the debug log never prints the AWS secret', () async {
    var secret = 'FAKE_SECRET_ACCESS_KEY';
    var sentBodies = <String>[];
    var printed = <String>[];
    var saved = debugTkmailApi;
    // Read when the client is created.
    debugTkmailApi = true;
    try {
      var service = TkmailAwsSesMailService(
        client: TkmailClientAwsSes(
          uri: Uri.parse('https://tkmail.example/api'),
          client: MockClient((request) async {
            sentBodies.add(request.body);
            return http.Response(
              jsonEncode({'messageId': 'm1'}),
              200,
              headers: {'content-type': 'application/json'},
            );
          }),
        ),
        options: TkmailAwsSesMailServiceOptions(
          region: 'eu-west-1',
          credentials: TkmailAwsSesCredentials(
            accessKeyId: 'AKIAFAKE',
            secretAccessKey: secret,
          ),
        ),
      );
      var result = await runZoned(
        () => service.sendMail(
          MailMessage(
            from: MailRecipient(email: 'from@example.com'),
            to: [MailRecipient(email: 'to@example.com')],
            subject: 'subject',
            text: 'text',
          ),
        ),
        zoneSpecification: ZoneSpecification(
          print: (_, _, _, line) => printed.add(line),
        ),
      );
      expect(result.messageId, 'm1');
    } finally {
      debugTkmailApi = saved;
    }
    // Logged, but redacted.
    expect(printed.join('\n'), contains('secretAccessKey'));
    expect(printed.join('\n'), contains('to@example.com'));
    expect(printed.where((line) => line.contains(secret)), isEmpty);
    // Still sent to the relay.
    expect(sentBodies.single, contains(secret));
  });
}
