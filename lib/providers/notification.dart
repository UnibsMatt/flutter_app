import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationManager {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final AndroidNotificationDetails androidPlatformChannelSpecifics =  const AndroidNotificationDetails("id" , "chan",
      channelDescription: "none",
      importance: Importance.high,
      priority: Priority.defaultPriority
  );



  Future<void> initializeNotification() async {
    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('ic_launcher');

    InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void sendNotification() async {
    AndroidNotificationDetails android = const AndroidNotificationDetails(
        'id', 'channel ', channelDescription: 'description',
        priority: Priority.high, importance: Importance.max);

    NotificationDetails platform = NotificationDetails(android: android);

    await _flutterLocalNotificationsPlugin.show(
        2,
        "Ehi",
        "Some one just sent a request",
        platform,
      payload: "welcome"
    );
  }
}
