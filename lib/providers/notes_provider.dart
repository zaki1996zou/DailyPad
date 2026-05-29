import 'package:fc_app3_dailypad/models/note_model.dart';
import 'package:fc_app3_dailypad/services/local_storage_service.dart';
import 'package:fc_app3_dailypad/utils/text_helpers.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class NotesProvider extends ChangeNotifier {
  final List<Note> _notes = [];
  final Map<String, Note> _byId = {};

  String _searchQuery = '';
  NoteCategory? _categoryFilter;

  List<Note>? _filteredCache;
  List<Note>? _recentCache;
  String? _filterCacheKey;

  List<Note> get notes => List.unmodifiable(_notes);
  String get searchQuery => _searchQuery;
  NoteCategory? get categoryFilter => _categoryFilter;
  int get noteCount => _notes.length;

  Future<void> load() async {
    try {
      final maps = LocalStorageService.loadNotes();
      _notes
        ..clear()
        ..addAll(maps.map(Note.fromMap));
      _rebuildIndex();
      _sortNotes();
      _invalidateCaches();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load notes: $e');
    }
  }

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    _invalidateCaches();
    notifyListeners();
  }

  void setCategoryFilter(NoteCategory? category) {
    if (_categoryFilter == category) return;
    _categoryFilter = category;
    _invalidateCaches();
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _categoryFilter = null;
    _invalidateCaches();
    notifyListeners();
  }

  List<Note> get filteredNotes {
    final key = '$_searchQuery|$_categoryFilter';
    if (_filteredCache != null && _filterCacheKey == key) {
      return _filteredCache!;
    }
    _filterCacheKey = key;
    final query = _searchQuery;
    _filteredCache = _notes.where((note) {
      final matchesSearch = query.isEmpty ||
          TextHelpers.matchesQuery(note.title, query) ||
          TextHelpers.matchesQuery(note.content, query);
      final matchesCategory =
          _categoryFilter == null || note.category == _categoryFilter;
      return matchesSearch && matchesCategory;
    }).toList();
    return _filteredCache!;
  }

  List<Note> get recentNotes {
    if (_recentCache != null) return _recentCache!;
    _recentCache = _notes.take(5).toList();
    return _recentCache!;
  }

  List<Note> searchNotes(String query) {
    if (query.isEmpty) return const [];
    return _notes
        .where(
          (n) =>
              TextHelpers.matchesQuery(n.title, query) ||
              TextHelpers.matchesQuery(n.content, query),
        )
        .take(20)
        .toList();
  }

  Note? getById(String id) => _byId[id];

  Future<Note> addNote({
    required String title,
    required String content,
    required NoteCategory category,
    bool isFavorite = false,
    bool isPinned = false,
  }) async {
    final now = DateTime.now();
    final note = Note(
      id: const Uuid().v4(),
      title: title,
      content: content,
      category: category,
      isFavorite: isFavorite,
      isPinned: isPinned,
      createdAt: now,
      updatedAt: now,
    );
    _notes.add(note);
    _byId[note.id] = note;
    _sortNotes();
    await LocalStorageService.saveNote(note.toMap());
    _invalidateCaches();
    notifyListeners();
    return note;
  }

  Future<void> updateNote(Note note) async {
    note.updatedAt = DateTime.now();
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
      _byId[note.id] = note;
      _sortNotes();
      await LocalStorageService.saveNote(note.toMap());
      _invalidateCaches();
      notifyListeners();
    }
  }

  Future<void> deleteNote(String id) async {
    _notes.removeWhere((n) => n.id == id);
    _byId.remove(id);
    await LocalStorageService.deleteNote(id);
    _invalidateCaches();
    notifyListeners();
  }

  Future<void> clearAll() async {
    _notes.clear();
    _byId.clear();
    await LocalStorageService.clearAllNotes();
    _invalidateCaches();
    notifyListeners();
  }

  void _rebuildIndex() {
    _byId
      ..clear()
      ..addEntries(_notes.map((n) => MapEntry(n.id, n)));
  }

  void _sortNotes() {
    _notes.sort((a, b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });
  }

  void _invalidateCaches() {
    _filteredCache = null;
    _recentCache = null;
    _filterCacheKey = null;
  }
}
