import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


  Future<void> initLocalNotifications() async{
    AndroidInitializationSettings androidInitializationSettings = AndroidInitializationSettings("@mipmap/ic_launcher");
    InitializationSettings settings = InitializationSettings(android: androidInitializationSettings);
    flutterLocalNotificationsPlugin.initialize(settings: settings);
  }

  void requestLNotificationPermission() async{
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      criticalAlert: true,
      sound: true,
    );

    if(settings.authorizationStatus == AuthorizationStatus.authorized){
      print("Permission granted");
    }else if(settings.authorizationStatus == AuthorizationStatus.provisional){
      print("Permission granted provisionally");
    }else{
      print("Permission denied by user");
    }
  }


  Future<String> getFCMToken() async{
    String ?token = await messaging.getToken();
    print("FCM - token :$token");
    return token!;
  }

  void showNotification(RemoteMessage message){
    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'high_importance_channel',
       'High Importance Channel',
       importance: Importance.high,
       priority: Priority.high
       );

       NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);

       flutterLocalNotificationsPlugin.show(
        id: 0,
        title: message.notification?.title ?? "no title",
        body: message.notification?.body ?? "no body",
        notificationDetails: notificationDetails
        );

  }
}

