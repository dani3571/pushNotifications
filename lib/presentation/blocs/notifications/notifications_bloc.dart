import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:push_app/config/local_notifications/local_notifications.dart';
import 'package:push_app/domain/entities/push_message.dart';
import '../../../firebase_options.dart';
part 'notifications_event.dart';
part 'notifications_state.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationsBloc() : super(const NotificationsState()) {
    //  on<NotificationsEvent>((event, emit) {});
    on<NotificationsStatusChanged>(_onChangeStatus);
    on<NotificationReceived>(_opPushMessageReceived);
    // Verificar estado initial de las notificaciones
    _initialStatusCheck();
    // Listener para notificaciones en foreground
    _onForegroundMessage();
  }

  void _onChangeStatus(
      NotificationsStatusChanged event, Emitter<NotificationsState> emit) {
    emit(state.copyWith(status: event.status));
    _getFCMToken();
  }

  void _initialStatusCheck() async {
    final settings = await messaging.getNotificationSettings();
    add(NotificationsStatusChanged(settings.authorizationStatus));
  }

  // FCM -> Firebase cloud message
  void _getFCMToken() async {
    // * Token identificador unico del dispositivo el cual nos puede servir
    // * para enviar una notificacion a un dispositivo especifico
    if (state.status != AuthorizationStatus.authorized) return;
    final token = await messaging.getToken();
    print('token: $token');
  }

  void handleRemoteMessage(RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');
    if (message.notification == null) return;

    print('Message also contained a notification: ${message.notification}');

    final notification = PushMessage(
        // * Limpiamos el messageId dado que puede contener caracteres que afecten al funcionamiento de la aplicacion
        messageId:
            message.messageId?.replaceAll(':', '').replaceAll('%', '') ?? '',
        title: message.notification!.title ?? '',
        body: message.notification!.body ?? '',
        sentData: message.sentTime ?? DateTime.now(),
        data: message.data,
        imageUrl: Platform.isAndroid
            ? message.notification!.android?.imageUrl
            : message.notification!.apple?.imageUrl);

    print(notification);

    add(NotificationReceived(notification));
  }

  void _opPushMessageReceived(
      NotificationReceived event, Emitter<NotificationsState> emit) {
    emit(
        // * Usamos el operador spread (...) para agregar la nueva notificacion al principio de la lista actual
        // * de las notificaciones
        state.copyWith(notifications: [event.message, ...state.notifications]));
  }

  void _onForegroundMessage() {
    // * Stream:
    FirebaseMessaging.onMessage.listen(handleRemoteMessage);
  }

  // Static permite hacer una llamada a la clase sin instanciarlo
  static Future<void> initializeFirebaseNotifications() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Sacado de la documentacion de flutterFire - Permissions
  void requestPermision() async {
    // * Solicitar permiso a las push notifications
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );
    add(NotificationsStatusChanged(settings.authorizationStatus));

    // * Solicitar permiso a las local notifications 
    await requestPermissionLocalNotifications();

  }

  // * Funcion para verificar si existe un pushMessage y si existe retornara el PushMessage
  PushMessage? getMessageId(String pushMessageId) {
    final exist = state.notifications
        .any((element) => element.messageId == pushMessageId);
    if (!exist) return null;
    // * El firsWhere siempre retornara a fuerza la instancia
    return state.notifications
        .firstWhere((element) => element.messageId == pushMessageId);
  }
  // ! FORMA 1 - DEPRECADA
  // * Para enviar notificaciones desde un protocolo http debemos consultar la siguiente documentacion
  // * https://firebase.google.com/docs/cloud-messaging/http-server-ref y ademas debemos habilitar el
  // * API de Cloud Messaging (heredada)

  // ! FORMA 2 - RECOMENDADA CON SERVIDORES BEARER TOKEN -> https://firebase.google.com/docs/cloud-messaging/send-message#rest_3
}
