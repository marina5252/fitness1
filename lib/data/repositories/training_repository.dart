import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voicepump/data/models/training_model.dart';
import 'package:voicepump/data/models/training_booking_model.dart';
import 'package:voicepump/core/constants/app_constants.dart';

class TrainingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Получить все тренировки
  Stream<List<TrainingModel>> getTrainings({DateTime? startDate}) {
    final query = _firestore
        .collection('trainings')
        .where('date', isGreaterThanOrEqualTo: startDate ?? DateTime.now())
        .orderBy('date');

    return query.snapshots().map((snapshot) {
      final trainings = snapshot.docs
          .map((doc) => TrainingModel.fromFirestore(doc))
          .toList();
      // Сортируем по времени вручную
      trainings.sort((a, b) {
        final dateCompare = a.date.compareTo(b.date);
        if (dateCompare != 0) return dateCompare;
        return a.timeStart.compareTo(b.timeStart);
      });
      return trainings;
    });
  }

  // Получить тренировку по ID
  Future<TrainingModel?> getTrainingById(String id) async {
    final doc = await _firestore.collection('trainings').doc(id).get();
    if (doc.exists) {
      return TrainingModel.fromFirestore(doc);
    }
    return null;
  }

  // Получить тренировки по типу
  Stream<List<TrainingModel>> getTrainingsByType(String type) {
    return _firestore
        .collection('trainings')
        .where('type', isEqualTo: type)
        .where('date', isGreaterThanOrEqualTo: DateTime.now())
        .orderBy('date')
        .snapshots()
        .map((snapshot) {
      final trainings = snapshot.docs
          .map((doc) => TrainingModel.fromFirestore(doc))
          .toList();
      // Сортируем по времени вручную
      trainings.sort((a, b) {
        final dateCompare = a.date.compareTo(b.date);
        if (dateCompare != 0) return dateCompare;
        return a.timeStart.compareTo(b.timeStart);
      });
      return trainings;
    });
  }

  // Создать тренировку (для админа)
  Future<String> createTraining(TrainingModel training) async {
    final docRef = await _firestore
        .collection('trainings')
        .add(training.toFirestore());
    return docRef.id;
  }

  // Обновить тренировку (для админа)
  Future<void> updateTraining(TrainingModel training) async {
    await _firestore
        .collection('trainings')
        .doc(training.id)
        .update(training.toFirestore());
  }

  // Удалить тренировку (для админа)
  Future<void> deleteTraining(String id) async {
    await _firestore.collection('trainings').doc(id).delete();
  }

  // Записаться на тренировку
  Future<String> bookTraining(String trainingId, String userId) async {
    // Проверяем, не записан ли уже пользователь
    final existingBooking = await _firestore
        .collection('training_bookings')
        .where('trainingId', isEqualTo: trainingId)
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: AppConstants.statusBooked)
        .get();

    if (existingBooking.docs.isNotEmpty) {
      throw Exception('Вы уже записаны на эту тренировку');
    }

    // Проверяем количество мест
    final training = await getTrainingById(trainingId);
    if (training == null) {
      throw Exception('Тренировка не найдена');
    }

    final bookingsCount = await _firestore
        .collection('training_bookings')
        .where('trainingId', isEqualTo: trainingId)
        .where('status', isEqualTo: AppConstants.statusBooked)
        .get();

    if (bookingsCount.docs.length >= training.capacity) {
      throw Exception('Нет свободных мест');
    }

    // Создаем запись
    final booking = TrainingBookingModel(
      id: '',
      trainingId: trainingId,
      userId: userId,
      status: AppConstants.statusBooked,
      createdAt: DateTime.now(),
    );

    final docRef = await _firestore
        .collection('training_bookings')
        .add(booking.toFirestore());
    return docRef.id;
  }

  // Отменить запись
  Future<void> cancelBooking(String bookingId) async {
    await _firestore.collection('training_bookings').doc(bookingId).update({
      'status': AppConstants.statusCancelled,
    });
  }

  // Получить записи пользователя
  Stream<List<TrainingBookingModel>> getUserBookings(String userId) {
    return _firestore
        .collection('training_bookings')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: AppConstants.statusBooked)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TrainingBookingModel.fromFirestore(doc))
          .toList();
    });
  }

  // Получить следующую тренировку пользователя
  Future<TrainingBookingModel?> getNextUserTraining(String userId) async {
    final bookings = await _firestore
        .collection('training_bookings')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: AppConstants.statusBooked)
        .get();

    if (bookings.docs.isEmpty) {
      return null;
    }

    // Получаем тренировки для этих записей
    final trainingIds = bookings.docs
        .map((doc) => TrainingBookingModel.fromFirestore(doc).trainingId)
        .toList();

    final trainings = await Future.wait(
      trainingIds.map((id) => getTrainingById(id)),
    );

    final validTrainings = trainings
        .whereType<TrainingModel>()
        .where((t) => t.date.isAfter(DateTime.now()))
        .toList();

    if (validTrainings.isEmpty) {
      return null;
    }

    validTrainings.sort((a, b) {
      final dateCompare = a.date.compareTo(b.date);
      if (dateCompare != 0) return dateCompare;
      return a.timeStart.compareTo(b.timeStart);
    });

    final nextTraining = validTrainings.first;
    return bookings.docs
        .map((doc) => TrainingBookingModel.fromFirestore(doc))
        .firstWhere((b) => b.trainingId == nextTraining.id);
  }
}

final trainingRepositoryProvider =
    Provider<TrainingRepository>((ref) => TrainingRepository());

