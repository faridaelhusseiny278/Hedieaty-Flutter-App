import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/servicecontrol/v1.dart' as servicecontrol;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Controllers/NotificationService.dart';
import 'Models/Notification.dart';
import 'package:flutter/material.dart';

Future <void> handleBackgroundMessage(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
  print('Message Body: ${message.notification?.body}');
  print('Message Title: ${message.notification?.title}');
  print('Message Data: ${message.data}');

}


class FirebaseApi {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final AppNotificationService _notificationService = AppNotificationService(userid: 0);




  // Initialize notifications and get FCM token
  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    print('Token: $fCMToken');
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }

  // handle notifications when received
  void handleMessages(RemoteMessage? message) {
    if (message != null) {
      print('Message data: ${message.data}');
    }
  }
  // handel notifications in case app is terminated
  void handleBackgroundNotifications() async {
    FirebaseMessaging.instance.getInitialMessage().then((handleMessages));
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessages);
  }
  static Future <String> getAccessToken() async{

    final serviceAccountJson= {

      "type": "service_account",
      "project_id": "hediaty-e96fc",
      "private_key_id": "0c079a1cc0d1a502092e683f7dc179b4e2f13b27",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC9LdHmU9HbBzLW\nXlt8ZF7LpOb1Uc1ZuVxK7+9S7drj+twFm/Bs/Wfrj2Ao2LRHeC7QRtZM81dYmbQg\nISUBwQJnT6ONr9pQSyUBmKEHrls0rkwx53Gq6+cqXfHNfZ07/WsD8faa23REw09u\nK58oOxmE8K5C22WC91cI3LP9REms3BM23vqoxyYXlzi8TdgoGcu/iHO84XdilL1q\nzwfK0u8h4GLUrcrSyHqh9DjxfbxniXPDlSDyFdJ0pzo5hc0JB6N2hLasmVVn+PAa\nkwabyVTftfFIpKcuLlWZh2qCQtpmIDDdW1WZ+Pew1wOkuycjxRmvrp6CWtWlKBEe\nymjG2bwdAgMBAAECggEAE8CkgXBFYaFd9AG/Jfz+5DQlb1OUEDxpQA55sRwntj/R\nAv7rZXM3YLeZhTpMkd0hGjBt8MlEWKUX0yD9fFzlk4Q+YgK3Ve86qnDVeM1XiufG\nCec4uELQYgfpbEN44Yojcd0s8AdeRk2++JRdFmDGrdme1a6TFKUfCncCOL1iv0W/\nE+tPf654viMneTgPV4A5MaV2bYjSgep0d1jrVTWLGWdPs4w8YTYGdPePWhxqxOOl\n7fR+A9jAIvqOxQZhGWtz05frbO/5m8Sr06DxvHcPIr6auNyqufmHeTAbjxsOZcn5\nHTShJftrPy+gn+xZm8fK6BYPAGIYc3IBmuOq6nlkmwKBgQD0v174fai4+2FoMea6\n2lHmfDRzJbFYlXc10koWIOI4WXMjI+fqfJIUrQKUJHoKZPTKZmbTsCr38vy87tUD\nWGwp/ueWOE1DuQNL1uLQsMWdyXgCCundCZcSoA7GR1sZqCBsRs7EsRqVURR0ojlJ\nfaWg8vEyY9+7Z4EqVViGT1/7VwKBgQDF4GsS2RU+mo8BZ5ix3LvN7FQLDaxJhbrE\nmjtnt4mosxMNXW9nDqXljHc4wazJcweu+MpQj9xAUb2trJDSRu4+hhuTnKfBqFb4\nWQirL/12tY4+32BBx4BxTn+EF4p8dBXRwA3dhiZi7NFy/81ZLscsePB1730PcjRA\nm/4FxxtPqwKBgQDrX7wC+D4yIDeOUCdYXavUIHEEqCRFUAEEdsefPmKw1H2hNt/L\np5+JWNWZCPeBVZQBrreHL+4y5LFhNcMP45KqVKX91wmfbqeX4QHit45lb6MFO9+r\nHpT2aY2r7GXVZ9Y+q14g1T3+iapFfNnhLoACKIID9v7sqN8Uil2HVYC2IwKBgBuW\nYzc4fsbAo6lteRNrE9/sz/bOjDOf6l8YpambJB0aAlD9stdqamSrhb+q+N0JJYwW\ncZZzyCBLhSdehL5cV0DuT4/v6k+Mmbt8JkI/qZXQUCmh2PiyyMyDRjHzWkJpqNUa\ncpRs7JMkMztWQJnrdKdVoSjAH+50XKaZWPwTO1KLAoGAR1JcVag/KHsX+1CecFAx\nJJkZKn02bc+h/1L8a5bZcTXrPTkN3rEVVaCuyylM8UYuQgcz/I/xljK8Fun305re\nvBohdagxloUE2wR+LZ7y6M0V7mxkInEBo5cttXnWiYnuj/i2ii6273ZTmaTCSc3u\nsMJ8n5tAqeGb+8D0S9csrzw=\n-----END PRIVATE KEY-----\n",
      "client_email": "firebase-adminsdk-1kci6@hediaty-e96fc.iam.gserviceaccount.com",
      "client_id": "114627562309099761659",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-1kci6%40hediaty-e96fc.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"

    };
    List <String> scopes = [
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/firebase.messaging',
      'https://www.googleapis.com/auth/userinfo.email',
    ];
    http.Client client = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes
    );

    // get the access token
    auth.AccessCredentials credentials = await auth.obtainAccessCredentialsViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
      client,
    );
    client.close();

    return credentials.accessToken.data;
  }

  sendNotification(String targetToken, BuildContext context, int userid) async {
    // final DatabaseReference dbRef =
    // FirebaseDatabase.instance.ref("Users/${userid.toString()}/events");
    //
    // dbRef.onValue.listen((event) async {
    //   final data = event.snapshot.value;
    //   if (data != null) {
    //     if (data is List) {
    //       final List eventList = data as List;
    //       for (var event in eventList) {
    //         if (event == null) {
    //           continue;
    //         }
    //         if (event['gifts'] == null) {
    //           continue;
    //         }
    //         final List giftList = event['gifts'] as List;
    //         for (var gift in giftList) {
    //           if (gift == null) {
    //             continue;
    //           }
    //           if (gift['pledged'] == true && gift['notificationSent'] == false) {
    //             String message =
    //                 '${gift['giftName']} has been pledged for the event ${event['eventName']}!';
    //
    //             // Add to your local notification service
    //             await _notificationService.addNotification(AppNotification(
    //               message: message,
    //               timestamp: DateTime.now(),
    //             ));
    //
    //             // Update database to avoid duplicate notifications
    //             dbRef
    //                 .child(eventList.indexOf(event).toString())
    //                 .child('gifts')
    //                 .child(giftList.indexOf(gift).toString())
    //                 .update({'notificationSent': true});
    //
    //             // add a listener for pledged gifts here to send a notif when gifts are pledged
    //             final accessToken = await getAccessToken();
    //             final url = Uri.parse('https://fcm.googleapis.com/v1/projects/hediaty-e96fc/messages:send');
    //             final response = await http.post(
    //               url,
    //               headers: <String, String>{
    //                 'Content-Type': 'application/json',
    //                 'Authorization': 'Bearer $accessToken',
    //               },
    //               body: jsonEncode({
    //                 'message': {
    //                   'token': targetToken,
    //                   'notification': {'title': 'Gift Pledged', 'body': message},
    //                 },
    //               }),
    //             );
    //             if (response.statusCode == 200) {
    //               print('Notification sent successfully');
    //             } else {
    //               print('Failed to send notification. Error: ${response.body}');
    //             }
    //           }
    //         }
    //
    //       }
    //     }
    //   }
    // });
  }
}



