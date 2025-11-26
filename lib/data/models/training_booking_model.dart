import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class TrainingBookingModel extends Equatable {
  final String id;
  final String trainingId;
  final String userId;
  final String status; // 'booked', 'cancelled', 'visited'
  final DateTime createdAt;

  const TrainingBookingModel({
    required this.id,
    required this.trainingId,
    required this.userId,
    required this.status,
    required this.createdAt,
  });

  factory TrainingBookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TrainingBookingModel(
      id: doc.id,
      trainingId: data['trainingId'] ?? '',
      userId: data['userId'] ?? '',
      status: data['status'] ?? 'booked',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'trainingId': trainingId,
      'userId': userId,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  @override
  List<Object?> get props => [id, trainingId, userId, status, createdAt];
}

