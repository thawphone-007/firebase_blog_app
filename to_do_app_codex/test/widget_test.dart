import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:to_do_app_codex/main.dart';

void main() {
  late Directory hiveDirectory;
  late Box taskBox;

  setUpAll(() async {
    hiveDirectory = await Directory.systemTemp.createTemp('to_do_app_test_');
    Hive.init(hiveDirectory.path);
  });

  setUp(() async {
    taskBox = await Hive.openBox('tasks');
  });

  tearDown(() async {
    await taskBox.clear();
    await taskBox.close();
  });

  tearDownAll(() async {
    await hiveDirectory.delete(recursive: true);
  });

  testWidgets('users can add, complete, and delete a task', (tester) async {
    await tester.pumpWidget(MyApp(taskBox: taskBox));

    await tester.enterText(find.byType(TextField), 'Buy groceries');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('Buy groceries'), findsOneWidget);
    expect(taskBox.length, 1);

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
    expect((taskBox.values.single as Map)['isCompleted'], isTrue);

    await tester.tap(find.byTooltip('Delete task'));
    await tester.pumpAndSettle();
    expect(find.text('Buy groceries'), findsNothing);
    expect(taskBox.isEmpty, isTrue);
  });
}
