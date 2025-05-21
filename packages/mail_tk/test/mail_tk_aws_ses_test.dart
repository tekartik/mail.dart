import 'package:cv/cv.dart';
import 'package:tekartik_mail_tk/mail_tk_aws_ses.dart';
import 'package:test/test.dart';

CvFillOptions get apiFillOptions =>
    CvFillOptions(collectionSize: 1, valueStart: 0);

//a request contains a header field in the form of Authorization: Basic <credentials>, where credentials is the Base64 encoding of ID and password joined by a single colon :.

void main() {
  initTkmailBuilders();
  initTkmailAwsSesBuilders();
  test('model', () {
    expect((ApiSendMailRequestAwsSes()..fillModel(apiFillOptions)).toMap(), {
      'service': {
        'credentials': {'accessKeyId': 'text_1', 'secretAccessKey': 'text_2'},
        'region': 'text_3',
      },
      'message': {
        'from': {'email': 'text_4', 'name': 'text_5'},
        'to': [
          {'email': 'text_6', 'name': 'text_7'},
        ],
        'cc': [
          {'email': 'text_8', 'name': 'text_9'},
        ],
        'bcc': [
          {'email': 'text_10', 'name': 'text_11'},
        ],
        'subject': 'text_12',
        'text': 'text_13',
        'html': 'text_14',
        'attachments': [
          {
            'mimeType': 'text_15',
            'filename': 'text_16',
            'base64Content': 'text_17',
          },
        ],
        'replyTo': [
          {'email': 'text_18', 'name': 'text_19'},
        ],
      },
    });
  });
}
