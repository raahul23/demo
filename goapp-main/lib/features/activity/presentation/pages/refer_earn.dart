import "package:flutter/material.dart";
import "package:goapp/features/activity/presentation/pages/terms_conditions.dart";
import "../../../../core/utils/constants.dart";
import "../../../../core/utils/responsive.dart";
import "../widgets/appbar.dart";
import "../widgets/buttons.dart";
import "coins_center.dart";

class ReferEarnPage extends StatelessWidget {
  const ReferEarnPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.coolwhite,
      appBar: const AppAppBar(
        title: "Refer & Earn",
      ),
      body: SingleChildScrollView(
        padding: Responsive.insetsLTRB(
          context,
          left: 16,
          top: 16,
          right: 16,
          bottom: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Center(
                child: Image.asset(
                  "assets/images/refer&earn.png",
                  fit: BoxFit.fill,
                ),
              ),
            ),

            const Text(
              "Invite Friends, Get 100Coins",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.saira,
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: Responsive.size(context, 10)),
            const Text(
              "Share the love! Get 100 Coin in your Reward when your friend completes their first ride.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.saira,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.charcoal,
              ),
            ),
            SizedBox(height: Responsive.size(context, 20)),
            Container(
              width: double.infinity,
              padding: Responsive.insetsAll(context, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(Responsive.size(context, 16)),
                border: Border.all(color: AppColors.green),
              ),
              child: Column(
                children: [
                  const Text(
                    "Your Referral Code",
                    style: TextStyle(
                      fontFamily: AppFonts.saira,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.green,
                    ),
                  ),
                  SizedBox(height: Responsive.size(context, 6)),
                  const Text(
                    "YOGESH100",
                    style: TextStyle(
                      fontFamily: AppFonts.saira,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: Responsive.size(context, 12)),
                  AppButton(
                    label: "Copy Code",
                    size: AppButtonSize.medium,
                    leading: Icon(
                      Icons.copy,
                      size: Responsive.size(context, 18),
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            SizedBox(height: Responsive.size(context, 20)),
            Align(
              alignment: Alignment.center,
              child: const Text(
                "Quick Share",
                style: TextStyle(
                  fontFamily: AppFonts.saira,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
            ),
            SizedBox(height: Responsive.size(context, 12)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ShareIcon(label: "WhatsApp", icon: Icons.message),
                const _ShareIcon(label: "SMS", icon: Icons.sms_outlined),
                const _ShareIcon(label: "More", icon: Icons.more_horiz),
              ],
            ),
            SizedBox(height: Responsive.size(context, 20)),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const TermsConditionsPage(),
                  ),
                );
              },
              child: const Text(
                "Terms & Conditions",
                style: TextStyle(
                  fontFamily: AppFonts.saira,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            SizedBox(height: Responsive.size(context, 20)),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: "Invite Friends",
                size: AppButtonSize.large,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CoinsCenterPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareIcon extends StatelessWidget {
  const _ShareIcon({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: Responsive.size(context, 22),
          backgroundColor: AppColors.lavender,
          child: Icon(
            icon,
            color: AppColors.violet,
            size: Responsive.size(context, 20),
          ),
        ),
        SizedBox(height: Responsive.size(context, 6)),
        Text(
          label,
          style: const TextStyle(
            fontFamily: AppFonts.saira,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.charcoal,
          ),
        ),
      ],
    );
  }
}

