import 'dart:convert';

import 'package:aws_common/aws_common.dart';
import 'package:aws_common/testing.dart';
import 'package:tekartik_mail_aws_ses/mail_aws_ses.dart';
import 'package:test/test.dart';

void main() {
  group('AwsMailService', () {
    test('sendMail success', () async {
      AWSHttpRequest? interceptedRequest;

      final mockClient = MockAWSHttpClient((request, isCancelled) async {
        interceptedRequest = request;
        return AWSHttpResponse(
          statusCode: 200,
          body: utf8.encode('{"MessageId": "test-msg-id"}'),
        );
      });

      final service = MailServiceAwsSes(
        options: MailServiceOptionsAwsSes(
          region: 'us-east-1',
          credentials: MailCredentialsAwsSes(
            accessKeyId: 'test-key-id',
            secretAccessKey: 'test-secret-key',
            sessionToken: 'test-session-token',
          ),
        ),
        client: mockClient,
      );

      final message = MailMessage(
        from: MailRecipient(email: 'sender@test.com', name: 'Sender Name'),
        to: [
          MailRecipient(email: 'to1@test.com', name: 'Recipient 1'),
          MailRecipient(email: 'to2@test.com'),
        ],
        cc: [MailRecipient(email: 'cc1@test.com', name: 'CC 1')],
        bcc: [MailRecipient(email: 'bcc1@test.com')],
        replyTo: [MailRecipient(email: 'reply@test.com', name: 'Reply To')],
        subject: 'Hello Test',
        text: 'This is body text.',
        html: '<h3>This is HTML body.</h3>',
        attachments: [
          MailAttachment(
            mimeType: 'text/plain',
            filename: 'test.txt',
            content: utf8.encode('Hello attachment!'),
          ),
        ],
      );

      final result = await service.sendMail(message);

      expect(result.messageId, equals('test-msg-id'));
      expect(result.toString(), contains('test-msg-id'));

      expect(interceptedRequest, isNotNull);
      final req = interceptedRequest!;
      expect(req.method, equals(AWSHttpMethod.post));
      expect(
        req.uri.toString(),
        equals(
          'https://email.us-east-1.amazonaws.com/v2/email/outbound-emails',
        ),
      );

      // Verify signed headers
      expect(req.headers, contains('Authorization'));
      expect(req.headers, contains('X-Amz-Date'));
      expect(req.headers['X-Amz-Security-Token'], equals('test-session-token'));
      expect(req.headers['Host'], equals('email.us-east-1.amazonaws.com'));
      expect(req.headers['Content-Type'], equals('application/json'));

      // Decode and verify body
      final bodyBytes = await req.body.fold<List<int>>(
        <int>[],
        (p, e) => p..addAll(e),
      );
      final bodyString = utf8.decode(bodyBytes);
      final bodyMap = jsonDecode(bodyString) as Map;

      expect(
        bodyMap['FromEmailAddress'] as String,
        equals('=?utf-8?B?U2VuZGVyIE5hbWU=?= <sender@test.com>'),
      );

      final destination = bodyMap['Destination'] as Map;
      expect(
        destination['ToAddresses'] as List,
        equals(['=?utf-8?B?UmVjaXBpZW50IDE=?= <to1@test.com>', 'to2@test.com']),
      );
      expect(
        destination['CcAddresses'] as List,
        equals(['=?utf-8?B?Q0MgMQ==?= <cc1@test.com>']),
      );
      expect(destination['BccAddresses'] as List, equals(['bcc1@test.com']));

      expect(
        bodyMap['ReplyToAddresses'] as List,
        equals(['=?utf-8?B?UmVwbHkgVG8=?= <reply@test.com>']),
      );

      final content = bodyMap['Content'] as Map;
      final simple = content['Simple'] as Map;
      final subject = simple['Subject'] as Map;
      expect(subject['Data'] as String, equals('Hello Test'));
      expect(subject['Charset'] as String, equals('UTF-8'));

      final body = simple['Body'] as Map;
      final text = body['Text'] as Map;
      final html = body['Html'] as Map;
      expect(text['Data'] as String, equals('This is body text.'));
      expect(html['Data'] as String, equals('<h3>This is HTML body.</h3>'));

      final attachments = simple['Attachments'] as List;
      expect(attachments.length, equals(1));
      final attachment0 = attachments[0] as Map;
      expect(attachment0['FileName'] as String, equals('test.txt'));
      expect(attachment0['ContentType'] as String, equals('text/plain'));
      expect(
        attachment0['RawContent'] as String,
        equals(base64Encode(utf8.encode('Hello attachment!'))),
      );
    });

    test('sendMail error response', () async {
      final mockClient = MockAWSHttpClient((request, isCancelled) async {
        return AWSHttpResponse(
          statusCode: 400,
          body: utf8.encode('{"Message":"AccessDenied"}'),
        );
      });

      final service = MailServiceAwsSes(
        options: MailServiceOptionsAwsSes(
          region: 'us-east-1',
          credentials: MailCredentialsAwsSes(
            accessKeyId: 'test-key-id',
            secretAccessKey: 'test-secret-key',
          ),
        ),
        client: mockClient,
      );

      final message = MailMessage(
        from: MailRecipient(email: 'sender@test.com'),
        subject: 'Hello',
      );

      expect(
        () => service.sendMail(message),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('AccessDenied'),
          ),
        ),
      );
    });
  });
}
