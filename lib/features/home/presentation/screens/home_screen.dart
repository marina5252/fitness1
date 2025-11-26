import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:voicepump/data/services/auth_service.dart';
import 'package:voicepump/data/repositories/news_repository.dart';
import 'package:voicepump/data/repositories/training_repository.dart';
import 'package:voicepump/data/repositories/subscription_repository.dart';
import 'package:voicepump/data/models/news_model.dart';
import 'package:voicepump/data/models/training_model.dart';
import 'package:voicepump/data/models/subscription_model.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    final currentUser = authService.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final newsStream = ref.watch(newsRepositoryProvider).getNews();
    final trainingsStream = ref.watch(trainingRepositoryProvider).getTrainings();
    final userSubscriptionsStream = ref
        .watch(subscriptionRepositoryProvider)
        .getUserSubscriptions(currentUser.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('VoicePump'),
        actions: [
          IconButton(
            icon: const Icon(Icons.mic),
            onPressed: () {
              context.push('/voice-assistant');
            },
            tooltip: 'Голосовой помощник',
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              context.push('/profile');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Обновление данных
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Приветствие
              StreamBuilder(
                stream: authService.getUserData(currentUser.uid).asStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final user = snapshot.data;
                    return Text(
                      'Привет, ${user?.name ?? 'Пользователь'}!',
                      style: Theme.of(context).textTheme.headlineSmall,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 24),

              // Активный абонемент
              StreamBuilder<List<UserSubscriptionModel>>(
                stream: userSubscriptionsStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    final activeSub = snapshot.data!.firstWhere(
                      (sub) => sub.isActive,
                      orElse: () => snapshot.data!.first,
                    );

                    if (activeSub.isActive) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.card_membership,
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
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  context.push('/subscriptions');
                                },
                                child: const Text('Продлить'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  }
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Нет активного абонемента'),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              context.push('/subscriptions');
                            },
                            child: const Text('Купить абонемент'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Ближайшие тренировки
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ближайшие тренировки',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () {
                      context.push('/schedule');
                    },
                    child: const Text('Все'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: StreamBuilder<List<TrainingModel>>(
                  stream: trainingsStream,
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
                        child: Text('Нет доступных тренировок'),
                      );
                    }

                    final trainings = snapshot.data!
                        .where((t) => t.date.isAfter(DateTime.now()))
                        .take(3)
                        .toList();

                    if (trainings.isEmpty) {
                      return const Center(
                        child: Text('Нет предстоящих тренировок'),
                      );
                    }

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: trainings.length,
                      itemBuilder: (context, index) {
                        final training = trainings[index];
                        return SizedBox(
                          width: 280,
                          child: Card(
                            margin: const EdgeInsets.only(right: 8),
                            child: InkWell(
                              onTap: () {
                                context.push('/training/${training.id}');
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      training.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      training.type,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${DateFormat('dd.MM.yyyy').format(training.date)} в ${training.timeStart}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Новости
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Новости и акции',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () {
                      context.push('/news');
                    },
                    child: const Text('Все'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              StreamBuilder<List<NewsModel>>(
                stream: newsStream,
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
                      child: Text('Нет новостей'),
                    );
                  }

                  final news = snapshot.data!.take(3).toList();

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: news.length,
                    itemBuilder: (context, index) {
                      final newsItem = news[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: newsItem.imageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    newsItem.imageUrl!,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.image);
                                    },
                                  ),
                                )
                              : const Icon(Icons.article),
                          title: Text(newsItem.title),
                          subtitle: Text(
                            newsItem.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            // Показать детали новости
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.push('/schedule');
              break;
            case 2:
              context.push('/subscriptions');
              break;
            case 3:
              context.push('/profile');
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Главная',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Расписание',
          ),
          NavigationDestination(
            icon: Icon(Icons.card_membership_outlined),
            selectedIcon: Icon(Icons.card_membership),
            label: 'Абонементы',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}

