part of 'notifications_bloc.dart';

class NotificationsState extends Equatable {
  final AuthorizationStatus status;
  // TODO: Crear modelo de notificaciones
  final List<dynamic> notifications; // Listado de todas las notificaciones push porque queremos mantenerlas
  const NotificationsState({
    this.status = AuthorizationStatus.notDetermined,
    this.notifications = const []
  });
  
  NotificationsState copyWith(
    AuthorizationStatus? status, 
    List<dynamic>? notifications,
  )=> NotificationsState(
    status: status ?? this.status, 
    notifications: notifications ?? this.notifications ,
  );
  @override
  List<Object> get props => [status, notifications];
}

