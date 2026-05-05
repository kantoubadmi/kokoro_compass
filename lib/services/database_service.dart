import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/gratitude_entry.dart';
import '../models/happiness_record.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static SharedPreferences? _prefs;
  static int _gratitudeIdCounter = 0;
  static int _happinessIdCounter = 0;
  static int _meditationIdCounter = 0;

  DatabaseService._init();

  Future<SharedPreferences> get database async {
    if (_prefs != null) return _prefs!;
    _prefs = await SharedPreferences.getInstance();
    await _loadCounters();
    return _prefs!;
  }

  Future<void> _loadCounters() async {
    _gratitudeIdCounter = _prefs?.getInt('gratitude_id_counter') ?? 0;
    _happinessIdCounter = _prefs?.getInt('happiness_id_counter') ?? 0;
    _meditationIdCounter = _prefs?.getInt('meditation_id_counter') ?? 0;
  }

  Future<void> _saveCounters() async {
    await _prefs?.setInt('gratitude_id_counter', _gratitudeIdCounter);
    await _prefs?.setInt('happiness_id_counter', _happinessIdCounter);
    await _prefs?.setInt('meditation_id_counter', _meditationIdCounter);
  }

  // Gratitude Entries
  Future<int> insertGratitudeEntry(GratitudeEntry entry) async {
    await database;
    final entries = await getGratitudeEntries();
    _gratitudeIdCounter++;
    final newEntry = GratitudeEntry(
      id: _gratitudeIdCounter,
      content: entry.content,
      createdAt: entry.createdAt,
    );
    entries.insert(0, newEntry);
    await _saveGratitudeEntries(entries);
    await _saveCounters();
    return _gratitudeIdCounter;
  }

  Future<List<GratitudeEntry>> getGratitudeEntries() async {
    await database;
    final jsonString = _prefs?.getString('gratitude_entries');
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => GratitudeEntry.fromMap(json)).toList();
  }

  Future<void> _saveGratitudeEntries(List<GratitudeEntry> entries) async {
    final jsonList = entries.map((e) => e.toMap()).toList();
    await _prefs?.setString('gratitude_entries', jsonEncode(jsonList));
  }

  Future<int> deleteGratitudeEntry(int id) async {
    final entries = await getGratitudeEntries();
    entries.removeWhere((e) => e.id == id);
    await _saveGratitudeEntries(entries);
    return 1;
  }

  // Happiness Records
  Future<int> insertHappinessRecord(HappinessRecord record) async {
    await database;
    final records = await getHappinessRecords();
    _happinessIdCounter++;
    final newRecord = HappinessRecord(
      id: _happinessIdCounter,
      score: record.score,
      note: record.note,
      createdAt: record.createdAt,
    );
    records.insert(0, newRecord);
    await _saveHappinessRecords(records);
    await _saveCounters();
    return _happinessIdCounter;
  }

  Future<List<HappinessRecord>> getHappinessRecords({int? limit}) async {
    await database;
    final jsonString = _prefs?.getString('happiness_records');
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    var records = jsonList.map((json) => HappinessRecord.fromMap(json)).toList();

    if (limit != null && records.length > limit) {
      records = records.sublist(0, limit);
    }
    return records;
  }

  Future<void> _saveHappinessRecords(List<HappinessRecord> records) async {
    final jsonList = records.map((r) => r.toMap()).toList();
    await _prefs?.setString('happiness_records', jsonEncode(jsonList));
  }

  // Meditation Sessions
  Future<int> insertMeditationSession(Map<String, dynamic> session) async {
    await database;
    final sessions = await getMeditationSessions();
    _meditationIdCounter++;
    session['id'] = _meditationIdCounter;
    sessions.insert(0, session);
    await _saveMeditationSessions(sessions);
    await _saveCounters();
    return _meditationIdCounter;
  }

  Future<List<Map<String, dynamic>>> getMeditationSessions({int? limit}) async {
    await database;
    final jsonString = _prefs?.getString('meditation_sessions');
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    var sessions = jsonList.cast<Map<String, dynamic>>();

    if (limit != null && sessions.length > limit) {
      sessions = sessions.sublist(0, limit);
    }
    return sessions;
  }

  Future<void> _saveMeditationSessions(List<Map<String, dynamic>> sessions) async {
    await _prefs?.setString('meditation_sessions', jsonEncode(sessions));
  }

  Future<void> close() async {
    // SharedPreferences doesn't need to be closed
  }

  // Export all data as JSON
  Future<Map<String, dynamic>> exportAllData() async {
    await database;
    final gratitudeEntries = await getGratitudeEntries();
    final happinessRecords = await getHappinessRecords();
    final meditationSessions = await getMeditationSessions();

    return {
      'export_date': DateTime.now().toIso8601String(),
      'app_version': '1.0.0',
      'gratitude_entries': gratitudeEntries.map((e) => e.toMap()).toList(),
      'happiness_records': happinessRecords.map((r) => r.toMap()).toList(),
      'meditation_sessions': meditationSessions,
    };
  }

  // Import data from JSON
  Future<void> importData(Map<String, dynamic> data) async {
    await database;

    // Import gratitude entries
    if (data['gratitude_entries'] != null) {
      final entries = (data['gratitude_entries'] as List)
          .map((e) => GratitudeEntry.fromMap(e as Map<String, dynamic>))
          .toList();
      for (final entry in entries) {
        await insertGratitudeEntry(entry);
      }
    }

    // Import happiness records
    if (data['happiness_records'] != null) {
      final records = (data['happiness_records'] as List)
          .map((r) => HappinessRecord.fromMap(r as Map<String, dynamic>))
          .toList();
      for (final record in records) {
        await insertHappinessRecord(record);
      }
    }

    // Import meditation sessions
    if (data['meditation_sessions'] != null) {
      final sessions = (data['meditation_sessions'] as List)
          .cast<Map<String, dynamic>>();
      for (final session in sessions) {
        final sessionCopy = Map<String, dynamic>.from(session);
        sessionCopy.remove('id');
        await insertMeditationSession(sessionCopy);
      }
    }
  }

  // Clear all data
  Future<void> clearAllData() async {
    await database;
    await _prefs?.remove('gratitude_entries');
    await _prefs?.remove('happiness_records');
    await _prefs?.remove('meditation_sessions');
    await _prefs?.remove('gratitude_id_counter');
    await _prefs?.remove('happiness_id_counter');
    await _prefs?.remove('meditation_id_counter');
    _gratitudeIdCounter = 0;
    _happinessIdCounter = 0;
    _meditationIdCounter = 0;
  }
}
