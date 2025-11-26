import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voicepump/data/repositories/training_repository.dart';
import 'package:voicepump/data/models/training_model.dart';
import 'package:intl/intl.dart';

class AdminTrainingsScreen extends ConsumerStatefulWidget {
  const AdminTrainingsScreen({super.key});

  @override
  ConsumerState<AdminTrainingsScreen> createState() =>
      _AdminTrainingsScreenState();
}

class _AdminTrainingsScreenState extends ConsumerState<AdminTrainingsScreen> {
  @override
  Widget build(BuildContext context) {
    final trainingsStream =
        ref.watch(trainingRepositoryProvider).getTrainings();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Управление тренировками'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddTrainingDialog(context, ref);
            },
          ),
        ],
      ),
      body: StreamBuilder<List<TrainingModel>>(
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
              child: Text('Нет тренировок'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final training = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(training.title),
                  subtitle: Text(
                    '${training.type} • ${DateFormat('dd.MM.yyyy').format(training.date)} • ${training.timeStart}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _showEditTrainingDialog(context, ref, training);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _deleteTraining(context, ref, training.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddTrainingDialog(
    BuildContext context,
    WidgetRef ref,
  ) {
    final titleController = TextEditingController();
    final typeController = TextEditingController();
    final descriptionController = TextEditingController();
    final timeStartController = TextEditingController();
    final timeEndController = TextEditingController();
    final capacityController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Добавить тренировку'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Название',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: typeController,
                  decoration: const InputDecoration(
                    labelText: 'Тип',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Описание',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(
                    selectedDate == null
                        ? 'Выберите дату'
                        : DateFormat('dd.MM.yyyy').format(selectedDate!),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setDialogState(() {
                        selectedDate = date;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: timeStartController,
                  decoration: const InputDecoration(
                    labelText: 'Время начала (HH:mm)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: timeEndController,
                  decoration: const InputDecoration(
                    labelText: 'Время окончания (HH:mm)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: capacityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Вместимость',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Выберите дату')),
                  );
                  return;
                }

                final training = TrainingModel(
                  id: '',
                  title: titleController.text,
                  type: typeController.text,
                  description: descriptionController.text,
                  date: selectedDate!,
                  timeStart: timeStartController.text,
                  timeEnd: timeEndController.text,
                  capacity: int.tryParse(capacityController.text) ?? 0,
                );

                try {
                  final repository = ref.read(trainingRepositoryProvider);
                  await repository.createTraining(training);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Тренировка добавлена')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ошибка: ${e.toString()}')),
                    );
                  }
                }
              },
              child: const Text('Добавить'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTrainingDialog(
    BuildContext context,
    WidgetRef ref,
    TrainingModel training,
  ) {
    final titleController = TextEditingController(text: training.title);
    final typeController = TextEditingController(text: training.type);
    final descriptionController =
        TextEditingController(text: training.description);
    final timeStartController = TextEditingController(text: training.timeStart);
    final timeEndController = TextEditingController(text: training.timeEnd);
    final capacityController =
        TextEditingController(text: training.capacity.toString());
    DateTime selectedDate = training.date;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Редактировать тренировку'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Название',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: typeController,
                  decoration: const InputDecoration(
                    labelText: 'Тип',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Описание',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(DateFormat('dd.MM.yyyy').format(selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setDialogState(() {
                        selectedDate = date;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: timeStartController,
                  decoration: const InputDecoration(
                    labelText: 'Время начала (HH:mm)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: timeEndController,
                  decoration: const InputDecoration(
                    labelText: 'Время окончания (HH:mm)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: capacityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Вместимость',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedTraining = training.copyWith(
                  title: titleController.text,
                  type: typeController.text,
                  description: descriptionController.text,
                  date: selectedDate,
                  timeStart: timeStartController.text,
                  timeEnd: timeEndController.text,
                  capacity: int.tryParse(capacityController.text) ?? 0,
                );

                try {
                  final repository = ref.read(trainingRepositoryProvider);
                  await repository.updateTraining(updatedTraining);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Тренировка обновлена')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ошибка: ${e.toString()}')),
                    );
                  }
                }
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteTraining(
    BuildContext context,
    WidgetRef ref,
    String trainingId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить тренировку?'),
        content: const Text('Это действие нельзя отменить'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final repository = ref.read(trainingRepositoryProvider);
        await repository.deleteTraining(trainingId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Тренировка удалена')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка: ${e.toString()}')),
          );
        }
      }
    }
  }
}

extension TrainingModelExtension on TrainingModel {
  TrainingModel copyWith({
    String? id,
    String? title,
    String? type,
    String? description,
    DateTime? date,
    String? timeStart,
    String? timeEnd,
    int? capacity,
    String? trainerId,
    String? trainerName,
  }) {
    return TrainingModel(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      description: description ?? this.description,
      date: date ?? this.date,
      timeStart: timeStart ?? this.timeStart,
      timeEnd: timeEnd ?? this.timeEnd,
      capacity: capacity ?? this.capacity,
      trainerId: trainerId ?? this.trainerId,
      trainerName: trainerName ?? this.trainerName,
    );
  }
}

