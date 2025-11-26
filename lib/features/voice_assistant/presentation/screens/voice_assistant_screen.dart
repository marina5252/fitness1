import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:voicepump/data/services/auth_service.dart';
import 'package:voicepump/data/repositories/training_repository.dart';
import 'package:voicepump/data/models/training_model.dart';
import 'package:voicepump/data/models/training_booking_model.dart';
import 'package:intl/intl.dart';

class VoiceAssistantScreen extends ConsumerStatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  ConsumerState<VoiceAssistantScreen> createState() =>
      _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState
    extends ConsumerState<VoiceAssistantScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _isListening = false;
  bool _isInitialized = false;
  String _recognizedText = '';
  String _responseText = '';

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    // Запрос разрешений
    await Permission.microphone.request();
    await Permission.speech.request();

    // Инициализация распознавания речи
    final available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() {
            _isListening = false;
          });
        }
      },
      onError: (error) {
        setState(() {
          _isListening = false;
          _responseText = 'Ошибка распознавания: $error';
        });
      },
    );

    // Настройка синтеза речи
    await _tts.setLanguage('ru-RU');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    setState(() {
      _isInitialized = available;
    });
  }

  Future<void> _startListening() async {
    if (!_isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Распознавание речи не доступно')),
      );
      return;
    }

    setState(() {
      _isListening = true;
      _recognizedText = '';
      _responseText = '';
    });

    await _speech.listen(
      onResult: (result) {
        setState(() {
          _recognizedText = result.recognizedWords;
        });

        if (result.finalResult) {
          _processCommand(result.recognizedWords);
        }
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      localeId: 'ru_RU',
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  Future<void> _processCommand(String command) async {
    final lowerCommand = command.toLowerCase();

    // Команда записи на тренировку
    if (lowerCommand.contains('запиши') ||
        lowerCommand.contains('записать')) {
      await _handleBookTraining(lowerCommand);
      return;
    }

    // Команда отмены записи
    if (lowerCommand.contains('отмени') ||
        lowerCommand.contains('отменить')) {
      await _handleCancelTraining(lowerCommand);
      return;
    }

    // Команда следующей тренировки
    if (lowerCommand.contains('когда') ||
        lowerCommand.contains('следующая') ||
        lowerCommand.contains('ближайшая')) {
      await _handleNextTraining();
      return;
    }

    // Команда продления абонемента
    if (lowerCommand.contains('продли') ||
        lowerCommand.contains('продлить')) {
      await _handleExtendSubscription();
      return;
    }

    // Неизвестная команда
    setState(() {
      _responseText = 'Не понял команду. Попробуйте еще раз.';
    });
    await _tts.speak(_responseText);
  }

  Future<void> _handleBookTraining(String command) async {
    final authService = ref.read(authServiceProvider);
    final userId = authService.currentUser?.uid;
    if (userId == null) {
      setState(() {
        _responseText = 'Необходимо войти в систему';
      });
      await _tts.speak(_responseText);
      return;
    }

    // Парсинг команды для поиска типа тренировки и времени
    String? trainingType;
    String? time;

    // Поиск типа тренировки
    if (command.contains('йога')) {
      trainingType = 'Йога';
    } else if (command.contains('растяжк')) {
      trainingType = 'Растяжка';
    } else if (command.contains('кардио')) {
      trainingType = 'Кардио';
    } else if (command.contains('силов')) {
      trainingType = 'Силовые';
    }

    // Поиск времени (простой парсинг)
    final timeRegex = RegExp(r'(\d{1,2}):?(\d{2})?');
    final timeMatch = timeRegex.firstMatch(command);
    if (timeMatch != null) {
      time = timeMatch.group(0);
    }

    // Поиск даты
    DateTime? targetDate;
    if (command.contains('завтра')) {
      targetDate = DateTime.now().add(const Duration(days: 1));
    } else if (command.contains('сегодня')) {
      targetDate = DateTime.now();
    }

    if (trainingType == null || targetDate == null) {
      setState(() {
        _responseText =
            'Не удалось определить тип тренировки или дату. Попробуйте сказать: "Запиши меня на завтра на растяжку в 8:00"';
      });
      await _tts.speak(_responseText);
      return;
    }

    // Поиск подходящей тренировки
    final repository = ref.read(trainingRepositoryProvider);
    final trainings = await repository.getTrainings().first;
    final finalTargetDate = targetDate; // Для избежания nullable проблемы
    final matchingTraining = trainings.firstWhere(
      (t) =>
          t.type == trainingType &&
          t.date.year == finalTargetDate.year &&
          t.date.month == finalTargetDate.month &&
          t.date.day == finalTargetDate.day &&
          (time == null || t.timeStart.contains(time.split(':')[0])),
      orElse: () => TrainingModel(
        id: '',
        title: '',
        type: '',
        description: '',
        date: DateTime.now(),
        timeStart: '',
        timeEnd: '',
        capacity: 0,
      ),
    );

    if (matchingTraining.id.isEmpty) {
      setState(() {
        _responseText = 'Не найдена подходящая тренировка';
      });
      await _tts.speak(_responseText);
      return;
    }

    try {
      await repository.bookTraining(matchingTraining.id, userId);
      setState(() {
        _responseText =
            'Вы успешно записаны на ${matchingTraining.title} ${DateFormat('dd.MM.yyyy').format(matchingTraining.date)} в ${matchingTraining.timeStart}';
      });
      await _tts.speak(_responseText);
    } catch (e) {
      setState(() {
        _responseText = 'Ошибка записи: ${e.toString()}';
      });
      await _tts.speak(_responseText);
    }
  }

  Future<void> _handleCancelTraining(String command) async {
    final authService = ref.read(authServiceProvider);
    final userId = authService.currentUser?.uid;
    if (userId == null) {
      setState(() {
        _responseText = 'Необходимо войти в систему';
      });
      await _tts.speak(_responseText);
      return;
    }

    // Поиск типа тренировки
    String? trainingType;
    if (command.contains('йога')) {
      trainingType = 'Йога';
    } else if (command.contains('растяжк')) {
      trainingType = 'Растяжка';
    }

    final repository = ref.read(trainingRepositoryProvider);
    final bookings = await repository.getUserBookings(userId).first;

    if (bookings.isEmpty) {
      setState(() {
        _responseText = 'У вас нет активных записей';
      });
      await _tts.speak(_responseText);
      return;
    }

    // Поиск подходящей записи
    TrainingBookingModel? bookingToCancel;
    if (trainingType != null) {
      for (final booking in bookings) {
        final training = await repository.getTrainingById(booking.trainingId);
        if (training != null && training.type == trainingType) {
          bookingToCancel = booking;
          break;
        }
      }
    } else {
      bookingToCancel = bookings.first;
    }

    if (bookingToCancel == null) {
      setState(() {
        _responseText = 'Не найдена запись для отмены';
      });
      await _tts.speak(_responseText);
      return;
    }

    try {
      await repository.cancelBooking(bookingToCancel.id);
      setState(() {
        _responseText = 'Запись отменена';
      });
      await _tts.speak(_responseText);
    } catch (e) {
      setState(() {
        _responseText = 'Ошибка отмены: ${e.toString()}';
      });
      await _tts.speak(_responseText);
    }
  }

  Future<void> _handleNextTraining() async {
    final authService = ref.read(authServiceProvider);
    final userId = authService.currentUser?.uid;
    if (userId == null) {
      setState(() {
        _responseText = 'Необходимо войти в систему';
      });
      await _tts.speak(_responseText);
      return;
    }

    final repository = ref.read(trainingRepositoryProvider);
    final nextBooking = await repository.getNextUserTraining(userId);

    if (nextBooking == null) {
      setState(() {
        _responseText = 'У вас нет предстоящих тренировок';
      });
      await _tts.speak(_responseText);
      return;
    }

    final training = await repository.getTrainingById(nextBooking.trainingId);
    if (training == null) {
      setState(() {
        _responseText = 'Тренировка не найдена';
      });
      await _tts.speak(_responseText);
      return;
    }

    setState(() {
      _responseText =
          'Ваша следующая тренировка: ${training.title} ${DateFormat('dd.MM.yyyy').format(training.date)} в ${training.timeStart}';
    });
    await _tts.speak(_responseText);
  }

  Future<void> _handleExtendSubscription() async {
    setState(() {
      _responseText = 'Для продления абонемента перейдите в раздел абонементов';
    });
    await _tts.speak(_responseText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Голосовой помощник'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Индикатор прослушивания
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isListening
                    ? Colors.red.withValues(alpha: 0.3)
                    : Colors.grey.withValues(alpha: 0.2),
              ),
              child: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                size: 80,
                color: _isListening ? Colors.red : Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              _isListening ? 'Слушаю...' : 'Нажмите для начала',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (_recognizedText.isNotEmpty) ...[
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Распознано:',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(_recognizedText),
                    ],
                  ),
                ),
              ),
            ],
            if (_responseText.isNotEmpty) ...[
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ответ:',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(_responseText),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
            // Кнопка записи
            ElevatedButton.icon(
              onPressed: _isListening ? _stopListening : _startListening,
              icon: Icon(_isListening ? Icons.stop : Icons.mic),
              label: Text(_isListening ? 'Остановить' : 'Начать запись'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Примеры команд
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Примеры команд:',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text('• "Запиши меня на завтра на растяжку в 8:00"'),
                    const Text('• "Отмени мою запись на йогу"'),
                    const Text('• "Когда у меня следующая тренировка?"'),
                    const Text('• "Продли мой абонемент"'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    super.dispose();
  }
}

