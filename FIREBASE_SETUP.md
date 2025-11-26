# Настройка Firebase

## Шаги для настройки Firebase в проекте VoicePump

### 1. Создание проекта в Firebase Console

1. Перейдите на [Firebase Console](https://console.firebase.google.com/)
2. Нажмите "Добавить проект"
3. Введите название проекта: "VoicePump"
4. Следуйте инструкциям для создания проекта

### 2. Добавление Android приложения

1. В Firebase Console выберите ваш проект
2. Нажмите на иконку Android
3. Введите:
   - Package name: `com.example.fitness`
   - App nickname: VoicePump (опционально)
4. Скачайте файл `google-services.json`
5. Поместите файл в `android/app/google-services.json`

### 3. Настройка Firestore Database

1. В Firebase Console перейдите в раздел "Firestore Database"
2. Создайте базу данных в режиме тестирования
3. Настройте правила безопасности (см. ниже)

### 4. Правила безопасности Firestore

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Trainings collection
    match /trainings/{trainingId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Training bookings
    match /training_bookings/{bookingId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // Subscriptions
    match /subscriptions/{subscriptionId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // User subscriptions
    match /user_subscriptions/{userSubscriptionId} {
      allow read: if request.auth != null && 
        resource.data.userId == request.auth.uid;
      allow write: if request.auth != null;
    }
    
    // News
    match /news/{newsId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Physical metrics
    match /physical_metrics/{metricId} {
      allow read: if request.auth != null && 
        resource.data.userId == request.auth.uid;
      allow write: if request.auth != null && 
        request.resource.data.userId == request.auth.uid;
    }
  }
}
```

### 5. Настройка Firebase Cloud Messaging (FCM)

1. В Firebase Console перейдите в раздел "Cloud Messaging"
2. Включите Cloud Messaging API
3. Для тестирования можно использовать токены устройств

### 6. Настройка Firebase Authentication

1. В Firebase Console перейдите в раздел "Authentication"
2. Включите метод входа "Email/Password"
3. Настройте авторизованные домены при необходимости

### 7. Создание структуры базы данных

После настройки создайте следующие коллекции в Firestore:

- `users` - пользователи
- `trainings` - тренировки
- `training_bookings` - записи на тренировки
- `subscriptions` - типы абонементов
- `user_subscriptions` - абонементы пользователей
- `news` - новости
- `physical_metrics` - физические показатели

### 8. Генерация firebase_options.dart (опционально)

Если используете FlutterFire CLI:

```bash
flutterfire configure
```

Это создаст файл `lib/firebase_options.dart` автоматически.

### 9. Тестирование

1. Запустите приложение
2. Проверьте регистрацию и вход
3. Убедитесь, что данные сохраняются в Firestore
4. Проверьте работу push-уведомлений

## Важные замечания

- Не коммитьте `google-services.json` в публичный репозиторий
- Используйте разные проекты Firebase для разработки и продакшена
- Регулярно проверяйте правила безопасности Firestore
- Настройте индексы для сложных запросов в Firestore

