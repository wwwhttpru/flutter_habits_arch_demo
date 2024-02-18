import 'package:meta/meta.dart';
import 'package:habits_arch_demo/data/models/habit.dart';

import 'habit_dao.dart';

@immutable
final class HabitRuntimeDao implements HabitDao {
  final List<Habit> _habits = [];

  HabitRuntimeDao();

  @override
  Future<List<Habit>> getAllHabits() => Future<List<Habit>>.delayed(
        const Duration(seconds: 1),
        () => _habits,
      );

  @override
  Future<void> addHabit(Habit habit) async {
    await Future.delayed(const Duration(seconds: 1));
    _habits.add(habit);
  }

  @override
  Future<void> saveHabit(Habit habit) async {
    final indexOfHabit = _habits.indexWhere((item) => item.id == habit.id);
    if (indexOfHabit >= 0) {
      _habits[indexOfHabit] = habit;
    }
  }

  @visibleForTesting
  void setupMockHabits(List<Habit> habits) {
    _habits.clear();
    _habits.addAll(habits);
  }
}
