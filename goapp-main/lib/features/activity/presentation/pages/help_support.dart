import "package:flutter/material.dart";
import "../../../../core/utils/constants.dart";
import "../../../../core/utils/responsive.dart";
import "../widgets/appbar.dart";
import "../widgets/textfield.dart";

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const AppAppBar(
        title: "Helps & Support",
      ),
      body: Padding(
        padding: Responsive.insetsLTRB(
          context,
          left: 16,
          top: 8,
          right: 16,
          bottom: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: Responsive.size(context, 16)),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.coolwhite,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 12,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const AppTextField(
                  borderColor: AppColors.warmGray,
                  label: "Search Here",
                  hint: "Search Here",
                  filled: true,
                  leading: Icon(Icons.search, color: AppColors.gray),
                  trailing: Icon(Icons.mic, color: AppColors.gray),
                ),
              ),
              SizedBox(height: Responsive.size(context, 16)),
              const Text(
                "Ride Issues",
                style: TextStyle(
                  fontFamily: AppFonts.saira,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray,
                ),
              ),
              SizedBox(height: Responsive.size(context, 12)),
              _HelpItem(
                icon: Icons.directions_car,
                title: "Issue with a past ride",
                showDivider: false,
                onTap: () {},
              ),
              _HelpItem(
                icon: Icons.report_problem,
                title: "Lost & found items",
                showDivider: true,
                onTap: () {},
              ),
              SizedBox(height: Responsive.size(context, 20)),
              const Text(
                "Payment & Receipts",
                style: TextStyle(
                  fontFamily: AppFonts.saira,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray,
                ),
              ),
              SizedBox(height: Responsive.size(context, 12)),
              _HelpItem(
                icon: Icons.receipt_long_outlined,
                title: "Payment inquiries",
                showDivider: false,
                onTap: () {},
              ),
              _HelpItem(
                icon: Icons.credit_card,
                title: "Managing payment methods",
                showDivider: true,
                onTap: () {},
              ),
              SizedBox(height: Responsive.size(context, 20)),
              const Text(
                "Account & Safety",
                style: TextStyle(
                  fontFamily: AppFonts.saira,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray,
                ),
              ),
              SizedBox(height: Responsive.size(context, 12)),
              _HelpItem(
                icon: Icons.shield,
                title: "Safety guidelines & reporting",
                showDivider: false,
                onTap: () {},
              ),
              _HelpItem(
                icon: Icons.manage_accounts,
                title: "Account settings & privacy",
                showDivider: false,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HelpItem extends StatelessWidget {
  const _HelpItem({
    required this.icon,
    required this.title,
    required this.showDivider,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final bool showDivider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: Responsive.insetsSymmetric(
              context,
              vertical: 12,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: Responsive.size(context, 18),
                  backgroundColor: AppColors.warmGray,
                  child: Icon(
                    icon,
                    size: Responsive.size(context, 18),
                    color: AppColors.black,
                  ),
                ),
                SizedBox(width: Responsive.size(context, 12)),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontFamily: AppFonts.saira,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.black,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.black,
                  size: Responsive.size(context, 20),
                ),
              ],
            ),
          ),
          if (showDivider)
            const Divider(
              height: 1,
              color: AppColors.silver,
            ),
        ],
      ),
    );
  }
}
