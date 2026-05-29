import 'package:fc_app3_dailypad/models/task_model.dart';
import 'package:fc_app3_dailypad/services/local_storage_service.dart';
import 'package:fc_app3_dailypad/utils/date_helpers.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class TasksProvider extends ChangeNotifier {
  final List<Task> _tasks = [];
  final Map<String, Task> _byId = {};

  List<Task>? _todayCache;
  List<Task>? _upcomingCache;
  List<Task>? _completedCache;
  int? _cacheVersion;
  int _dataVersion = 0;

  List<Task> get tasks => List.unmodifiable(_tasks);
  int get taskCount => _tasks.length;

  Future<void> load() async {
    try {
      final maps = LocalStorageService.loadTasks();
      _tasks
        ..clear()
        ..addAll(maps.map(Task.fromMap));
      _rebuildIndex();
      _invalidateCaches();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load tasks: $e');
    }
  }

  List<Task> get todayTasks {
    _ensureCaches();
    return _todayCache!;
  }

  List<Task> get upcomingTasks {
    _ensureCaches();
    return _upcomingCache!;
  }

  List<Task> get completedTasks {
    _ensureCaches();
    return _completedCache!;
  }

  List<Task> get todayTasksForHome => todayTasks.take(5).toList();

  Task? getById(String id) => _byId[id];

  Future<Task> addTask({
    required String title,
    required String description,
    DateTime? dueDate,
    TaskPriority priority = TaskPriority.medium,
  }) async {
    final now = DateTime.now();
    final task = Task(
      id: const Uuid().v4(),
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      createdAt: now,
      updatedAt: now,
    );
    _tasks.add(task);
    _byId[task.id] = task;
    await LocalStorageService.saveTask(task.toMap());
    _invalidateCaches();
    notifyListeners();
    return task;
  }

  Future<void> updateTask(Task task) async {
    task.updatedAt = DateTime.now();
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      _byId[task.id] = task;
      await LocalStorageService.saveTask(task.toMap());
      _invalidateCaches();
      notifyListeners();
    }
  }

  Future<void> toggleCompleted(String id) async {
    final task = getById(id);
    if (task != null) {
      task.isCompleted = !task.isCompleted;
      task.updatedAt = DateTime.now();
      await LocalStorageService.saveTask(task.toMap());
      _invalidateCaches();
      notifyListeners();
    }
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    _byId.remove(id);
    await LocalStorageService.deleteTask(id);
    _invalidateCaches();
    notifyListeners();
  }

  Future<void> clearAll() async {
    _tasks.clear();
    _byId.clear();
    await LocalStorageService.clearAllTasks();
    _invalidateCaches();
    notifyListeners();
  }

  void _rebuildIndex() {
    _byId
      ..clear()
      ..addEntries(_tasks.map((t) => MapEntry(t.id, t)));
  }

  void _ensureCaches() {
    if (_cacheVersion == _dataVersion) return;
    _cacheVersion = _dataVersion;

    _todayCache = _sorted(
      _tasks.where(
        (t) => !t.isCompleted && DateHelpers.isTodayOrOverdue(t.dueDate),
      ),
    );
    _upcomingCache = _sorted(
      _tasks.where(
        (t) =>
            !t.isCompleted &&
            (t.dueDate == null || DateHelpers.isAfterToday(t.dueDate)),
      ),
    );
    _completedCache = _sorted(
      _tasks.where((t) => t.isCompleted),
      completed: true,
    );
  }

  void _invalidateCaches() {
    _dataVersion++;
    _cacheVersion = null;
  }

  List<Task> _sorted(Iterable<Task> items, {bool completed = false}) {
    final list = List<Task>.from(items);
    list.sort((a, b) {
      if (!completed) {
        final priorityCompare = b.priority.index.compareTo(a.priority.index);
        if (priorityCompare != 0) return priorityCompare;
        if (a.dueDate != null && b.dueDate != null) {
          return a.dueDate!.compareTo(b.dueDate!);
        }
        if (a.dueDate != null) return -1;
        if (b.dueDate != null) return 1;
      }
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return list;
  }
}
