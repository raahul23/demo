import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "../../../../core/utils/app_assets.dart";
import "../../../../core/utils/constants.dart";
import "../../../../core/utils/date_time.dart";

enum ActivityFilter { all, completed, cancelled }

class ActivityItem {
  const ActivityItem({
    required this.section,
    required this.price,
    required this.status,
    required this.location,
    required this.dateTimeText,
    required this.rideType,
    required this.isCompleted,
    required this.isCancelled,
    required this.badgeColor,
    required this.assetPath,
  });

  final String section;
  final String price;
  final String status;
  final String location;
  final String dateTimeText;
  final String rideType;
  final bool isCompleted;
  final bool isCancelled;
  final Color badgeColor;
  final String assetPath;
}

class ActivityState {
  const ActivityState({required this.currentIndex, required this.items});

  final int currentIndex;
  final List<ActivityItem> items;

  ActivityState copyWith({int? currentIndex, List<ActivityItem>? items}) {
    return ActivityState(
      currentIndex: currentIndex ?? this.currentIndex,
      items: items ?? this.items,
    );
  }
}

class ActivityCubit extends Cubit<ActivityState> {
  ActivityCubit({DateTime? now})
      : super(
    ActivityState(
      currentIndex: 2,
      items: _buildItems(now ?? DateTimeUtils.now()),
    ),
  );

  void selectBottomNavIndex(int index) {
    emit(state.copyWith(currentIndex: index));
  }

  List<ActivityItem> filteredItems(ActivityFilter filter) {
    switch (filter) {
      case ActivityFilter.completed:
        return state.items.where((item) => item.isCompleted).toList();
      case ActivityFilter.cancelled:
        return state.items.where((item) => item.isCancelled).toList();
      case ActivityFilter.all:
        return state.items;
    }
  }

  static List<ActivityItem> _buildItems(DateTime now) {
    final section = DateTimeUtils.dayLabel(now);
    final dateTimeText = DateTimeUtils.formatDateTime(now);
    return [
      ActivityItem(
        section: section,
        price: "₹12.50",
        status: "Completed",
        location: "Airport Terminal 2",
        dateTimeText: dateTimeText,
        rideType: "Cab",
        isCompleted: true,
        isCancelled: false,
        badgeColor: AppColors.badge,
        assetPath: AppAssets.activityCar,
      ),
      ActivityItem(
        section: section,
        price: "₹6.80",
        status: "Cancelled",
        location: "Central Park West",
        dateTimeText: dateTimeText,
        rideType: "Bike",
        isCompleted: false,
        isCancelled: true,
        badgeColor: AppColors.badge,
        assetPath: AppAssets.activityBike,
      ),
      ActivityItem(
        section: section,
        price: "₹18.20",
        status: "Completed",
        location: "Union Square",
        dateTimeText: dateTimeText,
        rideType: "Cab",
        isCompleted: true,
        isCancelled: false,
        badgeColor: AppColors.badge,
        assetPath: AppAssets.activityCar,
      ),
      ActivityItem(
        section: section,
        price: "₹4.40",
        status: "Completed",
        location: "Riverside Mall",
        dateTimeText: dateTimeText,
        rideType: "Bike",
        isCompleted: true,
        isCancelled: false,
        badgeColor: AppColors.badge,
        assetPath: AppAssets.activityBike,
      ),
    ];
  }
}
