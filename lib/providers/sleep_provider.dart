import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sleep_record.dart';

class SleepProvider with ChangeNotifier {
  List<SleepRecord> _records = [];
  bool _isLoading = true;
  bool _isInitialized = false;
  String? _error;
  Future<void>? _initFuture;

  List<SleepRecord> get records => _records;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;

  double get averageQuality {
    if (_records.isEmpty) return 0;
    final sum = _records.fold<int>(0, (prev, r) => prev + r.quality);
    return sum / _records.length;
  }

  double get averageHours {
    if (_records.isEmpty) return 0;
    final totalMinutes =
        _records.fold<int>(0, (prev, r) => prev + r.totalMinutes);
    return totalMinutes / _records.length / 60;
  }

  SleepProvider() {
    _initFuture = _initialize();
  }

  Future<void> _initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('sleep_records');
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        _records = jsonList
            .map((json) => SleepRecord.fromMap(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      _error = e.toString();
      _records = [];
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> loadRecords() async {
    if (_initFuture != null) {
      await _initFuture;
    }
  }

  Future<void> addRecord(int quality, int hours, int minutes,
      {String? note}) async {
    // Make sure initialization is complete before adding
    if (_initFuture != null) {
      await _initFuture;
    }

    try {
      _error = null;

      final record = SleepRecord(
        // Use timestamp-based unique ID (avoids static counter issues)
        id: DateTime.now().millisecondsSinceEpoch,
        quality: quality,
        hoursSlept: hours,
        minutesSlept: minutes,
        note: note,
        createdAt: DateTime.now(),
      );

      _records.insert(0, record);
      // Notify UI immediately so the new record appears
      notifyListeners();

      // Persist to disk
      await _saveRecords();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteRecord(int id) async {
    if (_initFuture != null) {
      await _initFuture;
    }
    _records.removeWhere((r) => r.id == id);
    notifyListeners();
    await _saveRecords();
  }

  Future<void> _saveRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _records.map((r) => r.toMap()).toList();
    await prefs.setString('sleep_records', jsonEncode(jsonList));
  }

  List<SleepRecord> getRecentRecords(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return _records.where((r) => r.createdAt.isAfter(cutoff)).toList();
  }
}
