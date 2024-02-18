import 'package:flutter_test/flutter_test.dart';
import 'package:habits_arch_demo/data/models/habit.dart';
import 'package:habits_arch_demo/domain/habits_state/habits_state_holder.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';

import '../../data/dao/habit_dao.dart';

class MockUuid extends Mock implements Uuid {}

void main() {
  late final MockUuid uuid;
  late final MockHabitDao dao;
  const firstHabit = Habit(id: '1', title: 'First');
  const secondHabit = Habit(id: '2', title: 'Second');
  const mockHabits = <Habit>[firstHabit, secondHabit];

  HabitsStateHolder createHolder() {
    return HabitsStateHolder(dao, uuid);
  }

  HabitsStateHolder createDataHolder() {
    return HabitsStateHolder.data(
      dao,
      uuid,
      habits: {for (final habit in mockHabits) habit.id: habit},
    );
  }

  setUpAll(() {
    uuid = MockUuid();
    dao = MockHabitDao();
  });

  tearDownAll(() {
    reset(dao);
    reset(uuid);
  });

  group(
    'Проверка начальных значений',
    () {
      test(
        'обычный конструктор имеет пустой список, и состояния загрузки',
        () {
          // arrange
          final holder = createHolder();

          // act

          // aspect
          expect(holder.habits, isEmpty);
          expect(
              holder.habitsLoadingStatus, equals(HabitsLoadingStatus.loading));
        },
      );

      test(
        'data конструктор имеет начальный список, и состояния data',
        () {
          // arrange
          final holder = createDataHolder();

          // act

          // aspect
          expect(holder.habits, mockHabits);
          expect(holder.habitsLoadingStatus, equals(HabitsLoadingStatus.data));
        },
      );
    },
  );

  group(
    'Проверка ф-ии <fetchHabits>',
    () {
      late final HabitsStateHolder stateHolder;

      setUpAll(() {
        stateHolder = createHolder();
      });

      tearDownAll(() {
        stateHolder.dispose();
        reset(dao);
      });

      test(
        'после вызова ф-ии ожидаем успешное '
        'состояние со списком привычек',
        () async {
          // arrange
          when(() => dao.getAllHabits()).thenAnswer(
            (_) async => mockHabits,
          );

          // act
          await stateHolder.fetchHabits();

          // aspect
          expect(stateHolder.habits, equals(mockHabits));
          expect(
            stateHolder.habitsLoadingStatus,
            equals(HabitsLoadingStatus.data),
          );

          verify(() => dao.getAllHabits()).called(1);
        },
      );

      test(
        'после вызова ф-ии ожидаем состояние ошибки и '
        'список привычек пустой',
        () async {
          // arrange
          when(() => dao.getAllHabits()).thenAnswer(
            (_) async => throw Exception(),
          );

          // act
          await stateHolder.fetchHabits();

          // aspect
          expect(stateHolder.habits, equals(const []));
          expect(
            stateHolder.habitsLoadingStatus,
            equals(HabitsLoadingStatus.error),
          );

          verify(() => dao.getAllHabits()).called(1);
        },
      );
    },
  );

  group(
    'Проверка ф-ии <addHabit>',
    () {
      late final HabitsStateHolder stateHolder;
      const habit = Habit(id: '1', title: 'Coding');

      setUpAll(() {
        when(() => uuid.v1()).thenReturn(habit.id);
        stateHolder = createHolder();
      });

      tearDownAll(() {
        stateHolder.dispose();
        reset(uuid);
        reset(dao);
      });

      test(
        'в список привычек добавиться новая привычка',
        () async {
          // arrange
          final status = stateHolder.habitsLoadingStatus;
          when(() => dao.addHabit(habit)).thenAnswer(
            (invocation) async {},
          );

          // act
          await stateHolder.addHabit(title: habit.title);

          // aspect
          expect(stateHolder.habits, contains(habit));
          expect(stateHolder.habitsLoadingStatus, equals(status));

          verify(() => uuid.v1()).called(1);
          verify(() => dao.addHabit(habit)).called(1);
        },
      );

      test(
        'выбросит ошибку, в случае ошибки БД',
        () {
          // arrange
          final status = stateHolder.habitsLoadingStatus;
          when(() => dao.addHabit(habit)).thenAnswer(
            (invocation) async => throw Exception(),
          );

          // act
          final future = stateHolder.addHabit(title: habit.title);

          // aspect
          expectLater(future, throwsException);
          expect(stateHolder.habitsLoadingStatus, equals(status));

          verify(() => uuid.v1()).called(1);
          verify(() => dao.addHabit(habit)).called(1);
        },
      );
    },
  );

  group(
    'Вызов ф-ии <toggleDateForHabit>',
    () {
      late HabitsStateHolder stateHolder;
      final date = DateTime(2024, 01, 01);

      setUp(() {
        stateHolder = createDataHolder();
      });

      tearDown(() {
        stateHolder.dispose();
      });

      test(
        'выбросит ошибку, если в списке нету нужной привычки',
        () {
          // arrange
          final holder = createHolder();

          // act
          final result = holder.toggleDateForHabit(
            habitId: '-1',
            date: date,
          );

          // aspect
          expect(result, throwsException);
        },
      );

      test(
        'добавит новую дату в выбранный день',
        () async {
          // arrange
          const habit = firstHabit;
          final habitId = habit.id;
          final updatedHabit = habit.copyWith(
            completedDates: {...habit.completedDates, date},
          );

          when(() => dao.saveHabit(updatedHabit)).thenAnswer((_) async {});

          // act
          await stateHolder.toggleDateForHabit(
            habitId: habitId,
            date: date,
          );

          // aspect
          final newHabit = stateHolder.habits.firstWhere(
            (habit) => habit.id == habitId,
          );

          expect(newHabit.completedDates, contains(date));
          expect(newHabit, equals(updatedHabit));
        },
      );
    },
  );
}
