import 'package:fc_app3_dailypad/app/app.dart';
import 'package:fc_app3_dailypad/providers/notes_provider.dart';
import 'package:fc_app3_dailypad/providers/tasks_provider.dart';
import 'package:fc_app3_dailypad/providers/theme_provider.dart';
import 'package:fc_app3_dailypad/services/local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.init();

  final themeProvider = ThemeProvider();
  final notesProvider = NotesProvider();
  final tasksProvider = TasksProvider();

  await Future.wait([
    themeProvider.load(),
    notesProvider.load(),
    tasksProvider.load(),
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ChangeNotifierProvider<NotesProvider>.value(value: notesProvider),
        ChangeNotifierProvider<TasksProvider>.value(value: tasksProvider),
      ],
      child: const DailyPadApp(),
    ),
  );
}
