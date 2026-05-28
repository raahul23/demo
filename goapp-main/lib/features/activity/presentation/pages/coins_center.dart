import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "../../../../core/utils/constants.dart";
import "../../../../core/utils/responsive.dart";
import "../cubit/autouse_coin_cubit.dart";
import "../widgets/appbar.dart";
import "../widgets/buttons.dart";
import "coins_history.dart";

class CoinsCenterPage extends StatelessWidget {
  const CoinsCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AutoUseCoinCubit(),
      child: Scaffold(
        appBar: const AppAppBar(title: "Coins Center"),
        body: SingleChildScrollView(
          child: Padding(
            padding: Responsive.insetsLTRB(
              context,
              left: 16,
              top: 16,
              right: 16,
              bottom: 0,
            ),
            child: Column(
              children: [
                SizedBox(height: Responsive.size(context, 8)),
                Container(
                  padding: Responsive.insetsAll(context, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      Responsive.size(context, 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: Responsive.size(context, 10),
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        "assets/images/rupee.png",
                        width: Responsive.size(context, 80),
                        height: Responsive.size(context, 80),
                      ),
                      SizedBox(width: Responsive.size(context, 20)),
                      const Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Reward Balance",
                              style: TextStyle(
                                fontFamily: AppFonts.saira,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.charcoal,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "120",
                              style: TextStyle(
                                fontFamily: AppFonts.saira,
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: AppColors.black,
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.arrow_upward,
                                  size: 12,
                                  color: AppColors.gold,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "+15% this month",
                                  style: TextStyle(
                                    fontFamily: AppFonts.saira,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.charcoal,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: Responsive.size(context, 16)),
                Container(
                  width: double.infinity,
                  padding: Responsive.insetsAll(context, 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      Responsive.size(context, 16),
                    ),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3D2415), Color(0xFF5C3A24)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: Responsive.size(context, 16),
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        "assets/images/coins.png",
                        width: Responsive.size(context, 180),
                        height: Responsive.size(context, 180),
                        fit: BoxFit.contain,
                      ),
                      SizedBox(width: Responsive.size(context, 16)),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Use Go Coin to enjoy a",
                              style: TextStyle(
                                fontFamily: AppFonts.saira,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "discount on your ride!",
                              style: TextStyle(
                                fontFamily: AppFonts.saira,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "10 Go Coins = Rs1",
                              style: TextStyle(
                                fontFamily: AppFonts.saira,
                                fontSize: 16,
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
                SizedBox(height: Responsive.size(context, 16)),
                const _AutoUseCoinCard(),
                SizedBox(height: Responsive.size(context, 24)),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "How to Earn",
                    style: TextStyle(
                      fontFamily: AppFonts.saira,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.charcoal,
                    ),
                  ),
                ),
                SizedBox(height: Responsive.size(context, 12)),
                Container(
                  width: double.infinity,
                  padding: Responsive.insetsAll(context, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      Responsive.size(context, 12),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: Responsive.size(context, 10),
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: Responsive.size(context, 48),
                        height: Responsive.size(context, 48),
                        decoration: BoxDecoration(
                          color: AppColors.lavender,
                          borderRadius: BorderRadius.circular(
                            Responsive.size(context, 12),
                          ),
                        ),
                        child: Icon(
                          Icons.person_add_outlined,
                          color: AppColors.violet,
                          size: Responsive.size(context, 24),
                        ),
                      ),
                      SizedBox(width: Responsive.size(context, 16)),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Invite Friends",
                              style: TextStyle(
                                fontFamily: AppFonts.saira,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.black,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "For every friend who joins",
                              style: TextStyle(
                                fontFamily: AppFonts.saira,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppColors.charcoal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        "+100",
                        style: TextStyle(
                          fontFamily: AppFonts.saira,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: Responsive.size(context, 80)),
              ],
            ),
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
            label: "Coin History",
            size: AppButtonSize.large,
            trailing: Icon(
              Icons.arrow_forward,
              size: Responsive.size(context, 20),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CoinsHistoryPage()),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AutoUseCoinCard extends StatelessWidget {
  const _AutoUseCoinCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AutoUseCoinCubit, bool>(
      builder: (context, enabled) {
        return Container(
          width: double.infinity,
          padding: Responsive.insetsSymmetric(
            context,
            horizontal: 20,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Responsive.size(context, 12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: Responsive.size(context, 10),
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Always use Go coin",
                    style: TextStyle(
                      fontFamily: AppFonts.saira,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black,
                    ),
                  ),
                  Switch(
                    value: enabled,
                    onChanged: context.read<AutoUseCoinCubit>().setEnabled,
                    activeThumbColor: Colors.white,
                    activeTrackColor: AppColors.green,
                  ),
                ],
              ),
              const Text(
                "Use Go Coin to enjoy a discount on your ride!",
                style: TextStyle(
                  fontFamily: AppFonts.saira,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.charcoal,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
