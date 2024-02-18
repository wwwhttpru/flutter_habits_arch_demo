import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits_arch_demo/core/di/di.dart';
import 'package:habits_arch_demo/ui/screens/home/home_screen.dart';
import 'package:integration_test/integration_test.dart';

import '../test/ui/screens/home/home_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late final DependencyContainer container;

  setUpAll(() {
    configureDependencies();
    container = diContainer;
  });

  testWidgets(
    'Добавление новой привычки',
    (widgetTester) async {
      await widgetTester.pumpWidget(TestHomeScreen(container));
      await widgetTester.pumpAndSettle();

      final addButton = find.byWidgetPredicate(
        (widget) => widget is FloatingActionButton,
      );
      await widgetTester.pump();
      expect(addButton, findsOneWidget);

      await widgetTester.tap(addButton);
      await widgetTester.pumpAndSettle(const Duration(milliseconds: 400));

      final field = find.byType(TextField);
      expect(field, findsOneWidget);

      await widgetTester.enterText(field, 'My first habit');
      await widgetTester.pumpAndSettle();

      final createButton = find.byWidgetPredicate(
        (widget) => widget is ElevatedButton,
      );
      expect(createButton, findsOneWidget);

      await widgetTester.tap(createButton);
      await widgetTester.pumpAndSettle(const Duration(seconds: 1));

      final createdScreen = find.byKey(HomeScreen.createHabitScreenKey);
      expect(createdScreen, findsNothing);

      final habit = container.habitsStateHolder.habits.firstWhere(
        (element) => element.title == 'My first habit',
      );
      final habitTile = find.byKey(ValueKey('HabitTile${habit.id}'));
      expect(habitTile, findsOneWidget);
    },
  );
}
