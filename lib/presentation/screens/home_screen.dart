
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:push_app/presentation/blocs/notifications/notifications_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         title: context.select((NotificationsBloc bloc) =>Text('${bloc.state.status}' )),
        actions: [
          // TODO Solicitar permiso de notificaciones
          IconButton(
            onPressed: () {
              context.read<NotificationsBloc>().requestPermision();
            }, 
            icon: const Icon(Icons.settings)
          ) 
        ],
      ),
      body: const _HomeView(),
    );
  }
}
class _HomeView extends StatelessWidget {
  const _HomeView();
  
  @override
  Widget build(BuildContext context) {
    final notifications = context.watch<NotificationsBloc>().state.notifications;
    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
      
          final notification = notifications[index];

          return ListTile(
            title: Text(notification.title),
            subtitle: Text(notification.body),
            leading: notification.imageUrl !=null ? Image.network('${notification.imageUrl}') : Image.network('https://images.assetsdelivery.com/compings_v2/yehorlisnyi/yehorlisnyi2104/yehorlisnyi210400016.jpg') ,
            
          );
      });
  }
}