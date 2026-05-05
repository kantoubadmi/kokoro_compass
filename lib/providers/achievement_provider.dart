import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Achievement {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final int requiredCount;
  final String type; // gratitude, happiness, meditation, streak
  bool isUnlocked;
  DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.requiredCount,
    required this.type,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  void unlock() {
    if (!isUnlocked) {
      isUnlocked = true;
      unlockedAt = DateTime.now();
    }
  }
}

class AchievementProvider with ChangeNotifier {
  List<Achievement> _achievements = [];
  List<Achievement> _newlyUnlocked = [];

  List<Achievement> get achievements => _achievements;
  List<Achievement> get unlockedAchievements =>
      _achievements.where((a) => a.isUnlocked).toList();
  List<Achievement> get lockedAchievements =>
      _achievements.where((a) => !a.isUnlocked).toList();
  List<Achievement> get newlyUnlocked => _newlyUnlocked;

  int get totalAchievements => _achievements.length;
  int get unlockedCount => unlockedAchievements.length;

  AchievementProvider() {
    _initAchievements();
    _loadProgress();
  }

  void _initAchievements() {
    _achievements = [
      // Gratitude achievements
      Achievement(
        id: 'gratitude_1',
        title: '感謝のはじまり',
        description: '初めての感謝を記録',
        emoji: '🌱',
        requiredCount: 1,
        type: 'gratitude',
      ),
      Achievement(
        id: 'gratitude_10',
        title: '感謝の習慣',
        description: '感謝を10回記録',
        emoji: '🌿',
        requiredCount: 10,
        type: 'gratitude',
      ),
      Achievement(
        id: 'gratitude_50',
        title: '感謝マスター',
        description: '感謝を50回記録',
        emoji: '🌳',
        requiredCount: 50,
        type: 'gratitude',
      ),
      Achievement(
        id: 'gratitude_100',
        title: '感謝の達人',
        description: '感謝を100回記録',
        emoji: '🏆',
        requiredCount: 100,
        type: 'gratitude',
      ),

      // Happiness achievements
      Achievement(
        id: 'happiness_1',
        title: '気持ちの記録',
        description: '初めての幸福度を記録',
        emoji: '💫',
        requiredCount: 1,
        type: 'happiness',
      ),
      Achievement(
        id: 'happiness_7',
        title: '1週間の振り返り',
        description: '幸福度を7回記録',
        emoji: '📊',
        requiredCount: 7,
        type: 'happiness',
      ),
      Achievement(
        id: 'happiness_30',
        title: '1ヶ月の軌跡',
        description: '幸福度を30回記録',
        emoji: '📈',
        requiredCount: 30,
        type: 'happiness',
      ),

      // Meditation achievements
      Achievement(
        id: 'meditation_1',
        title: '瞑想入門',
        description: '初めての瞑想セッション',
        emoji: '🧘',
        requiredCount: 1,
        type: 'meditation',
      ),
      Achievement(
        id: 'meditation_10',
        title: '瞑想の習慣',
        description: '10回の瞑想セッション',
        emoji: '🕯️',
        requiredCount: 10,
        type: 'meditation',
      ),
      Achievement(
        id: 'meditation_30',
        title: '瞑想マスター',
        description: '30回の瞑想セッション',
        emoji: '✨',
        requiredCount: 30,
        type: 'meditation',
      ),

      // Streak achievements
      Achievement(
        id: 'streak_3',
        title: '3日連続',
        description: '3日連続で感謝を記録',
        emoji: '🔥',
        requiredCount: 3,
        type: 'streak',
      ),
      Achievement(
        id: 'streak_7',
        title: '1週間連続',
        description: '7日連続で感謝を記録',
        emoji: '💪',
        requiredCount: 7,
        type: 'streak',
      ),
      Achievement(
        id: 'streak_30',
        title: '30日連続',
        description: '30日連続で感謝を記録',
        emoji: '👑',
        requiredCount: 30,
        type: 'streak',
      ),

      // Special achievements
      Achievement(
        id: 'sleep_1',
        title: '睡眠記録開始',
        description: '初めての睡眠記録',
        emoji: '😴',
        requiredCount: 1,
        type: 'sleep',
      ),
      Achievement(
        id: 'sleep_7',
        title: '睡眠の習慣',
        description: '7日間の睡眠記録',
        emoji: '🌙',
        requiredCount: 7,
        type: 'sleep',
      ),
    ];
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('achievements_progress');
    if (jsonString != null) {
      final List<dynamic> savedList = jsonDecode(jsonString);
      for (final saved in savedList) {
        final achievement = _achievements.firstWhere(
          (a) => a.id == saved['id'],
          orElse: () => _achievements.first,
        );
        if (saved['isUnlocked'] == true) {
          achievement.isUnlocked = true;
          if (saved['unlockedAt'] != null) {
            achievement.unlockedAt = DateTime.parse(saved['unlockedAt']);
          }
        }
      }
    }
    notifyListeners();
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> saveList =
        _achievements.map((a) => a.toMap()).toList();
    await prefs.setString('achievements_progress', jsonEncode(saveList));
  }

  void clearNewlyUnlocked() {
    _newlyUnlocked = [];
    notifyListeners();
  }

  Future<void> checkAchievements({
    int? gratitudeCount,
    int? happinessCount,
    int? meditationCount,
    int? streakCount,
    int? sleepCount,
  }) async {
    _newlyUnlocked = [];

    for (final achievement in _achievements) {
      if (achievement.isUnlocked) continue;

      int? count;
      switch (achievement.type) {
        case 'gratitude':
          count = gratitudeCount;
          break;
        case 'happiness':
          count = happinessCount;
          break;
        case 'meditation':
          count = meditationCount;
          break;
        case 'streak':
          count = streakCount;
          break;
        case 'sleep':
          count = sleepCount;
          break;
      }

      if (count != null && count >= achievement.requiredCount) {
        achievement.unlock();
        _newlyUnlocked.add(achievement);
      }
    }

    if (_newlyUnlocked.isNotEmpty) {
      await _saveProgress();
      notifyListeners();
    }
  }
}
