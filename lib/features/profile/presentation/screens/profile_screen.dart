import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:voicepump/data/services/auth_service.dart';
import 'package:voicepump/data/models/user_model.dart';
import 'package:voicepump/data/repositories/physical_metrics_repository.dart';
import 'package:voicepump/data/models/physical_metrics_model.dart';
import 'package:fl_chart/fl_chart.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    final currentUser = authService.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final userDataFuture = authService.getUserData(currentUser.uid);
    final metricsStream = ref
        .watch(physicalMetricsRepositoryProvider)
        .getUserMetrics(currentUser.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Информация о пользователе
            FutureBuilder<UserModel?>(
              future: userDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final user = snapshot.data;
                if (user == null) {
                  return const Text('Ошибка загрузки данных');
                }

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              child: Text(
                                user.name.isNotEmpty
                                    ? user.name[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(fontSize: 32),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(user.email),
                                  if (user.phone != null) ...[
                                    const SizedBox(height: 4),
                                    Text(user.phone!),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Физические показатели
            Text(
              'Физические показатели',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        _showAddMetricsDialog(context, ref, currentUser.uid);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Добавить показатели'),
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder<List<PhysicalMetricsModel>>(
                      stream: metricsStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Text('Нет данных');
                        }

                        final metrics = snapshot.data!;
                        final latest = metrics.first;

                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildMetricCard(
                                  context,
                                  'Вес',
                                  latest.weight != null
                                      ? '${latest.weight!.toStringAsFixed(1)} кг'
                                      : '-',
                                  Icons.monitor_weight,
                                ),
                                _buildMetricCard(
                                  context,
                                  'Шаги',
                                  latest.steps?.toString() ?? '-',
                                  Icons.directions_walk,
                                ),
                                _buildMetricCard(
                                  context,
                                  'Калории',
                                  latest.calories?.toString() ?? '-',
                                  Icons.local_fire_department,
                                ),
                              ],
                            ),
                            if (metrics.length > 1) ...[
                              const SizedBox(height: 24),
                              SizedBox(
                                height: 200,
                                child: _buildMetricsChart(metrics),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildMetricsChart(List<PhysicalMetricsModel> metrics) {
    final weightData = metrics
        .where((m) => m.weight != null)
        .map((m) => FlSpot(
              m.date.millisecondsSinceEpoch.toDouble(),
              m.weight!,
            ))
        .toList();

    if (weightData.isEmpty) {
      return const Center(child: Text('Нет данных для графика'));
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: weightData,
            isCurved: true,
            color: Colors.blue,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }

  void _showAddMetricsDialog(
    BuildContext context,
    WidgetRef ref,
    String userId,
  ) {
    final weightController = TextEditingController();
    final stepsController = TextEditingController();
    final caloriesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить показатели'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Вес (кг)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: stepsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Шаги',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: caloriesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Калории',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              final repository = ref.read(physicalMetricsRepositoryProvider);
              final metrics = PhysicalMetricsModel(
                id: '',
                userId: userId,
                weight: weightController.text.isNotEmpty
                    ? double.tryParse(weightController.text)
                    : null,
                steps: stepsController.text.isNotEmpty
                    ? int.tryParse(stepsController.text)
                    : null,
                calories: caloriesController.text.isNotEmpty
                    ? int.tryParse(caloriesController.text)
                    : null,
                date: DateTime.now(),
              );

              await repository.addMetrics(metrics);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Показатели добавлены')),
                );
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}

