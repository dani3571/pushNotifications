import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> requestPermissionLocalNotifications() async {
  // * Permisos local notifications
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  // * funcion tipo Future para asegurarnos que no siga hasta que esto se resuelva
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
       ?.requestNotificationsPermission();
}
