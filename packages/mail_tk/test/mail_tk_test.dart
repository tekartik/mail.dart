import 'package:cv/cv.dart';
import 'package:test/test.dart';
import 'package:tekartik_mail_tk/mail_tk.dart';

CvFillOptions get apiFillOptions =>
    CvFillOptions(collectionSize: 1, valueStart: 0);

//a request contains a header field in the form of Authorization: Basic <credentials>, where credentials is the Base64 encoding of ID and password joined by a single colon :.

void main() {
  initTkmailBuilders();
  test('model', () {
    expect((ApiSendMailRequest()..fillModel(apiFillOptions)).toMap(), {
      'message': {
        'from': {'email': 'text_1', 'name': 'text_2'},
        'to': [
          {'email': 'text_3', 'name': 'text_4'}
        ],
        'cc': [
          {'email': 'text_5', 'name': 'text_6'}
        ],
        'bcc': [
          {'email': 'text_7', 'name': 'text_8'}
        ],
        'subject': 'text_9',
        'text': 'text_10',
        'html': 'text_11',
        'attachments': [
          {
            'mimeType': 'text_12',
            'filename': 'text_13',
            'base64Content': 'text_14'
          }
        ],
        'replyTo': [
          {'email': 'text_15', 'name': 'text_16'}
        ]
      }
    });
    expect((ApiSendMailResponse()..fillModel(apiFillOptions)).toMap(),
        {'messageId': 'text_1'});
  });
}
