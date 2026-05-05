import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/happiness_record.dart';
import '../models/gratitude_entry.dart';

class StatisticsProvider with ChangeNotifier {
  List<HappinessRecord> _happinessRecords = [];
  List<GratitudeEntry> _gratitudeEntries = [];
  List<Map<String, dynamic>> _meditationSessions = [];
  bool _isLoading = false;
  String? _error;

  List<HappinessRecord> get happinessRecords => _happinessRecords;
  List<GratitudeEntry> get gratitudeEntries => _gratitudeEntries;
  List<Map<String, dynamic>> get meditationSessions => _meditationSessions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Happiness Statistics
  double get averageHappiness {
    if (_happinessRecords.isEmpty) return 0;
    final sum = _happinessRecords.fold<int>(0, (prev, r) => prev + r.score);
    return sum / _happinessRecords.length;
  }

  int get totalHappinessRecords => _happinessRecords.length;

  Map<String, double> get weeklyHappinessAverage {
    final now = DateTime.now();
    final Map<String, List<int>> weeklyScores = {};

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = '${date.month}/${date.day}';
      weeklyScores[key] = [];
    }

    for (final record in _happinessRecords) {
      final diff = now.difference(record.createdAt).inDays;
      if (diff < 7) {
        final key = '${record.createdAt.month}/${record.createdAt.day}';
        if (weeklyScores.containsKey(key)) {
          weeklyScores[key]!.add(record.score);
        }
      }
    }

    return weeklyScores.map((key, scores) {
      if (scores.isEmpty) return MapEntry(key, 0.0);
      return MapEntry(key, scores.reduce((a, b) => a + b) / scores.length);
    });
  }

  // Gratitude Statistics
  int get totalGratitudeEntries => _gratitudeEntries.length;

  int get thisWeekGratitudeCount {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return _gratitudeEntries.where((e) =>
      e.createdAt.isAfter(DateTime(weekStart.year, weekStart.month, weekStart.day))
    ).length;
  }

  int get currentStreak {
    if (_gratitudeEntries.isEmpty) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int streak = 0;
    DateTime checkDate = today;

    final sortedEntries = List<GratitudeEntry>.from(_gratitudeEntries)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    Set<String> entryDates = sortedEntries.map((e) =>
      '${e.createdAt.year}-${e.createdAt.month}-${e.createdAt.day}'
    ).toSet();

    while (true) {
      final dateKey = '${checkDate.year}-${checkDate.month}-${checkDate.day}';
      if (entryDates.contains(dateKey)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (checkDate == today) {
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  // Meditation Statistics
  int get totalMeditationSessions => _meditationSessions.length;

  int get totalMeditationMinutes {
    if (_meditationSessions.isEmpty) return 0;
    final totalSeconds = _meditationSessions.fold<int>(
      0,
      (prev, s) => prev + (s['duration'] as int? ?? 0)
    );
    return totalSeconds ~/ 60;
  }

  Map<String, int> get meditationTypeCount {
    final Map<String, int> counts = {};
    for (final session in _meditationSessions) {
      final type = session['type'] as String? ?? '不明';
      counts[type] = (counts[type] ?? 0) + 1;
    }
    return counts;
  }

  StatisticsProvider() {
    loadAllData();
  }

  Future<void> loadAllData() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _happinessRecords = await DatabaseService.instance.getHappinessRecords();
      _gratitudeEntries = await DatabaseService.instance.getGratitudeEntries();
      _meditationSessions = await DatabaseService.instance.getMeditationSessions();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
