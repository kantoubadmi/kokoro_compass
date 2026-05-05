import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sleep_record.dart';

class SleepProvider with ChangeNotifier {
  List<SleepRecord> _records = [];
  bool _isLoading = false;
  String? _error;
  static int _idCounter = 0;

  List<SleepRecord> get records => _records;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get averageQuality {
    if (_records.isEmpty) return 0;
    final sum = _records.fold<int>(0, (prev, r) => prev + r.quality);
    return sum / _records.length;
  }

  double get averageHours {
    if (_records.isEmpty) return 0;
    final totalMinutes = _records.fold<int>(0, (prev, r) => prev + r.totalMinutes);
    return totalMinutes / _records.length / 60;
  }

  SleepProvider() {
    loadRecords();
  }

  Future<void> loadRecords() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      _idCounter = prefs.getInt('sleep_id_counter') ?? 0;

      final jsonString = prefs.getString('sleep_records');
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        _records = jsonList.map((json) => SleepRecord.fromMap(json)).toList();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addRecord(int quality, int hours, int minutes, {String? note}) async {
    try {
      _error = null;
      _idCounter++;

      final record = SleepRecord(
        id: _idCounter,
        quality: quality,
        hoursSlept: hours,
        minutesSlept: minutes,
        note: note,
        createdAt: DateTime.now(),
      );

      _records.insert(0, record);
      await _saveRecords();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _saveRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _records.map((r) => r.toMap()).toList();
    await prefs.setString('sleep_records', jsonEncode(jsonList));
    await prefs.setInt('sleep_id_counter', _idCounter);
  }

  List<SleepRecord> getRecentRecords(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return _records.where((r) => r.createdAt.isAfter(cutoff)).toList();
  }
}
