import 'package:flutter/material.dart';
import '../models/gratitude_entry.dart';
import '../services/database_service.dart';

class GratitudeProvider with ChangeNotifier {
  List<GratitudeEntry> _entries = [];
  bool _isLoading = false;
  String? _error;
  GratitudeEntry? _lastDeletedEntry;

  List<GratitudeEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  String? get error => _error;
  GratitudeEntry? get lastDeletedEntry => _lastDeletedEntry;

  GratitudeProvider() {
    loadEntries();
  }

  Future<void> loadEntries() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _entries = await DatabaseService.instance.getGratitudeEntries();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addEntry(String content) async {
    try {
      _error = null;
      final entry = GratitudeEntry(
        content: content,
        createdAt: DateTime.now(),
      );
      await DatabaseService.instance.insertGratitudeEntry(entry);
      await loadEntries();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteEntry(int id) async {
    try {
      _error = null;
      // Store the entry before deleting for undo functionality
      _lastDeletedEntry = _entries.firstWhere((e) => e.id == id);
      await DatabaseService.instance.deleteGratitudeEntry(id);
      await loadEntries();
    } catch (e) {
      _error = e.toString();
      _lastDeletedEntry = null;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> undoDelete() async {
    if (_lastDeletedEntry == null) return;

    try {
      _error = null;
      await DatabaseService.instance.insertGratitudeEntry(_lastDeletedEntry!);
      _lastDeletedEntry = null;
      await loadEntries();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clearLastDeleted() {
    _lastDeletedEntry = null;
  }
}