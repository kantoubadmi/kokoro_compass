import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DailyGoal {
  final String id;
  final String title;
  final String emoji;
  bool isCompleted;
  final DateTime createdAt;

  DailyGoal({
    required this.id,
    required this.title,
    required this.emoji,
    this.isCompleted = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'emoji': emoji,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DailyGoal.fromMap(Map<String, dynamic> map) {
    return DailyGoal(
      id: map['id'],
      title: map['title'],
      emoji: map['emoji'],
      isCompleted: map['isCompleted'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

class GoalsProvider with ChangeNotifier {
  List<DailyGoal> _goals = [];
  String? _dailyIntention;
  DateTime? _lastResetDate;

  List<DailyGoal> get goals => _goals;
  String? get dailyIntention => _dailyIntention;

  int get completedCount => _goals.where((g) => g.isCompleted).length;
  int get totalCount => _goals.length;
  double get completionRate => totalCount > 0 ? completedCount / totalCount : 0;

  final List<Map<String, String>> suggestedGoals = [
    {'emoji': '🧘', 'title': '5分間瞑想する'},
    {'emoji': '📝', 'title': '感謝を3つ書く'},
    {'emoji': '💧', 'title': '水を8杯飲む'},
    {'emoji': '🚶', 'title': '10分散歩する'},
    {'emoji': '😊', 'title': '誰かに優しくする'},
    {'emoji': '📵', 'title': 'SNSを1時間控える'},
    {'emoji': '🌿', 'title': '深呼吸を10回する'},
    {'emoji': '📖', 'title': '10分間読書する'},
    {'emoji': '🎵', 'title': '好きな音楽を聴く'},
    {'emoji': '🌙', 'title': '23時前に寝る'},
  ];

  GoalsProvider() {
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if we need to reset for a new day
    final lastResetStr = prefs.getString('goals_last_reset');
    if (lastResetStr != null) {
      _lastResetDate = DateTime.parse(lastResetStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final lastReset = DateTime(
        _lastResetDate!.year,
        _lastResetDate!.month,
        _lastResetDate!.day,
      );

      if (today.isAfter(lastReset)) {
        // New day - reset goals
        await _resetGoals();
        return;
      }
    }

    // Load existing goals
    final goalsJson = prefs.getString('daily_goals');
    if (goalsJson != null) {
      final List<dynamic> goalsList = jsonDecode(goalsJson);
      _goals = goalsList.map((g) => DailyGoal.fromMap(g)).toList();
    }

    _dailyIntention = prefs.getString('daily_intention');
    notifyListeners();
  }

  Future<void> _resetGoals() async {
    final prefs = await SharedPreferences.getInstance();
    _goals = [];
    _dailyIntention = null;
    await prefs.remove('daily_goals');
    await prefs.remove('daily_intention');
    await prefs.setString('goals_last_reset', DateTime.now().toIso8601String());
    notifyListeners();
  }

  Future<void> _saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final goalsList = _goals.map((g) => g.toMap()).toList();
    await prefs.setString('daily_goals', jsonEncode(goalsList));
    await prefs.setString('goals_last_reset', DateTime.now().toIso8601String());
  }

  Future<void> addGoal(String title, String emoji) async {
    final goal = DailyGoal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      emoji: emoji,
      createdAt: DateTime.now(),
    );
    _goals.add(goal);
    await _saveGoals();
    notifyListeners();
  }

  Future<void> toggleGoal(String id) async {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index != -1) {
      _goals[index].isCompleted = !_goals[index].isCompleted;
      await _saveGoals();
      notifyListeners();
    }
  }

  Future<void> removeGoal(String id) async {
    _goals.removeWhere((g) => g.id == id);
    await _saveGoals();
    notifyListeners();
  }

  Future<void> setDailyIntention(String intention) async {
    _dailyIntention = intention;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('daily_intention', intention);
    notifyListeners();
  }
}
