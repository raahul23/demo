import "package:flutter_test/flutter_test.dart";
import "package:goapp/features/activity/presentation/cubit/coins_history_cubit.dart";

void main() {
  group("CoinsHistoryCubit", () {
    test("initializes with all filter and sections", () {
      final cubit = CoinsHistoryCubit(now: DateTime(2026, 2, 12, 10, 0));
      expect(cubit.state.filter, CoinsHistoryFilter.all);
      expect(cubit.state.sections, isNotEmpty);
    });

    test("filters earned transactions", () {
      final cubit = CoinsHistoryCubit(now: DateTime(2026, 2, 12, 10, 0));
      cubit.selectFilter(CoinsHistoryFilter.earned);
      final sections = cubit.filteredSections();
      final allItems = sections.expand((section) => section.items);
      expect(
        allItems.every((item) => item.type == CoinsTransactionType.earned),
        isTrue,
      );
    });

    test("filters spent transactions", () {
      final cubit = CoinsHistoryCubit(now: DateTime(2026, 2, 12, 10, 0));
      cubit.selectFilter(CoinsHistoryFilter.spent);
      final sections = cubit.filteredSections();
      final allItems = sections.expand((section) => section.items).toList();
      expect(allItems, isNotEmpty);
      expect(
        allItems.every((item) => item.type == CoinsTransactionType.spent),
        isTrue,
      );
    });
  });
}
