import 'dart:io';

import 'package:fc_app3_dailypad/app/app.dart';
import 'package:fc_app3_dailypad/providers/notes_provider.dart';
import 'package:fc_app3_dailypad/providers/tasks_provider.dart';
import 'package:fc_app3_dailypad/providers/theme_provider.dart';
import 'package:fc_app3_dailypad/services/local_storage_service.dart';
import 'package:fc_app3_dailypad/utils/constants.dart';
import 'package:fc_app3_dailypad/utils/date_helpers.dart';
import 'package:fc_app3_dailypad/utils/text_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('helpers', () {
    test('TextHelpers matches case-insensitive query', () {
      expect(TextHelpers.matchesQuery('Hello World', 'world'), isTrue);
      expect(TextHelpers.matchesQuery('Hello', 'xyz'), isFalse);
    });

    test('DateHelpers identifies today and overdue', () {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      expect(DateHelpers.isToday(today), isTrue);
      expect(DateHelpers.isTodayOrOverdue(yesterday), isTrue);
      expect(DateHelpers.isTodayOrOverdue(today.add(const Duration(days: 2))),
          isFalse);
    });
  });

  group('app', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('dailypad_test_');
      await LocalStorageService.init(storagePath: tempDir.path);
      await LocalStorageService.setOnboardingComplete();
    });

    tearDown(() async {
      await LocalStorageService.clearAllUserContent();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    testWidgets('DailyPad shows splash then home navigation', (tester) async {
      final themeProvider = ThemeProvider();
      final notesProvider = NotesProvider();
      final tasksProvider = TasksProvider();
      await themeProvider.load();
      await notesProvider.load();
      await tasksProvider.load();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
            ChangeNotifierProvider<NotesProvider>.value(value: notesProvider),
            ChangeNotifierProvider<TasksProvider>.value(value: tasksProvider),
          ],
          child: const DailyPadApp(),
        ),
      );

      expect(find.text(AppStrings.appName), findsOneWidget);

      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.byType(NavigationBar), findsOneWidget);
    });
  });
}
