import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class PhysicalMetricsModel extends Equatable {
  final String id;
  final String userId;
  final double? weight;
  final int? steps;
  final int? calories;
  final DateTime date;

  const PhysicalMetricsModel({
    required this.id,
    required this.userId,
    this.weight,
    this.steps,
    this.calories,
    required this.date,
  });

  factory PhysicalMetricsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PhysicalMetricsModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      weight: data['weight']?.toDouble(),
      steps: data['steps'],
      calories: data['calories'],
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'weight': weight,
      'steps': steps,
      'calories': calories,
      'date': Timestamp.fromDate(date),
    };
  }

  @override
  List<Object?> get props => [id, userId, weight, steps, calories, date];
}

