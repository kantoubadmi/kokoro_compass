import 'package:flutter/material.dart';
import '../models/happiness_record.dart';
import '../services/database_service.dart';

class HappinessProvider with ChangeNotifier {
  List<HappinessRecord> _records = [];
  bool _isLoading = false;
  String? _error;

  List<HappinessRecord> get records => _records;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get averageScore {
    if (_records.isEmpty) return 0;
    final sum = _records.fold<int>(0, (prev, record) => prev + record.score);
    return sum / _records.length;
  }

  HappinessProvider() {
    loadRecords();
  }

  Future<void> loadRecords() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _records = await DatabaseService.instance.getHappinessRecords(limit: 30);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addRecord(int score, {String? note}) async {
    try {
      _error = null;
      final record = HappinessRecord(
        score: score,
        note: note,
        createdAt: DateTime.now(),
      );
      await DatabaseService.instance.insertHappinessRecord(record);
      await loadRecords();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}