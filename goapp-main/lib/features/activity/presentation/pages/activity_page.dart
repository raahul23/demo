import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:goapp/features/activity/presentation/pages/rebook.dart";
import "../../../../core/utils/constants.dart";
import "../../../../core/utils/responsive.dart";
import "../cubit/activity_cubit.dart";
import "../widgets/appbar.dart";
import "../widgets/buttons.dart";
import "../widgets/custom_tabbar.dart";

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  static const _tabs = [
    Tab(text: "All"),
    Tab(text: "Completed"),
    Tab(text: "Cancel"),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ActivityCubit(),
      child: DefaultTabController(
        length: _tabs.length,
        child: BlocBuilder<ActivityCubit, ActivityState>(
          builder: (context, state) {
            return Scaffold(
              backgroundColor: AppColors.coolwhite,
              appBar: const AppAppBar(
                title: "Activity",
                showBack: true,
              ),
              body: Padding(
                padding: Responsive.insetsSymmetric(context, vertical: 8),
                child: Column(
                  children: const [
                    _ActivityTabs(),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _ActivityListView(filter: ActivityFilter.all),
                          _ActivityListView(filter: ActivityFilter.completed),
                          _ActivityListView(filter: ActivityFilter.cancelled),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ActivityTabs extends StatelessWidget {
  const _ActivityTabs();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: const CustomTabBar(
        tabs: ActivityPage._tabs,
        selectedColor: AppColors.black,
        unselectedColor: AppColors.gray,
        indicatorColor: Color(0xFF00A86B),
        fontFamily: AppFonts.saira,
        labelFontSize: 20,
        labelFontWeight: FontWeight.w700,
        unselectedFontWeight: FontWeight.w600,
        showBottomDivider: false,
      ),
    );
  }
}

class _ActivityListView extends StatelessWidget {
  const _ActivityListView({required this.filter});

  final ActivityFilter filter;

  @override
  Widget build(BuildContext context) {
    final items = context.read<ActivityCubit>().filteredItems(filter);
    return ListView.builder(
      padding: Responsive.insetsLTRB(
        context,
        left: 16,
        top: 8,
        right: 16,
        bottom: 24,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final showHeader =
            index == 0 || items[index - 1].section != item.section;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader)
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: Text(
                  item.section,
                  style: const TextStyle(
                    fontFamily: AppFonts.saira,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.sectionLabel,
                  ),
                ),
              ),
            _ActivityCard(item: item),
          ],
        );
      },
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.item});

  final ActivityItem item;

  @override
  Widget build(BuildContext context) {
    final statusColor = item.isCancelled ? AppColors.red : AppColors.green;

    return Container(
      margin: EdgeInsets.only(bottom: Responsive.size(context, 12)),
      padding: Responsive.insetsAll(context, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.size(context, 16)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.isCancelled ? "₹0" : item.price,
                          style: TextStyle(
                            fontFamily: AppFonts.saira,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: item.isCancelled
                                ? AppColors.muted
                                : AppColors.success,
                          ),
                        ),
                        SizedBox(width: Responsive.size(context, 8)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item.status,
                            style: TextStyle(
                              fontFamily: AppFonts.saira,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.size(context, 8)),
                    Text(
                      item.location,
                      style: const TextStyle(
                        fontFamily: AppFonts.saira,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: Responsive.size(context, 6)),
                    Text(
                      "${item.dateTimeText} - ${item.rideType}",
                      style: const TextStyle(
                        fontFamily: AppFonts.saira,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.charcoal,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: Responsive.size(context, 12)),
              Container(
                width: Responsive.size(context, 52),
                height: Responsive.size(context, 52),
                decoration: BoxDecoration(
                  color: item.badgeColor,
                  borderRadius: BorderRadius.circular(
                    Responsive.size(context, 14),
                  ),
                ),
                child: Center(
                  child: _RideTypeIcon(item: item),
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.size(context, 12)),
          const Divider(height: 1, color: AppColors.silver),
          SizedBox(height: Responsive.size(context, 10)),
          Row(
            children: [
              const Spacer(),
              AppButton(
                label: "Rebook",
                size: AppButtonSize.small,
                leading: const Icon(Icons.history),
                backgroundColor: const Color(0xFFF9FAFB),
                foregroundColor: AppColors.charcoal,
                borderColor: const Color(0xFFF3F4F6),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => RebookPage(status: item.status),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RideTypeIcon extends StatelessWidget {
  const _RideTypeIcon({required this.item});

  final ActivityItem item;

  @override
  Widget build(BuildContext context) {
    final lower = item.assetPath.toLowerCase();
    if (lower.endsWith(".svg")) {
      IconData icon = Icons.local_taxi;
      if (lower.contains("bike") || lower.contains("scooty")) {
        icon = Icons.two_wheeler;
      } else if (lower.contains("parcel")) {
        icon = Icons.local_shipping;
      } else if (lower.contains("auto")) {
        icon = Icons.electric_rickshaw;
      }
      return Icon(
        icon,
        size: Responsive.size(context, 28),
        color: AppColors.charcoal,
      );
    }
    return Image.asset(
      item.assetPath,
      width: Responsive.size(context, 28),
      height: Responsive.size(context, 28),
      fit: BoxFit.contain,
    );
  }
}
