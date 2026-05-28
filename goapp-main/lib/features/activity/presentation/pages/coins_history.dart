import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:goapp/features/activity/presentation/pages/rewards.dart";
import "../../../../core/utils/constants.dart";
import "../../../../core/utils/responsive.dart";
import "../cubit/coins_history_cubit.dart";
import "../widgets/appbar.dart";
import "../widgets/buttons.dart";

class CoinsHistoryPage extends StatelessWidget {
  const CoinsHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CoinsHistoryCubit(),
      child: Scaffold(
        backgroundColor: AppColors.coolwhite,
        appBar: const AppAppBar(title: "Coins History"),
        body: Padding(
          padding: Responsive.insetsLTRB(
            context,
            left: 16,
            top: 8,
            right: 16,
            bottom: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Reward Balance",
                style: TextStyle(
                  fontFamily: AppFonts.saira,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoal,
                ),
              ),
              SizedBox(height: Responsive.size(context, 6)),
              const Text(
                "120",
                style: TextStyle(
                  fontFamily: AppFonts.saira,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              SizedBox(height: Responsive.size(context, 4)),
              const Text(
                "+15% this month",
                style: TextStyle(
                  fontFamily: AppFonts.saira,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gold,
                ),
              ),
              SizedBox(height: Responsive.size(context, 16)),
              Container(
                width: double.infinity,
                height: Responsive.size(context, 120),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    Responsive.size(context, 16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: Responsive.size(context, 16),
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    Responsive.size(context, 16),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        "assets/images/coin_bg.png",
                        fit: BoxFit.cover,
                      ),
                      Padding(
                        padding: Responsive.insetsAll(context, 16),
                        child: Row(
                          children: [
                            Image.asset(
                              "assets/images/coins.png",
                              width: Responsive.size(context, 64),
                              height: Responsive.size(context, 64),
                              fit: BoxFit.contain,
                            ),
                            SizedBox(width: Responsive.size(context, 12)),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Use Go Coin to enjoy a discount on your ride!",
                                    style: TextStyle(
                                      fontFamily: AppFonts.saira,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    "10 Go Coins = 1",
                                    style: TextStyle(
                                      fontFamily: AppFonts.saira,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: Responsive.size(context, 16)),
              BlocBuilder<CoinsHistoryCubit, CoinsHistoryState>(
                builder: (context, state) {
                  final cubit = context.read<CoinsHistoryCubit>();
                  return Row(
                    children: [
                      _FilterButton(
                        label: "All",
                        isSelected: state.filter == CoinsHistoryFilter.all,
                        onTap: () => cubit.selectFilter(CoinsHistoryFilter.all),
                      ),
                      SizedBox(width: Responsive.size(context, 8)),
                      _FilterButton(
                        label: "Earned",
                        isSelected: state.filter == CoinsHistoryFilter.earned,
                        onTap: () =>
                            cubit.selectFilter(CoinsHistoryFilter.earned),
                      ),
                      SizedBox(width: Responsive.size(context, 8)),
                      _FilterButton(
                        label: "Spent",
                        isSelected: state.filter == CoinsHistoryFilter.spent,
                        onTap: () =>
                            cubit.selectFilter(CoinsHistoryFilter.spent),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: Responsive.size(context, 12)),
              const Expanded(child: _HistoryList()),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          minimum: Responsive.insetsLTRB(
            context,
            left: 16,
            top: 12,
            right: 16,
            bottom: 16,
          ),
          child: AppButton(
            label: "Reward",
            size: AppButtonSize.large,
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const RewardsPage()));
            },
          ),
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: Responsive.insetsSymmetric(context, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.green : Colors.white,
            borderRadius: BorderRadius.circular(Responsive.size(context, 12)),
            border: Border.all(
              color: isSelected ? AppColors.green : AppColors.silver,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppFonts.saira,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.charcoal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList();

  @override
  Widget build(BuildContext context) {
    final sections = context.watch<CoinsHistoryCubit>().filteredSections();
    return ListView(
      children: sections
          .map(
            (section) =>
            _HistorySection(title: section.title, items: section.items),
      )
          .toList(),
    );
  }
}

class _HistorySection extends StatelessWidget {
  const _HistorySection({required this.title, required this.items});

  final String title;
  final List<CoinsHistoryItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: AppFonts.saira,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        SizedBox(height: Responsive.size(context, 8)),
        ...items.map(
              (item) => Padding(
            padding: EdgeInsets.only(bottom: Responsive.size(context, 10)),
            child: _HistoryRow(item: item),
          ),
        ),
        SizedBox(height: Responsive.size(context, 6)),
      ],
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.item});

  final CoinsHistoryItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: Responsive.size(context, 18),
          backgroundColor: AppColors.lavender,
          child: Icon(
            item.icon,
            color: AppColors.violet,
            size: Responsive.size(context, 18),
          ),
        ),
        SizedBox(width: Responsive.size(context, 12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  fontFamily: AppFonts.saira,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              SizedBox(height: Responsive.size(context, 4)),
              Text(
                item.subtitle,
                style: const TextStyle(
                  fontFamily: AppFonts.saira,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.charcoal,
                ),
              ),
            ],
          ),
        ),
        Text(
          item.amount,
          style: TextStyle(
            fontFamily: AppFonts.saira,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: item.type == CoinsTransactionType.spent
                ? AppColors.red
                : AppColors.green,
          ),
        ),
      ],
    );
  }
}

