import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voicepump/data/models/subscription_model.dart';
import 'package:voicepump/core/constants/app_constants.dart';

class SubscriptionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Получить все типы абонементов
  Stream<List<SubscriptionModel>> getSubscriptions() {
    return _firestore
        .collection('subscriptions')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SubscriptionModel.fromFirestore(doc))
          .toList();
    });
  }

  // Получить активный абонемент пользователя
  Future<UserSubscriptionModel?> getActiveUserSubscription(String userId) async {
    final snapshot = await _firestore
        .collection('user_subscriptions')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: AppConstants.statusActive)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    final subscriptions = snapshot.docs
        .map((doc) => UserSubscriptionModel.fromFirestore(doc))
        .where((sub) => sub.isActive)
        .toList();

    if (subscriptions.isEmpty) {
      return null;
    }

    // Возвращаем самый свежий
    subscriptions.sort((a, b) => b.startDate.compareTo(a.startDate));
    return subscriptions.first;
  }

  // Получить все абонементы пользователя
  Stream<List<UserSubscriptionModel>> getUserSubscriptions(String userId) {
    return _firestore
        .collection('user_subscriptions')
        .where('userId', isEqualTo: userId)
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserSubscriptionModel.fromFirestore(doc))
          .toList();
    });
  }

  // Продлить/купить абонемент
  Future<String> purchaseSubscription(
    String userId,
    String subscriptionId,
  ) async {
    // Получаем данные абонемента
    final subscriptionDoc =
        await _firestore.collection('subscriptions').doc(subscriptionId).get();
    if (!subscriptionDoc.exists) {
      throw Exception('Абонемент не найден');
    }

    final subscription = SubscriptionModel.fromFirestore(subscriptionDoc);

    // Создаем новую подписку
    final now = DateTime.now();
    final endDate = now.add(Duration(days: subscription.durationDays));

    final userSubscription = UserSubscriptionModel(
      id: '',
      userId: userId,
      subscriptionId: subscriptionId,
      startDate: now,
      endDate: endDate,
      status: AppConstants.statusActive,
    );

    final docRef = await _firestore
        .collection('user_subscriptions')
        .add(userSubscription.toFirestore());

    // Помечаем старые абонементы как истекшие
    await _firestore
        .collection('user_subscriptions')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: AppConstants.statusActive)
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        if (doc.id != docRef.id) {
          doc.reference.update({'status': AppConstants.statusExpired});
        }
      }
    });

    return docRef.id;
  }

  // Создать тип абонемента (для админа)
  Future<String> createSubscription(SubscriptionModel subscription) async {
    final docRef = await _firestore
        .collection('subscriptions')
        .add(subscription.toFirestore());
    return docRef.id;
  }

  // Обновить тип абонемента (для админа)
  Future<void> updateSubscription(SubscriptionModel subscription) async {
    await _firestore
        .collection('subscriptions')
        .doc(subscription.id)
        .update(subscription.toFirestore());
  }

  // Удалить тип абонемента (для админа)
  Future<void> deleteSubscription(String id) async {
    await _firestore.collection('subscriptions').doc(id).delete();
  }
}

final subscriptionRepositoryProvider =
    Provider<SubscriptionRepository>((ref) => SubscriptionRepository());

