import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";


import "../../../../core/utils/date_time.dart";

enum CoinsHistoryFilter { all, earned, spent }

enum CoinsTransactionType { earned, spent }

class CoinsHistoryItem {
  const CoinsHistoryItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.type,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String amount;
  final CoinsTransactionType type;
}

class CoinsHistorySection {
  const CoinsHistorySection({required this.title, required this.items});

  final String title;
  final List<CoinsHistoryItem> items;
}

class CoinsHistoryState {
  const CoinsHistoryState({required this.filter, required this.sections});

  final CoinsHistoryFilter filter;
  final List<CoinsHistorySection> sections;

  CoinsHistoryState copyWith({
    CoinsHistoryFilter? filter,
    List<CoinsHistorySection>? sections,
  }) {
    return CoinsHistoryState(
      filter: filter ?? this.filter,
      sections: sections ?? this.sections,
    );
  }
}

class CoinsHistoryCubit extends Cubit<CoinsHistoryState> {
  CoinsHistoryCubit({DateTime? now})
      : super(
    CoinsHistoryState(
      filter: CoinsHistoryFilter.all,
      sections: _buildSections(now ?? DateTimeUtils.now()),
    ),
  );

  void selectFilter(CoinsHistoryFilter filter) {
    emit(state.copyWith(filter: filter));
  }

  List<CoinsHistorySection> filteredSections() {
    if (state.filter == CoinsHistoryFilter.all) {
      return state.sections;
    }
    final requiredType = state.filter == CoinsHistoryFilter.earned
        ? CoinsTransactionType.earned
        : CoinsTransactionType.spent;

    return state.sections
        .map(
          (section) => CoinsHistorySection(
        title: section.title,
        items: section.items
            .where((item) => item.type == requiredType)
            .toList(),
      ),
    )
        .where((section) => section.items.isNotEmpty)
        .toList();
  }

  static List<CoinsHistorySection> _buildSections(DateTime now) {
    final timeText = DateTimeUtils.formatTime24(now);
    return [
      CoinsHistorySection(
        title: DateTimeUtils.dayLabel(now),
        items: [
          CoinsHistoryItem(
            icon: Icons.directions_car_filled_outlined,
            title: "Ride Completed",
            subtitle: "XL Toyota - $timeText",
            amount: "+20",
            type: CoinsTransactionType.earned,
          ),
          CoinsHistoryItem(
            icon: Icons.person_outline,
            title: "Referral Bonus",
            subtitle: "Friend: Sam. - $timeText",
            amount: "+40",
            type: CoinsTransactionType.earned,
          ),
          CoinsHistoryItem(
            icon: Icons.local_offer_outlined,
            title: "Discount Applied",
            subtitle: "Cab ride - $timeText",
            amount: "-10",
            type: CoinsTransactionType.spent,
          ),
        ],
      ),
      CoinsHistorySection(
        title: DateTimeUtils.formatDate(now),
        items: [
          CoinsHistoryItem(
            icon: Icons.directions_car_filled_outlined,
            title: "Ride Completed",
            subtitle: "Sedan - $timeText",
            amount: "+15",
            type: CoinsTransactionType.earned,
          ),
        ],
      ),
    ];
  }
}
