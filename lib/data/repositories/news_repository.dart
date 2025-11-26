import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voicepump/data/models/news_model.dart';

class NewsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Получить все новости
  Stream<List<NewsModel>> getNews() {
    return _firestore
        .collection('news')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => NewsModel.fromFirestore(doc))
          .toList();
    });
  }

  // Получить новость по ID
  Future<NewsModel?> getNewsById(String id) async {
    final doc = await _firestore.collection('news').doc(id).get();
    if (doc.exists) {
      return NewsModel.fromFirestore(doc);
    }
    return null;
  }

  // Создать новость (для админа)
  Future<String> createNews(NewsModel news) async {
    final docRef = await _firestore.collection('news').add(news.toFirestore());
    return docRef.id;
  }

  // Обновить новость (для админа)
  Future<void> updateNews(NewsModel news) async {
    await _firestore
        .collection('news')
        .doc(news.id)
        .update(news.toFirestore());
  }

  // Удалить новость (для админа)
  Future<void> deleteNews(String id) async {
    await _firestore.collection('news').doc(id).delete();
  }
}

final newsRepositoryProvider =
    Provider<NewsRepository>((ref) => NewsRepository());

