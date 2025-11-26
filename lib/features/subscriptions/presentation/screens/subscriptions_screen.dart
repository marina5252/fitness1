import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voicepump/data/repositories/subscription_repository.dart';
import 'package:voicepump/data/services/auth_service.dart';
import 'package:voicepump/data/models/subscription_model.dart';
import 'package:intl/intl.dart';

class SubscriptionsScreen extends ConsumerStatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  ConsumerState<SubscriptionsScreen> createState() =>
      _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends ConsumerState<SubscriptionsScreen> {
  bool _isLoading = false;

  Future<void> _purchaseSubscription(String subscriptionId) async {
    final authService = ref.read(authServiceProvider);
    final userId = authService.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Необходимо войти в систему')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(subscriptionRepositoryProvider);
      await repository.purchaseSubscription(userId, subscriptionId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Абонемент успешно приобретен')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionsStream =
        ref.watch(subscriptionRepositoryProvider).getSubscriptions();
    final authService = ref.read(authServiceProvider);
    final userId = authService.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Абонементы'),
      ),
      body: Column(
        children: [
          // Активный абонемент
          if (userId != null)
            StreamBuilder<List<UserSubscriptionModel>>(
              stream: ref
                  .watch(subscriptionRepositoryProvider)
                  .getUserSubscriptions(userId),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  final activeSub = snapshot.data!.firstWhere(
                    (sub) => sub.isActive,
                    orElse: () => snapshot.data!.first,
                  );

                  if (activeSub.isActive) {
                    return Card(
                      margin: const EdgeInsets.all(16),
                      color: Colors.green.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.check_circle,
                                    color: Colors.green),
                                const SizedBox(width: 8),
                                Text(
                                  'Активный абонемент',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Действует до: ${DateFormat('dd.MM.yyyy').format(activeSub.endDate)}',
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                }
                return const SizedBox.shrink();
              },
            ),

          // Список доступных абонементов
          Expanded(
            child: StreamBuilder<List<SubscriptionModel>>(
              stream: subscriptionsStream,
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
                    child: Text('Нет доступных абонементов'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final subscription = snapshot.data![index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subscription.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(subscription.description),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${subscription.price.toStringAsFixed(0)} ₽',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                    ),
                                    Text(
                                      'на ${subscription.durationDays} дней',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                                ElevatedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : () => _purchaseSubscription(
                                            subscription.id,
                                          ),
                                  child: const Text('Купить'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

