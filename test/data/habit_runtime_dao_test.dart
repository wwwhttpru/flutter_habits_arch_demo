import 'package:flutter_test/flutter_test.dart';
import 'package:habits_arch_demo/data/dao/habit_runtime_dao.dart';
import 'package:habits_arch_demo/data/models/habit.dart';

void main() {
  late final HabitRuntimeDao habitDao;

  setUpAll(() {
    habitDao = HabitRuntimeDao();
  });

  test(
    'Проверка функции <getAllHabits>, должна возвращать весь список привычек',
    () async {
      // arrange
      const mockHabits = <Habit>[
        Habit(id: '1', title: 'First'),
        Habit(id: '2', title: 'Second'),
      ];
      habitDao.setupMockHabits(mockHabits);

      // act
      final habits = await habitDao.getAllHabits();

      // aspect
      expect(habits, equals(mockHabits));
    },
  );

  test(
    'Проверка ф-ии <addHabit>, должна добавить новую привычку '
    'в список всех привычек',
    () async {
      // arrange
      const habit = Habit(id: '1', title: 'Second');
      habitDao.setupMockHabits(const []);

      // act
      await habitDao.addHabit(habit);
      final habits = await habitDao.getAllHabits();

      // aspect
      expect(habits, contains(habit));
      expect(habits, hasLength(1));
    },
  );

  test(
    'Проверка ф-ии <addHabit>, при добавлении существующей привычке '
    'должна обновить ее в текущем списке',
    () async {
      // arrange
      const habit = Habit(id: '1', title: 'First');
      habitDao.setupMockHabits(const [habit]);

      final updatedHabit = habit.copyWith(title: 'Sleep');

      // act
      await habitDao.addHabit(updatedHabit);
      final habits = await habitDao.getAllHabits();

      // aspect
      expect(habits, contains(updatedHabit));
      expect(habits, hasLength(1));
    },
  );

  test(
    'Проверка ф-ии <saveHabit>, сохраняя привычку должна обновить '
    'имеющиеся по идентификатору',
    () async {
      // arrange
      const habit = Habit(id: '1', title: 'First');
      habitDao.setupMockHabits(const [habit]);

      final updatedHabit = habit.copyWith(title: 'Sleep');

      // act
      await habitDao.saveHabit(updatedHabit);
      final habits = await habitDao.getAllHabits();

      // aspect
      expect(habits, contains(updatedHabit));
      expect(habits, hasLength(1));
    },
  );

  test(
    'Проверка ф-ии <saveHabit>, сохраняя новую привычку, '
    'должно появиться в списке всех привычек',
    () async {
      // arrange
      const habit = Habit(id: '1', title: 'First');
      habitDao.setupMockHabits(const []);

      // act
      await habitDao.saveHabit(habit);
      final habits = await habitDao.getAllHabits();

      // aspect
      expect(habits, contains(habit));
      expect(habits, hasLength(1));
    },
  );
}
