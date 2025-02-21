import 'package:habits_arch_demo/domain/entities/habit_entity.dart';
import 'package:habits_arch_demo/domain/repositories/habits_repository.dart';
import 'package:rxdart/rxdart.dart';

class HabitsRepositoryImpl implements HabitsRepository {
  final HabitDao _dao;
  final Uuid _uuid;

  Map<String, HabitDto> _habits = {};
  HabitsLoadingStatus _habitsLoadingStatus = HabitsLoadingStatus.loading;

  HabitsStateHolder(this._dao, this._uuid);

  List<HabitDto> get habits => _habits.values.toList();
  HabitsLoadingStatus get habitsLoadingStatus => _habitsLoadingStatus;

  Future<void> fetchHabits() async {
    try {
      _habitsLoadingStatus = HabitsLoadingStatus.loading;
      notifyListeners();

      final habitList = await _dao.getAllHabits();

      _habits = Map.fromEntries(
        habitList.map((habit) => MapEntry(habit.id, habit)),
      );
      _habitsLoadingStatus = HabitsLoadingStatus.data;
    } catch (_) {
      _habits = {};
      _habitsLoadingStatus = HabitsLoadingStatus.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> addHabit({
    required String title,
  }) async {
    final habit = HabitDto(
      id: _uuid.v1(),
      title: title,
    );
    try {
      await _dao.addHabit(habit);
      _habits[habit.id] = habit;
      notifyListeners();
    } catch (_) {
      rethrow;
    }
  }

  Future<void> toggleDateForHabit({
    required String habitId,
    required DateTime date,
  }) async {
    final dateOnly = DateUtils.dateOnly(date);
    final habit = _habits[habitId];
    if (habit == null) {
      throw Exception('No habit with id: $habitId');
    }

    final updatedDates = Set.of(habit.completedDates);
    if (habit.completedDates.contains(dateOnly)) {
      updatedDates.remove(dateOnly);
    } else {
      updatedDates.add(dateOnly);
    }
    final updatedHabit = habit.copyWith(
      completedDates: updatedDates,
    );

    await _dao.saveHabit(updatedHabit);

    _habits = Map.of(_habits)..[habitId] = updatedHabit;
    notifyListeners();
  }
}