import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class SubscriptionModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final double price;
  final int durationDays;

  const SubscriptionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.durationDays,
  });

  factory SubscriptionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SubscriptionModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      durationDays: data['durationDays'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'durationDays': durationDays,
    };
  }

  @override
  List<Object?> get props => [id, title, description, price, durationDays];
}

class UserSubscriptionModel extends Equatable {
  final String id;
  final String userId;
  final String subscriptionId;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // 'active' or 'expired'

  const UserSubscriptionModel({
    required this.id,
    required this.userId,
    required this.subscriptionId,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory UserSubscriptionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserSubscriptionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      subscriptionId: data['subscriptionId'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      status: data['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'subscriptionId': subscriptionId,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'status': status,
    };
  }

  bool get isActive => status == 'active' && DateTime.now().isBefore(endDate);

  @override
  List<Object?> get props => [id, userId, subscriptionId, startDate, endDate, status];
}

