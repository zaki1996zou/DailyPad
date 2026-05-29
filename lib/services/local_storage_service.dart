import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageService {
  LocalStorageService._();

  static const String notesBoxName = 'notes';
  static const String tasksBoxName = 'tasks';
  static const String settingsBoxName = 'settings';

  static const String keyDarkMode = 'isDarkMode';
  static const String keyOnboardingComplete = 'hasSeenOnboarding';

  static late Box<dynamic> _notesBox;
  static late Box<dynamic> _tasksBox;
  static late Box<dynamic> _settingsBox;

  /// [storagePath] is for tests only; production uses [Hive.initFlutter].
  static Future<void> init({String? storagePath}) async {
    if (storagePath != null) {
      Hive.init(storagePath);
    } else {
      await Hive.initFlutter();
    }
    _notesBox = await Hive.openBox(notesBoxName);
    _tasksBox = await Hive.openBox(tasksBoxName);
    _settingsBox = await Hive.openBox(settingsBoxName);
  }

  static Map<String, dynamic> _normalizeMap(dynamic value) {
    if (value is! Map) {
      throw const FormatException('Invalid stored record');
    }
    return value.map(
      (key, val) => MapEntry(key.toString(), val),
    );
  }

  // Notes
  static List<Map<String, dynamic>> loadNotes() {
    final results = <Map<String, dynamic>>[];
    for (final value in _notesBox.values) {
      try {
        results.add(_normalizeMap(value));
      } catch (e) {
        debugPrint('Skipping corrupt note: $e');
      }
    }
    return results;
  }

  static Future<void> saveNote(Map<String, dynamic> note) async {
    await _notesBox.put(note['id'], note);
  }

  static Future<void> deleteNote(String id) async {
    await _notesBox.delete(id);
  }

  // Tasks
  static List<Map<String, dynamic>> loadTasks() {
    final results = <Map<String, dynamic>>[];
    for (final value in _tasksBox.values) {
      try {
        results.add(_normalizeMap(value));
      } catch (e) {
        debugPrint('Skipping corrupt task: $e');
      }
    }
    return results;
  }

  static Future<void> saveTask(Map<String, dynamic> task) async {
    await _tasksBox.put(task['id'], task);
  }

  static Future<void> deleteTask(String id) async {
    await _tasksBox.delete(id);
  }

  static Future<void> clearAllNotes() async {
    await _notesBox.clear();
  }

  static Future<void> clearAllTasks() async {
    await _tasksBox.clear();
  }

  /// Removes all notes and tasks (appearance/onboarding settings are kept).
  static Future<void> clearAllUserContent() async {
    await Future.wait([clearAllNotes(), clearAllTasks()]);
  }

  // Settings
  static bool get isDarkMode =>
      _settingsBox.get(keyDarkMode, defaultValue: false) as bool;

  static Future<void> setDarkMode(bool value) async {
    await _settingsBox.put(keyDarkMode, value);
  }

  static bool get hasSeenOnboarding =>
      _settingsBox.get(keyOnboardingComplete, defaultValue: false) as bool;

  static Future<void> setOnboardingComplete() async {
    await _settingsBox.put(keyOnboardingComplete, true);
  }
}
