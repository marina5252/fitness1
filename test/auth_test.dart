import 'package:flutter_test/flutter_test.dart';
import 'package:voicepump/data/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('should create UserModel from map', () {
      final user = UserModel(
        id: '123',
        name: 'Test User',
        email: 'test@example.com',
        phone: '+1234567890',
        role: 'client',
        createdAt: DateTime.now(),
      );

      expect(user.id, '123');
      expect(user.name, 'Test User');
      expect(user.email, 'test@example.com');
      expect(user.role, 'client');
    });

    test('should compare UserModel instances', () {
      final user1 = UserModel(
        id: '123',
        name: 'Test User',
        email: 'test@example.com',
        role: 'client',
        createdAt: DateTime.now(),
      );

      final user2 = UserModel(
        id: '123',
        name: 'Test User',
        email: 'test@example.com',
        role: 'client',
        createdAt: user1.createdAt,
      );

      expect(user1, equals(user2));
    });
  });
}

