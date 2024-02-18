import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits_arch_demo/core/app.dart';
import 'package:habits_arch_demo/core/di/di.dart';
import 'package:habits_arch_demo/ui/screens/home/home_screen.dart';

void main() {
  late final DependencyContainer container;

  setUpAll(() {
    configureDependencies();
    container = diContainer;
  });

  testWidgets(
    'Есть кнопка "Добавить" и она всего одна',
    (widgetTester) async {
      final app = TestHomeScreen(container);
      await widgetTester.pumpWidget(app);

      final button = find.byKey(HomeScreen.addHabitButtonKey);
      await widgetTester.pumpAndSettle();

      expect(button, findsOneWidget);
    },
  );

  testWidgets(
    'При нажатии на кнопку "Добавить" откроется экран создания привычки',
    (widgetTester) async {
      final app = TestHomeScreen(container);
      await widgetTester.pumpWidget(app);

      final button = find.byKey(HomeScreen.addHabitButtonKey);
      await widgetTester.tap(button);
      await widgetTester.pumpAndSettle();

      final createScreen = find.byKey(HomeScreen.createHabitScreenKey);
      await widgetTester.pumpAndSettle(const Duration(milliseconds: 400));

      expect(createScreen, findsOneWidget);
    },
  );
}

class TestHomeScreen extends StatelessWidget {
  final DependencyContainer container;

  const TestHomeScreen(this.container, {super.key});

  @override
  Widget build(BuildContext context) => HabitsApp(
        container: container,
      );
}
