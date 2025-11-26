# Инструкция по настройке проекта VoicePump

## Требования

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android Studio или VS Code
- Android SDK (для Android разработки)
- Аккаунт Firebase

## Установка

### 1. Клонирование и установка зависимостей

```bash
cd /Users/mariazuravleva/AndroidStudioProjects/fitness
flutter pub get
```

### 2. Настройка Firebase

Следуйте инструкциям в файле `FIREBASE_SETUP.md` для настройки Firebase.

### 3. Настройка Android

1. Убедитесь, что `google-services.json` находится в `android/app/`
2. Проверьте, что `minSdkVersion` установлен на 26 (Android 8.0+)

### 4. Запуск приложения

```bash
flutter run
```

## Структура проекта

```
lib/
├── main.dart                    # Точка входа
├── core/                        # Основные компоненты
│   ├── constants/              # Константы
│   ├── theme/                  # Темы приложения
│   ├── router/                 # Навигация
│   └── utils/                  # Утилиты
├── data/                        # Слой данных
│   ├── models/                 # Модели данных
│   ├── repositories/           # Репозитории
│   └── services/              # Сервисы (Auth, Firebase, Notifications)
└── features/                    # Функциональные модули
    ├── auth/                   # Аутентификация
    ├── home/                   # Главный экран
    ├── trainings/              # Тренировки
    ├── subscriptions/          # Абонементы
    ├── news/                   # Новости
    ├── profile/                # Профиль
    ├── voice_assistant/        # Голосовой помощник
    └── admin/                  # Панель администратора
```

## Основные функции

### Для клиентов:
- Регистрация и вход
- Просмотр расписания тренировок
- Запись и отмена записи на тренировки
- Просмотр и покупка абонементов
- Просмотр новостей
- Отслеживание физических показателей
- Голосовой помощник

### Для администраторов:
- Управление тренировками
- Управление новостями
- Просмотр списка клиентов
- Управление абонементами

## Тестирование

### Unit тесты

```bash
flutter test
```

### Интеграционные тесты

```bash
flutter test integration_test/
```

## Сборка APK

### Debug

```bash
flutter build apk --debug
```

### Release

```bash
flutter build apk --release
```

## Разрешения

Приложение запрашивает следующие разрешения:
- Интернет (для работы с Firebase)
- Микрофон (для голосового помощника)
- Уведомления (для push-уведомлений)

## Troubleshooting

### Ошибка подключения к Firebase
- Убедитесь, что `google-services.json` находится в правильной директории
- Проверьте, что Firebase проект настроен правильно

### Ошибки с голосовым помощником
- Проверьте разрешения микрофона в настройках устройства
- Убедитесь, что устройство поддерживает распознавание речи

### Проблемы с уведомлениями
- Проверьте настройки уведомлений в Firebase Console
- Убедитесь, что FCM токен получен успешно

## Дополнительная информация

Для получения помощи обратитесь к документации:
- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Riverpod Documentation](https://riverpod.dev/)

