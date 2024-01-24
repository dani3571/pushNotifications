import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:push_app/presentation/blocs/notifications/notifications_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationState = NotificationsBloc().state;
    return Scaffold(
      appBar: AppBar(
        // title: context.select((NotificationsBloc bloc) =>Text('${bloc.state.status}' )),
        title: Text('${notificationState.status}'),
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
    return const Placeholder();
  }
}