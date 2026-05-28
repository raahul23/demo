import "package:flutter/material.dart";
import "../../../../core/utils/constants.dart";
import "../../../../core/utils/responsive.dart";
import "../widgets/appbar.dart";
import "../widgets/buttons.dart";

class RewardDetailsPage extends StatelessWidget {
  const RewardDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.coolwhite,
      appBar: const AppAppBar(
        title: "Reward Details",
      ),
      body: Padding(
        padding: Responsive.insetsLTRB(
          context,
          left: 16,
          top: 8,
          right: 16,
          bottom: 0,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/car_big.png",
                width: double.infinity,
                fit: BoxFit.contain,
              ),
              SizedBox(height: Responsive.size(context, 12)),
              const Text(
                "XL Cab",
                style: TextStyle(
                  fontFamily: AppFonts.saira,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              SizedBox(height: Responsive.size(context, 6)),
              const Text(
                "Premium Privilege",
                style: TextStyle(
                  fontFamily: AppFonts.saira,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gold,
                ),
              ),
              SizedBox(height: Responsive.size(context, 10)),
              const Text(
                "10% Off Weekend Escape",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppFonts.saira,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              SizedBox(height: Responsive.size(context, 6)),
              const Text(
                "8 Seater XL Cab",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppFonts.saira,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              SizedBox(height: Responsive.size(context, 12)),
              const Text(
                "Worem ipsum dolor sit amet, consectetur adipiscing elit. Nunc vulputate libero et velit interdum, ac aliquet odio mattis. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Curabitur tempus dio mattis........",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppFonts.saira,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.charcoal,
                ),
              ),
              SizedBox(height: Responsive.size(context, 16)),
              const _InfoRow(
                icon: Icons.access_time,
                title: "Valid for 30 days",
                subtitle: "Must be used within one month of redemption",
              ),
              SizedBox(height: Responsive.size(context, 12)),
              const _InfoRow(
                icon: Icons.redeem,
                title: "One-time use",
                subtitle: "Applicable on any single Black Lux booking",
              ),
              SizedBox(height: Responsive.size(context, 16)),
              const Text(
                "Terms & Conditions apply",
                style: TextStyle(
                  fontFamily: AppFonts.saira,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray,
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
          label: "Redeem & Get Code",
          size: AppButtonSize.large,
          onPressed: () {},
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: Responsive.size(context, 18),
          backgroundColor: AppColors.lavender,
          child: Icon(
            icon,
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
    );
  }
}

