import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:push_app/config/router/app_router.dart';

final flutterLocalNotifications = FlutterLocalNotificationsPlugin();

class LocalNotifications {
  
  // * static para no crear instancia de la clase LocalNotifications
  static Future<void> requestPermissionLocalNotifications() async {
    // * Permisos local notifications
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    // * funcion tipo Future para asegurarnos que no siga hasta que esto se resuelva
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> initializeLocalNotifications() async {

    final initializeSettingsAndroid = AndroidInitializationSettings('app_icon');

    final initializeSettings = InitializationSettings(android: initializeSettingsAndroid);

    await flutterLocalNotifications.initialize(
      
      initializeSettings,
      onDidReceiveNotificationResponse: onDidNotificationRespose

    );
  }
  static void onDidNotificationRespose(NotificationResponse respose){
      appRouter.push('/push-details/${respose.payload}');

  }

  

  static void showLocalNotification({
    required int id,
    String? title,
    String? body,
    String? data,
  }) {
    const androidNotificationsDetails = AndroidNotificationDetails(
        'channelId', 'channelName',
        playSound: true,
        // * Sonido de notificacion personalizada con una carpeta creada en app/src/main/res/raw/
        sound: RawResourceAndroidNotificationSound('notification'),
        importance: Importance.max,
        priority: Priority.high,
        color: Colors.red,
        
        
        );

    const notificationDetails = NotificationDetails(android: androidNotificationsDetails);

    flutterLocalNotifications.show(id, title, body, notificationDetails, payload: data); // * mostramos la notificacion
  }
}
