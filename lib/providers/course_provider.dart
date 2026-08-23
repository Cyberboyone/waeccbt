import 'package:flutter/material.dart';
import '../models/course.dart';
import '../models/progress.dart';
import '../services/hive_service.dart';

class CourseProvider with ChangeNotifier {
  final HiveService _hiveService = HiveService();

  final List<Course> _courses = [
    Course(id: 'eng', code: 'ENG', name: 'English Language', icon: '📖', colorHex: '#DCEEFF', mode: 'core', examQuestions: 80, examMinutes: 90),
    Course(id: 'mat', code: 'MAT', name: 'General Mathematics', icon: '📐', colorHex: '#FFF3CD', mode: 'core', examQuestions: 50, examMinutes: 90),
    Course(id: 'cve', code: 'CVE', name: 'Civic Education', icon: '⚖️', colorHex: '#E0E7FF', mode: 'core', examQuestions: 50, examMinutes: 60),
    Course(id: 'phy', code: 'PHY', name: 'Physics', icon: '⚡', colorHex: '#FFE8D6', mode: 'science', examQuestions: 50, examMinutes: 75),
    Course(id: 'che', code: 'CHE', name: 'Chemistry', icon: '⚗️', colorHex: '#DFF5E4', mode: 'science', examQuestions: 50, examMinutes: 75),
    Course(id: 'bio', code: 'BIO', name: 'Biology', icon: '🧬', colorHex: '#E2F8EC', mode: 'science', examQuestions: 60, examMinutes: 60),
    Course(id: 'agr', code: 'AGR', name: 'Agricultural Science', icon: '🌱', colorHex: '#DCFCE7', mode: 'science', examQuestions: 50, examMinutes: 60),
    Course(id: 'ani', code: 'ANI', name: 'Animal Husbandry', icon: '🐄', colorHex: '#D1FAE5', mode: 'science', examQuestions: 40, examMinutes: 60),
    Course(id: 'fsh', code: 'FSH', name: 'Fisheries', icon: '🐟', colorHex: '#BFDBFE', mode: 'science', examQuestions: 40, examMinutes: 60),
    Course(id: 'fmat', code: 'FMAT', name: 'Further Mathematics', icon: '∑', colorHex: '#FEF3C7', mode: 'science', examQuestions: 40, examMinutes: 150),
    Course(id: 'ict', code: 'ICT', name: 'Computer Studies', icon: '💻', colorHex: '#DDD6FE', mode: 'science', examQuestions: 40, examMinutes: 60),
    Course(id: 'fdn', code: 'FDN', name: 'Food & Nutrition', icon: '🍎', colorHex: '#FECACA', mode: 'science', examQuestions: 60, examMinutes: 60),
    Course(id: 'geo', code: 'GEO', name: 'Geography', icon: '🌍', colorHex: '#DBEAFE', mode: 'arts', examQuestions: 50, examMinutes: 60),
    Course(id: 'gov', code: 'GOV', name: 'Government', icon: '🏛️', colorHex: '#DCEEFF', mode: 'arts', examQuestions: 50, examMinutes: 60),
    Course(id: 'lit', code: 'LIT', name: 'Literature in English', icon: '📚', colorHex: '#EAE2FA', mode: 'arts', examQuestions: 50, examMinutes: 60),
    Course(id: 'crs', code: 'CRS', name: 'Christian Religious Studies', icon: '✝️', colorHex: '#FFEDD5', mode: 'arts', examQuestions: 50, examMinutes: 60),
    Course(id: 'irs', code: 'IRS', name: 'Islamic Religious Studies', icon: '☪️', colorHex: '#CCFBF1', mode: 'arts', examQuestions: 50, examMinutes: 60),
    Course(id: 'his', code: 'HIS', name: 'History', icon: '🏺', colorHex: '#E7E5E4', mode: 'arts', examQuestions: 50, examMinutes: 60),
    Course(id: 'eco', code: 'ECO', name: 'Economics', icon: '📈', colorHex: '#EAE2FA', mode: 'commercial', examQuestions: 50, examMinutes: 60),
    Course(id: 'com', code: 'COM', name: 'Commerce', icon: '🛒', colorHex: '#FFF3CD', mode: 'commercial', examQuestions: 50, examMinutes: 60),
    Course(id: 'acc', code: 'ACC', name: 'Financial Accounting', icon: '🧾', colorHex: '#DFF5E4', mode: 'commercial', examQuestions: 50, examMinutes: 60),
    Course(id: 'mkt', code: 'MKT', name: 'Marketing', icon: '📣', colorHex: '#FDE68A', mode: 'commercial', examQuestions: 40, examMinutes: 60),
  ];

  List<Course> get courses => _courses;
  final Map<String, CourseProgress> _progressMap = {};
  CourseProvider() { loadAllProgress(); }
  void loadAllProgress() {
    for (var course in _courses) {
      _progressMap[course.id] = _hiveService.getProgress(course.id);
    }
    notifyListeners();
  }
  CourseProgress getProgressForCourse(String courseId) {
    return _progressMap[courseId] ??
        CourseProgress(courseId: courseId, questionsAttempted: 0, correctCount: 0, bestScore: 0, lastAttemptDate: DateTime.now());
  }
  double getCompletionPercentage(String courseId) {
    final cachedQuestionsCount = _hiveService.getCachedQuestions(courseId).length;
    final total = cachedQuestionsCount > 0 ? cachedQuestionsCount : 100;
    final progress = getProgressForCourse(courseId);
    if (progress.questionsAttempted == 0) return 0.0;
    final pct = (progress.questionsAttempted / total);
    return pct > 1.0 ? 1.0 : pct;
  }
  Future<void> updateCourseProgress({required String courseId, required int additionalAttempted, required int additionalCorrect, int? newExamScore}) async {
    final current = getProgressForCourse(courseId);
    int updatedAttempted = current.questionsAttempted + additionalAttempted;
    int updatedCorrect = current.correctCount + additionalCorrect;
    int updatedBestScore = current.bestScore;
    if (newExamScore != null && newExamScore > current.bestScore) {
      updatedBestScore = newExamScore;
    }
    final updated = CourseProgress(courseId: courseId, questionsAttempted: updatedAttempted, correctCount: updatedCorrect, bestScore: updatedBestScore, lastAttemptDate: DateTime.now());
    _progressMap[courseId] = updated;
    await _hiveService.saveProgress(updated);
    notifyListeners();
  }
}
