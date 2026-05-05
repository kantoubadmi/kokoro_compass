import 'package:flutter/material.dart';
import '../services/database_service.dart';

class MeditationProvider with ChangeNotifier {
  bool _isMeditating = false;
  int _currentDuration = 0;
  String _selectedType = '呼吸瞑想';
  List<Map<String, dynamic>> _sessions = [];
  bool _isLoading = false;
  String? _error;

  bool get isMeditating => _isMeditating;
  int get currentDuration => _currentDuration;
  String get selectedType => _selectedType;
  List<Map<String, dynamic>> get sessions => _sessions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final List<String> meditationTypes = [
    '呼吸瞑想',
    'ボディスキャン',
    'マインドフルネス',
    '慈悲の瞑想',
  ];

  MeditationProvider() {
    loadSessions();
  }

  void setMeditationType(String type) {
    _selectedType = type;
    notifyListeners();
  }

  void startMeditation() {
    _isMeditating = true;
    _currentDuration = 0;
    notifyListeners();
  }

  void updateDuration(int seconds) {
    _currentDuration = seconds;
    notifyListeners();
  }

  Future<void> stopMeditation() async {
    _isMeditating = false;
    if (_currentDuration > 0) {
      try {
        await DatabaseService.instance.insertMeditationSession({
          'duration': _currentDuration,
          'type': _selectedType,
          'created_at': DateTime.now().toIso8601String(),
        });
        await loadSessions();
      } catch (e) {
        _error = e.toString();
        notifyListeners();
      }
    }
    notifyListeners();
  }

  Future<void> loadSessions() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _sessions = await DatabaseService.instance.getMeditationSessions(limit: 10);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}