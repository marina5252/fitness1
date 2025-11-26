import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class TrainingModel extends Equatable {
  final String id;
  final String title;
  final String type; // 'yoga', 'stretching', 'cardio', etc.
  final String description;
  final DateTime date;
  final String timeStart;
  final String timeEnd;
  final int capacity;
  final String? trainerId;
  final String? trainerName;

  const TrainingModel({
    required this.id,
    required this.title,
    required this.type,
    required this.description,
    required this.date,
    required this.timeStart,
    required this.timeEnd,
    required this.capacity,
    this.trainerId,
    this.trainerName,
  });

  factory TrainingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TrainingModel(
      id: doc.id,
      title: data['title'] ?? '',
      type: data['type'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      timeStart: data['timeStart'] ?? '',
      timeEnd: data['timeEnd'] ?? '',
      capacity: data['capacity'] ?? 0,
      trainerId: data['trainerId'],
      trainerName: data['trainerName'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'type': type,
      'description': description,
      'date': Timestamp.fromDate(date),
      'timeStart': timeStart,
      'timeEnd': timeEnd,
      'capacity': capacity,
      'trainerId': trainerId,
      'trainerName': trainerName,
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        type,
        description,
        date,
        timeStart,
        timeEnd,
        capacity,
        trainerId,
        trainerName,
      ];
}

