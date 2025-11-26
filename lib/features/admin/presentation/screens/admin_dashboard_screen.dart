import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Панель администратора'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildAdminCard(
            context,
            'Тренировки',
            Icons.fitness_center,
            Colors.blue,
            () {
              context.push('/admin/trainings');
            },
          ),
          _buildAdminCard(
            context,
            'Новости',
            Icons.article,
            Colors.green,
            () {
              context.push('/admin/news');
            },
          ),
          _buildAdminCard(
            context,
            'Клиенты',
            Icons.people,
            Colors.orange,
            () {
              context.push('/admin/users');
            },
          ),
          _buildAdminCard(
            context,
            'Абонементы',
            Icons.card_membership,
            Colors.purple,
            () {
              // TODO: Экран управления абонементами
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('В разработке')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

