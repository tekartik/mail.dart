import 'dart:convert';
import 'package:aws_common/aws_common.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';
import 'package:tekartik_mail/mail_mixin.dart';
import 'recipient_codec.dart';

/// AWS mail credentials.
class MailCredentialsAwsSes {
  /// Access key ID.
  final String accessKeyId;

  /// Secret access key.
  final String secretAccessKey;

  /// Session token.
  final String? sessionToken;

  /// Constructor.
  MailCredentialsAwsSes({
    required this.accessKeyId,
    required this.secretAccessKey,
    this.sessionToken,
  });
}

/// AWS mail service options.
class MailServiceOptionsAwsSes {
  /// AWS region.
  final String region;

  /// AWS credentials.
  final MailCredentialsAwsSes credentials;

  /// Constructor.
  MailServiceOptionsAwsSes({required this.region, required this.credentials});
}

/// AWS SES mail service using Signature Version 4.
class MailServiceAwsSes with MailServiceMixin implements MailService {
  /// Options.
  final MailServiceOptionsAwsSes options;
  final AWSHttpClient _client;

  /// Constructor.
  MailServiceAwsSes({required this.options, AWSHttpClient? client})
    : _client = client ?? AWSHttpClient();

  @override
  bool get supportAttachments => true;

  /// Close the HTTP client.
  void close() {
    _client.close();
  }

  @override
  Future<SendMailResult> sendMail(MailMessage message) async {
    final signer = AWSSigV4Signer(
      credentialsProvider: AWSCredentialsProvider(
        AWSCredentials(
          options.credentials.accessKeyId,
          options.credentials.secretAccessKey,
          options.credentials.sessionToken,
        ),
      ),
    );

    // Construct credential scope for SES
    final scope = AWSCredentialScope(
      region: options.region,
      service: const AWSService('ses'),
    );

    final uri = Uri.parse(
      'https://email.${options.region}.amazonaws.com/v2/email/outbound-emails',
    );

    final destination = <String, dynamic>{};
    if (message.to != null && message.to!.isNotEmpty) {
      destination['ToAddresses'] = message.to!.map(_encodeRecipient).toList();
    }
    if (message.cc != null && message.cc!.isNotEmpty) {
      destination['CcAddresses'] = message.cc!.map(_encodeRecipient).toList();
    }
    if (message.bcc != null && message.bcc!.isNotEmpty) {
      destination['BccAddresses'] = message.bcc!.map(_encodeRecipient).toList();
    }

    final simpleBody = <String, dynamic>{};
    if (message.text != null) {
      simpleBody['Text'] = {'Data': message.text, 'Charset': 'UTF-8'};
    }
    if (message.html != null) {
      simpleBody['Html'] = {'Data': message.html, 'Charset': 'UTF-8'};
    }

    final simple = <String, dynamic>{
      'Subject': {'Data': message.subject, 'Charset': 'UTF-8'},
      'Body': simpleBody,
    };

    if (message.attachments != null && message.attachments!.isNotEmpty) {
      simple['Attachments'] = message.attachments!.map((e) {
        return {
          'FileName': e.filename,
          'ContentType': e.mimeType,
          'RawContent': base64Encode(e.content),
        };
      }).toList();
    }

    final bodyMap = <String, dynamic>{
      'FromEmailAddress': _encodeRecipient(message.from!),
      'Destination': destination,
      'Content': {'Simple': simple},
    };

    if (message.replyTo != null && message.replyTo!.isNotEmpty) {
      bodyMap['ReplyToAddresses'] = message.replyTo!
          .map(_encodeRecipient)
          .toList();
    }

    final bodyBytes = utf8.encode(jsonEncode(bodyMap));

    final request = AWSHttpRequest(
      method: AWSHttpMethod.post,
      uri: uri,
      headers: {AWSHeaders.contentType: 'application/json', 'Host': uri.host},
      body: bodyBytes,
    );

    final signedRequest = await signer.sign(request, credentialScope: scope);

    final response = await _client.send(signedRequest).response;
    final responseBody = await response.decodeBody();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decodedJson = jsonDecode(responseBody) as Map;
      final messageId = decodedJson['MessageId'] as String?;
      return SendMailResultAwsSes(messageId);
    } else {
      throw Exception(
        'AWS SES SendEmail failed (status ${response.statusCode}): $responseBody',
      );
    }
  }

  String _encodeRecipient(MailRecipient recipient) {
    final name = recipient.name;
    if (name == null || name.isEmpty) {
      return recipient.email;
    }
    return '${encodeName(name)} <${recipient.email}>';
  }
}

/// Send mail result for AWS.
class SendMailResultAwsSes implements SendMailResult {
  @override
  final String? messageId;

  /// Constructor.
  SendMailResultAwsSes(this.messageId);

  @override
  String toString() => 'SendMailResultAws($messageId)';
}
