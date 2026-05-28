import "package:flutter/material.dart";
import "package:goapp/features/activity/presentation/pages/wallet.dart";
import "../../../../core/utils/constants.dart";
import "../../../../core/utils/responsive.dart";
import "../widgets/appbar.dart";
import "../widgets/buttons.dart";

class ClaimsPage extends StatelessWidget {
  const ClaimsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.coolwhite,
      appBar: const AppAppBar(
        title: "Claims",
      ),
      body: Padding(
        padding: Responsive.insetsLTRB(
          context,
          left: 16,
          top: 8,
          right: 16,
          bottom: 0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Policy Coverage",
              style: TextStyle(
                fontFamily: AppFonts.saira,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: Responsive.size(context, 24)),
            _CoverageCard(
              icon: Icons.person_rounded,
              title: "Personal Accident / Accidental Death",
              subtitle: "Up to ₹5,00,000",
            ),
            SizedBox(height: Responsive.size(context, 12)),
            _CoverageCard(
              icon: Icons.medical_services_rounded,
              title: "Medical Expense for Hospitalization",
              subtitle: "Up to ₹1,00,000",
            ),
            SizedBox(height: Responsive.size(context, 24)),
            const Text(
              "Legal",
              style: TextStyle(
                fontFamily: AppFonts.saira,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: Responsive.size(context, 24)),
            _LegalRow(
              title: "Claim Procedure",
              onTap: () {},
            ),
            SizedBox(height: Responsive.size(context, 24)),
            _LegalRow(
              title: "Terms and Conditions",
              onTap: () {},
            ),
            SizedBox(height: Responsive.size(context, 46)),
            const Text(
              "Please ensure your contact details and date of birth are accurate to prevent any interruptions in the verification of your luxury insurance claim.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.saira,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.charcoal,
              ),
            ),
            SizedBox(height: Responsive.size(context, 36)),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: Responsive.size(context, 6),
                    height: Responsive.size(context, 6),
                    decoration: const BoxDecoration(
                      color: AppColors.gray,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: Responsive.size(context, 6)),
                  const Text(
                    "Powered by Elite Protect",
                    style: TextStyle(
                      fontFamily: AppFonts.saira,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray,
                    ),
                  ),
                ],
              ),
            ),
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
          label: "Wallet",
          size: AppButtonSize.large,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const WalletPage(),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CoverageCard extends StatelessWidget {
  const _CoverageCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: Responsive.insetsAll(context, 14),
      decoration: BoxDecoration(
        color: Colors.white,

      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: Responsive.size(context, 18),
            backgroundColor: AppColors.warmGray,
            child: Icon(
              icon,
              size: Responsive.size(context, 18),
              color: AppColors.gray,
            ),
          ),
          SizedBox(width: Responsive.size(context, 12)),
          Expanded(
            child: Column(
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
                SizedBox(height: Responsive.size(context, 4)),
                Text(
                  subtitle,
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
        ],
      ),
    );
  }
}

class _LegalRow extends StatelessWidget {
  const _LegalRow({
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: AppFonts.saira,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
          ),
          const Text(
            "View",
            style: TextStyle(
              fontFamily: AppFonts.saira,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.emerald,
            ),
          ),
          SizedBox(width: Responsive.size(context, 4)),
          Icon(
            Icons.chevron_right,
            color: AppColors.emerald,
            size: Responsive.size(context, 20),
          ),
        ],
      ),
    );
  }
}

