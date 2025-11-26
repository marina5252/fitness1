import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:voicepump/data/repositories/training_repository.dart';
import 'package:voicepump/data/models/training_model.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  String? _selectedType;

  final List<String> _trainingTypes = [
    'Все',
    'Йога',
    'Растяжка',
    'Кардио',
    'Силовые',
    'Пилатес',
  ];

  @override
  Widget build(BuildContext context) {
    final trainingRepository = ref.watch(trainingRepositoryProvider);
    final trainingsStream = trainingRepository.getTrainings();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Расписание'),
      ),
      body: Column(
        children: [
          // Календарь
          TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),

          // Фильтр по типу
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _trainingTypes.length,
              itemBuilder: (context, index) {
                final type = _trainingTypes[index];
                final isSelected = _selectedType == type ||
                    (_selectedType == null && index == 0);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedType = selected ? (index == 0 ? null : type) : null;
                      });
                    },
                  ),
                );
              },
            ),
          ),

          // Список тренировок
          Expanded(
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

                var trainings = snapshot.data!;

                // Фильтр по дате
                trainings = trainings.where((training) {
                  return isSameDay(training.date, _selectedDay);
                }).toList();

                // Фильтр по типу
                if (_selectedType != null && _selectedType != 'Все') {
                  trainings = trainings
                      .where((training) => training.type == _selectedType)
                      .toList();
                }

                if (trainings.isEmpty) {
                  return const Center(
                    child: Text('Нет тренировок на выбранную дату'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: trainings.length,
                  itemBuilder: (context, index) {
                    final training = trainings[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(training.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${training.type} • ${training.timeStart} - ${training.timeEnd}'),
                            if (training.trainerName != null)
                              Text('Тренер: ${training.trainerName}'),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          context.push('/training/${training.id}');
                        },
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

