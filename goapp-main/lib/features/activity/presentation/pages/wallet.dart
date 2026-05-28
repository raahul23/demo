import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:goapp/features/activity/presentation/pages/transaction_successful.dart";
import "../../../../core/utils/constants.dart";
import "../../../../core/utils/responsive.dart";
import "../cubit/wallet_cubit.dart";
import "../widgets/appbar.dart";
import "../widgets/buttons.dart";
import "../widgets/custom_topup_grid.dart";
import "enter_custom_amount.dart";

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WalletCubit(),
      child: BlocBuilder<WalletCubit, WalletState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.coolwhite,
            appBar: const AppAppBar(title: "Wallet"),
            body: Padding(
              padding: Responsive.insetsLTRB(
                context,
                left: 16,
                top: 16,
                right: 16,
                bottom: 16,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Current Balance",
                    style: TextStyle(
                      fontFamily: AppFonts.saira,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoal,
                    ),
                  ),
                  SizedBox(height: Responsive.size(context, 6)),
                  const Text(
                    "Rs500.00",
                    style: TextStyle(
                      fontFamily: AppFonts.saira,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: Responsive.size(context, 16)),
                  Center(
                    child: SizedBox(
                      width: Responsive.size(context, 140),
                      child: AppButton(
                        label: "Top Up",
                        size: AppButtonSize.small,
                        onPressed: () {
                          showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(
                                  Responsive.size(context, 20),
                                ),
                              ),
                            ),
                            builder: (_) => const _TopUpSheet(),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: Responsive.size(context, 20)),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Payment Methods",
                      style: TextStyle(
                        fontFamily: AppFonts.saira,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.sectionLabel,
                      ),
                    ),
                  ),
                  SizedBox(height: Responsive.size(context, 12)),
                  _PaymentMethod(
                    selected: state.selectedMethod == 0,
                    onSelected: () =>
                        context.read<WalletCubit>().selectMethod(0),
                    icon: Icons.credit_card,
                    title: "Credit/Debit card",
                    subtitle: "Expires 12/26",
                  ),
                  SizedBox(height: Responsive.size(context, 10)),
                  _PaymentMethod(
                    selected: state.selectedMethod == 1,
                    onSelected: () =>
                        context.read<WalletCubit>().selectMethod(1),
                    icon: Icons.account_balance_wallet_outlined,
                    title: "UPI (PhonePe, Google Pay)",
                    subtitle: "Quick Verification",
                  ),
                  SizedBox(height: Responsive.size(context, 10)),
                  _PaymentMethod(
                    selected: state.selectedMethod == 2,
                    onSelected: () =>
                        context.read<WalletCubit>().selectMethod(2),
                    icon: Icons.account_balance_outlined,
                    title: "Net Banking (HDFC, ICICI)",
                    subtitle: "Secure Portal",
                  ),
                  SizedBox(height: Responsive.size(context, 16)),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Auto-Refill",
                          style: TextStyle(
                            fontFamily: AppFonts.saira,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.sectionLabel,
                          ),
                        ),
                      ),
                      Switch(
                        value: state.autoRefillEnabled,
                        onChanged: context.read<WalletCubit>().setAutoRefill,
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.size(context, 6)),
                  const Text(
                    "Automatically top up Rs500.00 when your balance falls below Rs100.00. High-priority rides are never interrupted.",
                    style: TextStyle(
                      fontFamily: AppFonts.saira,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.sectionLabel,
                    ),
                  ),
                  SizedBox(height: Responsive.size(context, 16)),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Recent Activity",
                      style: TextStyle(
                        fontFamily: AppFonts.saira,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TopUpSheet extends StatelessWidget {
  const _TopUpSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: Responsive.size(context, 16),
          right: Responsive.size(context, 16),
          top: Responsive.size(context, 16),
          bottom:
          Responsive.size(context, 16) +
              MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: Responsive.size(context, 48),
                height: Responsive.size(context, 4),
                decoration: BoxDecoration(
                  color: AppColors.silver,
                  borderRadius: BorderRadius.circular(
                    Responsive.size(context, 999),
                  ),
                ),
              ),
            ),
            SizedBox(height: Responsive.size(context, 16)),
            const Text(
              "Top Up Balance",
              style: TextStyle(
                fontFamily: AppFonts.saira,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.sectionLabel,
              ),
            ),
            SizedBox(height: Responsive.size(context, 12)),
            ResponsiveTopUpGrid(
              onCustomTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const EnterCustomAmountPage(),
                  ),
                );
              },
            ),
            SizedBox(height: Responsive.size(context, 16)),
            const Text(
              "Payment Source",
              style: TextStyle(
                fontFamily: AppFonts.saira,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: Responsive.size(context, 12)),
            Container(
              padding: Responsive.insetsAll(context, 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  Responsive.size(context, 14),
                ),
                border: Border.all(color: AppColors.silver),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: Responsive.size(context, 18),
                    backgroundColor: AppColors.lavender,
                    child: Icon(
                      Icons.account_balance_wallet_outlined,
                      color: AppColors.violet,
                      size: Responsive.size(context, 18),
                    ),
                  ),
                  SizedBox(width: Responsive.size(context, 12)),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "UPI (PhonePe, Google Pay)",
                          style: TextStyle(
                            fontFamily: AppFonts.saira,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Quick Verification",
                          style: TextStyle(
                            fontFamily: AppFonts.saira,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.charcoal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.gray,
                    size: Responsive.size(context, 20),
                  ),
                ],
              ),
            ),
            SizedBox(height: Responsive.size(context, 16)),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: "Proceed to Top Up",
                size: AppButtonSize.large,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const TransactionSuccessPage(),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: Responsive.size(context, 8)),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethod extends StatelessWidget {
  const _PaymentMethod({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onSelected,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(Responsive.size(context, 14)),
      child: Container(
        padding: Responsive.insetsAll(context, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Responsive.size(context, 14)),
          border: Border.all(color: AppColors.silver),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: Responsive.size(context, 18),
              backgroundColor: AppColors.lavender,
              child: Icon(
                icon,
                size: Responsive.size(context, 18),
                color: AppColors.violet,
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
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.sectionLabel,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.emerald : AppColors.gray,
            ),
          ],
        ),
      ),
    );
  }
}
