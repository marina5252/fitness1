# Настройка Dart SDK в Android Studio

## Проблема: "Dart is not configured"

Это означает, что Android Studio не может найти Dart SDK. Вот как это исправить:

## Решение

### Шаг 1: Убедитесь, что Flutter установлен

1. Откройте терминал (в Android Studio или системный)

2. Проверьте установку Flutter:
   ```bash
   flutter --version
   flutter doctor
   ```

3. Если Flutter не установлен, установите его:
   - Скачайте с https://flutter.dev/docs/get-started/install
   - Или используйте Homebrew (macOS):
     ```bash
     brew install --cask flutter
     ```

### Шаг 2: Настройте Dart SDK в Android Studio

1. **Откройте настройки**:
   - `File` → `Settings` (или `Android Studio` → `Preferences` на Mac)
   - Или `Ctrl + Alt + S` (Windows/Linux) / `Cmd + ,` (Mac)

2. **Перейдите в раздел Dart**:
   - В левом меню найдите `Languages & Frameworks` → `Dart`

3. **Укажите путь к Dart SDK**:
   - Flutter включает Dart SDK, поэтому путь обычно:
     ```
     /path/to/flutter/bin/cache/dart-sdk
     ```
   - Или просто укажите путь к Flutter:
     ```
     /path/to/flutter
     ```
   - Android Studio автоматически найдет Dart SDK внутри Flutter

4. **Найдите путь к Flutter**:
   - В терминале выполните:
     ```bash
     which flutter
     ```
   - Или:
     ```bash
     flutter --version
     ```
   - Обычно Flutter находится в:
     - macOS: `~/development/flutter` или `/usr/local/flutter`
     - Linux: `~/development/flutter` или `/opt/flutter`
     - Windows: `C:\src\flutter`

5. **Проверьте настройки**:
   - В настройках Dart должна быть галочка "Enable Dart support for the project"
   - Нажмите `Apply` и `OK`

### Шаг 3: Перезапустите Android Studio

1. Закройте Android Studio полностью
2. Откройте заново
3. Откройте проект

### Шаг 4: Проверьте настройки проекта

1. `File` → `Project Structure` (или `Ctrl + Alt + Shift + S`)
2. В разделе `SDKs` должен быть Dart SDK
3. Если нет - добавьте вручную:
   - Нажмите `+` → `Dart SDK`
   - Укажите путь к Dart SDK

## Альтернативный способ (через Flutter команды)

1. **Установите зависимости через терминал**:
   ```bash
   cd /Users/mariazuravleva/AndroidStudioProjects/fitness
   flutter pub get
   ```

2. **Откройте проект через Flutter**:
   ```bash
   flutter open
   ```
   Это откроет проект в Android Studio с правильными настройками

## Проверка

После настройки:

1. Откройте любой `.dart` файл (например, `lib/main.dart`)
2. Должна быть подсветка синтаксиса
3. Должны работать автодополнение и подсказки
4. Внизу Android Studio должна быть вкладка "Dart Analysis"

## Если ничего не помогает

1. **Переустановите Flutter плагин**:
   - `File` → `Settings` → `Plugins`
   - Найдите "Flutter" и "Dart"
   - Отключите и включите снова
   - Или удалите и установите заново

2. **Используйте VS Code** (временно):
   - VS Code отлично работает с Flutter
   - Установите расширение "Flutter"
   - Откройте папку проекта

3. **Проверьте переменные окружения**:
   ```bash
   echo $PATH
   ```
   Убедитесь, что Flutter в PATH

