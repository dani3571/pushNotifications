part of 'notifications_bloc.dart';

sealed class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object> get props => [];
}
class NotificationsStatusChanged extends NotificationsEvent{
  final AuthorizationStatus status;

  NotificationsStatusChanged(this.status);

}

//TODO 2: NOTIFICATIONRECEIVED()

class NotificationReceived  extends NotificationsEvent{
  	final PushMessage message;

  NotificationReceived(this.message);
    

}