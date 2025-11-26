import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voicepump/data/models/physical_metrics_model.dart';

class PhysicalMetricsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Добавить метрики
  Future<String> addMetrics(PhysicalMetricsModel metrics) async {
    final docRef = await _firestore
        .collection('physical_metrics')
        .add(metrics.toFirestore());
    return docRef.id;
  }

  // Получить метрики пользователя
  Stream<List<PhysicalMetricsModel>> getUserMetrics(String userId) {
    return _firestore
        .collection('physical_metrics')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PhysicalMetricsModel.fromFirestore(doc))
          .toList();
    });
  }

  // Получить последние метрики пользователя
  Future<PhysicalMetricsModel?> getLatestMetrics(String userId) async {
    final snapshot = await _firestore
        .collection('physical_metrics')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return PhysicalMetricsModel.fromFirestore(snapshot.docs.first);
  }

  // Обновить метрики
  Future<void> updateMetrics(PhysicalMetricsModel metrics) async {
    await _firestore
        .collection('physical_metrics')
        .doc(metrics.id)
        .update(metrics.toFirestore());
  }

  // Удалить метрики
  Future<void> deleteMetrics(String id) async {
    await _firestore.collection('physical_metrics').doc(id).delete();
  }
}

final physicalMetricsRepositoryProvider =
    Provider<PhysicalMetricsRepository>((ref) => PhysicalMetricsRepository());

