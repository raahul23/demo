import "package:flutter/material.dart";
import "package:goapp/features/activity/presentation/pages/reward_details.dart";

import "../../../../core/utils/constants.dart";
import "../../../../core/utils/responsive.dart";
import "../widgets/appbar.dart";

class RewardsPage extends StatelessWidget {
  const RewardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.coolwhite,
      appBar: const AppAppBar(
        title: "Rewards",
      ),
      body: Padding(
        padding: Responsive.insetsLTRB(
          context,
          left: 16,
          top: 8,
          right: 16,
          bottom: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Available Vouchers",
              style: TextStyle(
                fontFamily: AppFonts.saira,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: Responsive.size(context, 12)),
            Expanded(
              child: ListView(
                children: [
                  const _VoucherCard(isExpired: false),
                  SizedBox(height: Responsive.size(context, 12)),
                  const _VoucherCard(isExpired: false),
                  SizedBox(height: Responsive.size(context, 20)),
                  const Text(
                    "Expired Vouchers",
                    style: TextStyle(
                      fontFamily: AppFonts.saira,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: Responsive.size(context, 12)),
                  const _VoucherCard(isExpired: true),
                  SizedBox(height: Responsive.size(context, 12)),
                  const _VoucherCard(isExpired: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoucherCard extends StatelessWidget {
  const _VoucherCard({this.isExpired = false});

  final bool isExpired;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: Responsive.insetsAll(context, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(Responsive.size(context, 14)),
        border: Border.all(color: AppColors.silver),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: Responsive.size(context, 70),
            padding:
            Responsive.insetsSymmetric(context, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.warmGray,
              borderRadius:
              BorderRadius.circular(Responsive.size(context, 12)),
            ),
            child: Column(
              children: [
                const Text(
                  "10%",
                  style: TextStyle(
                    fontFamily: AppFonts.saira,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xC5A36A0D),
                  ),
                ),
                SizedBox(height: Responsive.size(context, 4)),
                const Text(
                  "Discount",
                  style: TextStyle(
                    fontFamily: AppFonts.saira,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.violet,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: Responsive.size(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Weekend Escape",
                  style: TextStyle(
                    fontFamily: AppFonts.saira,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: Responsive.size(context, 6)),
                const Text(
                  "Valid for rides over 10rs",
                  style: TextStyle(
                    fontFamily: AppFonts.saira,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.charcoal,
                  ),
                ),
                SizedBox(height: Responsive.size(context, 4)),
                const Text(
                  "Expires in 3 days",
                  style: TextStyle(
                    fontFamily: AppFonts.saira,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray,
                  ),
                ),
              ],
            ),
          ),
          isExpired
              ? const Text(
            "Expired",
            style: TextStyle(
              fontFamily: AppFonts.saira,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.gray,
            ),
          )
              : GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const RewardDetailsPage(),
                ),
              );
            },
            child: const Text(
              "Redeem",
              style: TextStyle(
                fontFamily: AppFonts.saira,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

