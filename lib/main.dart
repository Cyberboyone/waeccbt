import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'services/hive_service.dart';
import 'services/ad_service.dart';
import 'services/sound_service.dart';
import 'models/question.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hiveService = HiveService();
  await hiveService.init();

  runApp(const WaecCbtApp());
  unawaited(_runStartupTasks(hiveService));
}

Future<void> _runStartupTasks(HiveService hiveService) async {
  await Future<void>.delayed(const Duration(milliseconds: 600));

  try {
    await _seedStarterQuestions(hiveService);
  } catch (e) {
    debugPrint('Seeding failed: $e');
  }

  unawaited(
    Future<void>.delayed(const Duration(seconds: 5))
        .then((_) => AdService.instance.init()),
  );

  try {
    await AudioPlayer.global
        .setAudioContext(AppSound.context)
        .timeout(const Duration(seconds: 3));
  } catch (e) {
    debugPrint('Audio context setup skipped: $e');
  }
}

Future<void> _seedStarterQuestions(HiveService hiveService) async {
  const courseIds = [
    'eng', 'mat', 'cve', 'phy', 'che', 'bio', 'agr', 'ani', 'fsh', 'fmat', 'ict', 'fdn',
    'geo', 'gov', 'lit', 'crs', 'irs', 'his',
    'eco', 'com', 'acc', 'mkt'
  ];

  for (final courseId in courseIds) {
    final cached = hiveService.getCachedQuestions(courseId);
    if (cached.isNotEmpty) continue;

    try {
      final jsonStr = await rootBundle.loadString('assets/questions/$courseId.json');
      final questions = await compute(parseQuestionsJson, jsonStr);
      await hiveService.cacheQuestions(courseId, questions);
      debugPrint('Seeded ${questions.length} questions for $courseId');
    } catch (e) {
      debugPrint('Failed to seed $courseId: $e');
    }
  }
}

List<Question> parseQuestionsJson(String jsonStr) {
  final data = json.decode(jsonStr) as Map<String, dynamic>;
  final questionsRaw = data['questions'] as List<dynamic>;

  return questionsRaw.map((q) {
    final map = q as Map<String, dynamic>;
    return Question(
      id: map['id'] as String? ?? '',
      text: map['text'] as String? ?? '',
      options: List<String>.from(map['options'] as List? ?? []),
      correctIndex: map['correct_index'] as int? ?? 0,
      explanation: map['explanation'] as String? ?? '',
      difficulty: map['difficulty'] as int? ?? 1,
    );
  }).toList();
}
