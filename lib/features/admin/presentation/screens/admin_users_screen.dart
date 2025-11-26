import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:voicepump/data/models/user_model.dart';
import 'package:voicepump/data/repositories/training_repository.dart';
import 'package:voicepump/data/repositories/subscription_repository.dart';

class AdminUsersScreen extends ConsumerWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersStream = FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'client')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Клиенты'),
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: usersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Ошибка: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Нет клиентов'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final user = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      user.name.isNotEmpty
                          ? user.name[0].toUpperCase()
                          : 'U',
                    ),
                  ),
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  trailing: IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () {
                      _showUserDetails(context, ref, user);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showUserDetails(
    BuildContext context,
    WidgetRef ref,
    UserModel user,
  ) {
    final trainingRepository = ref.read(trainingRepositoryProvider);
    final subscriptionRepository = ref.read(subscriptionRepositoryProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Email: ${user.email}'),
              if (user.phone != null) Text('Телефон: ${user.phone}'),
              const SizedBox(height: 16),
              const Text(
                'Записи на тренировки:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              StreamBuilder(
                stream: trainingRepository.getUserBookings(user.id),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text('${snapshot.data!.length} записей');
                  }
                  return const Text('Загрузка...');
                },
              ),
              const SizedBox(height: 8),
              const Text(
                'Абонементы:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              StreamBuilder(
                stream: subscriptionRepository.getUserSubscriptions(user.id),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final active = snapshot.data!
                        .where((s) => s.isActive)
                        .length;
                    return Text('Активных: $active');
                  }
                  return const Text('Загрузка...');
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }
}

