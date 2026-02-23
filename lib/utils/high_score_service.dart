import 'package:shared_preferences/shared_preferences.dart';

class HighScoreService {
  static const _cleanUpKey = 'highscore_cleanup';
  static const _catchTrashKey = 'highscore_catchtrash';
  static const _quizKey = 'highscore_quiz';

  static Future<int> getCleanUpHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_cleanUpKey) ?? 0;
  }

  static Future<int> getCatchTrashHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_catchTrashKey) ?? 0;
  }

  static Future<int> getQuizHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_quizKey) ?? 0;
  }

  static Future<void> saveCleanUpHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt(_cleanUpKey) ?? 0;
    if (score > current) {
      await prefs.setInt(_cleanUpKey, score);
    }
  }

  static Future<void> saveCatchTrashHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt(_catchTrashKey) ?? 0;
    if (score > current) {
      await prefs.setInt(_catchTrashKey, score);
    }
  }

  static Future<void> saveQuizHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt(_quizKey) ?? 0;
    if (score > current) {
      await prefs.setInt(_quizKey, score);
    }
  }
}
