import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voicepump/data/repositories/training_repository.dart';
import 'package:voicepump/data/services/auth_service.dart';
import 'package:voicepump/data/models/training_model.dart';
import 'package:voicepump/data/models/training_booking_model.dart';
import 'package:voicepump/core/constants/app_constants.dart';
import 'package:intl/intl.dart';

class TrainingDetailScreen extends ConsumerStatefulWidget {
  final String trainingId;

  const TrainingDetailScreen({
    super.key,
    required this.trainingId,
  });

  @override
  ConsumerState<TrainingDetailScreen> createState() =>
      _TrainingDetailScreenState();
}

class _TrainingDetailScreenState
    extends ConsumerState<TrainingDetailScreen> {
  bool _isLoading = false;
  TrainingBookingModel? _userBooking;

  @override
  void initState() {
    super.initState();
    _loadUserBooking();
  }

  Future<void> _loadUserBooking() async {
    final authService = ref.read(authServiceProvider);
    final userId = authService.currentUser?.uid;
    if (userId == null) return;

    final repository = ref.read(trainingRepositoryProvider);
    final bookings = await repository.getUserBookings(userId).first;
    _userBooking = bookings.firstWhere(
      (b) => b.trainingId == widget.trainingId,
      orElse: () => TrainingBookingModel(
        id: '',
        trainingId: '',
        userId: '',
        status: '',
        createdAt: DateTime.now(),
      ),
    );

    if (mounted && _userBooking!.id.isNotEmpty) {
      setState(() {});
    }
  }

  Future<void> _bookTraining() async {
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
      final repository = ref.read(trainingRepositoryProvider);
      await repository.bookTraining(widget.trainingId, userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Вы успешно записались на тренировку')),
        );
        _loadUserBooking();
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

  Future<void> _cancelBooking() async {
    if (_userBooking == null || _userBooking!.id.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(trainingRepositoryProvider);
      await repository.cancelBooking(_userBooking!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Запись отменена')),
        );
        _loadUserBooking();
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
    final repository = ref.read(trainingRepositoryProvider);
    final trainingFuture = repository.getTrainingById(widget.trainingId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Тренировка'),
      ),
      body: FutureBuilder<TrainingModel?>(
        future: trainingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Text('Ошибка: ${snapshot.error ?? 'Тренировка не найдена'}'),
            );
          }

          final training = snapshot.data!;
          final isBooked = _userBooking != null &&
              _userBooking!.id.isNotEmpty &&
              _userBooking!.status == AppConstants.statusBooked;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  training.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Chip(label: Text(training.type)),
                const SizedBox(height: 16),
                _buildInfoRow(
                  Icons.calendar_today,
                  DateFormat('dd.MM.yyyy').format(training.date),
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.access_time,
                  '${training.timeStart} - ${training.timeEnd}',
                ),
                if (training.trainerName != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.person,
                    training.trainerName!,
                  ),
                ],
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.people,
                  'Мест: ${training.capacity}',
                ),
                const SizedBox(height: 24),
                Text(
                  'Описание',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(training.description),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : (isBooked ? _cancelBooking : _bookTraining),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: isBooked ? Colors.red : null,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(isBooked ? 'Отменить запись' : 'Записаться'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}

