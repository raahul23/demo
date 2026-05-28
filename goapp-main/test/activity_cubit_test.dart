import "package:flutter_test/flutter_test.dart";
import "package:goapp/features/activity/presentation/cubit/activity_cubit.dart";

void main() {
  group("ActivityCubit", () {
    test("initializes with activity index and seeded items", () {
      final cubit = ActivityCubit(now: DateTime(2026, 2, 12, 10, 0));
      expect(cubit.state.currentIndex, 2);
      expect(cubit.state.items, isNotEmpty);
    });

    test("updates bottom nav index", () {
      final cubit = ActivityCubit();
      cubit.selectBottomNavIndex(1);
      expect(cubit.state.currentIndex, 1);
    });

    test("filters completed and cancelled items", () {
      final cubit = ActivityCubit(now: DateTime(2026, 2, 12, 10, 0));
      final completed = cubit.filteredItems(ActivityFilter.completed);
      final cancelled = cubit.filteredItems(ActivityFilter.cancelled);

      expect(completed.every((item) => item.isCompleted), isTrue);
      expect(cancelled.every((item) => item.isCancelled), isTrue);
      expect(cancelled.length, 1);
    });
  });
}
