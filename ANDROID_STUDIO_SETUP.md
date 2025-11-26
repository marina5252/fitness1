# Как правильно открыть Flutter проект в Android Studio

## Проблема
Android Studio не видит Flutter файлы, потому что проект открыт как Android проект, а не как Flutter проект.

## Решение

### Вариант 1: Переоткрыть проект как Flutter (РЕКОМЕНДУЕТСЯ)

1. **Закройте текущий проект** в Android Studio:
   - File → Close Project

2. **Откройте проект заново**:
   - File → Open
   - Выберите папку `/Users/mariazuravleva/AndroidStudioProjects/fitness`
   - **ВАЖНО**: Android Studio должен автоматически определить, что это Flutter проект (по наличию `pubspec.yaml`)

3. **Если Android Studio не распознал Flutter проект**:
   - File → Settings → Plugins
   - Убедитесь, что установлен плагин "Flutter" и "Dart"
   - Если нет - установите их и перезапустите Android Studio

4. **Синхронизируйте проект**:
   - В терминале Android Studio выполните:
     ```bash
     flutter pub get
     ```
   - Или: Tools → Flutter → Flutter Pub Get

5. **Проверьте структуру проекта**:
   - В левой панели должен быть виден каталог `lib/` со всеми Dart файлами
   - Если не видно - нажмите на папку проекта правой кнопкой → Reload from Disk

### Вариант 2: Использовать Flutter команды

1. **Откройте терминал** в Android Studio (View → Tool Windows → Terminal)

2. **Выполните команды**:
   ```bash
   cd /Users/mariazuravleva/AndroidStudioProjects/fitness
   flutter pub get
   flutter clean
   flutter pub get
   ```

3. **Обновите проект**:
   - File → Invalidate Caches / Restart
   - Выберите "Invalidate and Restart"

### Вариант 3: Создать новый Flutter проект и скопировать файлы

Если ничего не помогает:

1. **Создайте новый Flutter проект**:
   ```bash
   cd /Users/mariazuravleva/AndroidStudioProjects
   flutter create voicepump_new
   ```

2. **Скопируйте файлы**:
   ```bash
   cp -r fitness/lib/* voicepump_new/lib/
   cp fitness/pubspec.yaml voicepump_new/
   cp fitness/analysis_options.yaml voicepump_new/
   ```

3. **Откройте новый проект** в Android Studio

## Проверка

После правильной настройки вы должны видеть:

✅ В левой панели проекта папку `lib/` с Dart файлами  
✅ Внизу Android Studio вкладку "Flutter"  
✅ Возможность запустить приложение через кнопку "Run" с Flutter иконкой  
✅ Подсветку синтаксиса Dart в файлах `.dart`

## Если файлы все еще не видны

1. **Проверьте, что Flutter установлен**:
   ```bash
   flutter doctor
   ```

2. **Убедитесь, что плагины установлены**:
   - File → Settings → Plugins
   - Поиск: "Flutter" и "Dart"
   - Должны быть установлены и включены

3. **Принудительно обновите проект**:
   - File → Invalidate Caches / Restart
   - Выберите все опции и нажмите "Invalidate and Restart"

4. **Проверьте настройки проекта**:
   - File → Project Structure
   - Убедитесь, что SDK настроен правильно

## Важные замечания

- **Не удаляйте папку `android/`** - она нужна для Flutter Android приложения
- **Папка `app/` со старым Android кодом** может быть удалена, если не нужна
- **Все Flutter файлы находятся в папке `lib/`**
- **`pubspec.yaml`** - главный файл конфигурации Flutter проекта

## Структура Flutter проекта

```
fitness/
├── lib/              ← ВСЕ Dart файлы здесь
│   ├── main.dart
│   ├── core/
│   ├── data/
│   └── features/
├── android/          ← Android настройки (НЕ УДАЛЯТЬ)
├── pubspec.yaml      ← Зависимости Flutter
└── app/              ← Старый Android код (можно удалить)
```

## Команды для терминала

```bash
# Перейти в проект
cd /Users/mariazuravleva/AndroidStudioProjects/fitness

# Установить зависимости
flutter pub get

# Запустить приложение
flutter run

# Проверить проект
flutter analyze
```

