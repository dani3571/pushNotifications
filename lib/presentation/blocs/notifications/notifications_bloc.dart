import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
    emit(state.copyWith(notifications: [event.message, ...state.notifications]));
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
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }

    //  settings.authorizationStatus;

    add(NotificationsStatusChanged(settings.authorizationStatus));
  }
}
