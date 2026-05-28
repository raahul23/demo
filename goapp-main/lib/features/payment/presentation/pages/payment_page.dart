import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../feedback/domain/entities/feedback_submission.dart';
import '../../../feedback/presentation/pages/feedback_page.dart';
import '../../domain/usecases/get_payment_options_usecase.dart';
import '../../domain/usecases/submit_payment_usecase.dart';
import '../cubit/payment_cubit.dart';
import '../cubit/payment_state.dart';
import 'payment_success_page.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({
    super.key,
    required this.amount,
    required this.feedbackSummary,
    this.cubit,
  });

  final double amount;
  final FeedbackSubmission feedbackSummary;
  final PaymentCubit? cubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PaymentCubit>(
      create: (_) =>
          cubit ??
          PaymentCubit(
            getPaymentOptionsUseCase: getIt<GetPaymentOptionsUseCase>(),
            submitPaymentUseCase: getIt<SubmitPaymentUseCase>(),
            amount: amount,
          ),
      child: _PaymentView(feedbackSummary: feedbackSummary),
    );
  }
}

class _PaymentView extends StatelessWidget {
  const _PaymentView({required this.feedbackSummary});

  final FeedbackSubmission feedbackSummary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Payment Methods',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: BlocListener<PaymentCubit, PaymentState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage ||
            previous.success != current.success,
        listener: (context, state) {
          if (state.errorMessage != null) {
            SnackBarUtils.show(context, state.errorMessage!);
          }
          if (!state.success) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => PaymentSuccessPage(
                source: PaymentSource.payment,
                doneLabel: 'Done',
                doneRouteBuilder: (_) => FeedbackPage(summary: feedbackSummary),
              ),
            ),
          );
        },
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionHeader(title: 'UPI Payments'),
                    const SizedBox(height: 12),
                    _RoundedCard(
                      child: ListTile(
                        onTap: () => _navigateToSuccess(context),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        leading: const _ImagePlaceholder(
                          imagePath: 'assets/images/payment/smartphone.png',
                          iconColor: Color(0xFF9C27B0),
                        ),
                        title: const Text(
                          'GoApp Wallet',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: const Text(
                          'GoApp Balance : 500',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const _SectionHeader(title: 'Saved Cards'),
                    const SizedBox(height: 12),
                    _RoundedCard(
                      child: Column(
                        children: [
                          _ListTileItem(
                            title: 'Google Pay',
                            subtitle: 'Directly from bank account',
                            imagePath: 'assets/images/payment/google_pay.png',
                            iconColor: const Color(0xFF1976D2),
                            onTap: () => _navigateToSuccess(context),
                          ),
                          const Divider(height: 1, indent: 72, color: Color(0xFFF1F1F1)),
                          _ListTileItem(
                            title: 'PhonePe',
                            subtitle: 'Fast and secure UPI',
                            imagePath: 'assets/images/payment/smartphone.png',
                            iconColor: const Color(0xFF9C27B0),
                            onTap: () => _navigateToSuccess(context),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const _SectionHeader(title: 'Saved Cards'),
                    const SizedBox(height: 12),
                    _RoundedCard(
                      child: Column(
                        children: [
                          _ListTileItem(
                            title: 'Visa •••• 1122',
                            subtitle: 'Expires 09/27',
                            imagePath: 'assets/images/payment/visa.png',
                            iconColor: const Color(0xFF0D47A1),
                            onTap: () => _navigateToSuccess(context),
                          ),
                          const Divider(height: 1, indent: 72, color: Color(0xFFF1F1F1)),
                          _ListTileItem(
                            title: 'Mastercard •••• 4455',
                            subtitle: 'Expires 12/25',
                            imagePath: 'assets/images/payment/mastercard.png',
                            iconColor: const Color(0xFFF44336),
                            onTap: () => _navigateToSuccess(context),
                          ),
                          const Divider(height: 1, indent: 72, color: Color(0xFFF1F1F1)),
                          ListTile(
                            onTap: () {},
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: const SizedBox(
                              width: 48,
                              height: 48,
                              child: Icon(
                                Icons.add_circle,
                                color: Color(0xFF0D47A1),
                                size: 28,
                              ),
                            ),
                            title: const Text(
                              'Add New Card',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF0D47A1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const _SectionHeader(title: 'Net Banking'),
                    const SizedBox(height: 12),
                    const _RoundedCard(
                      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _BankGridItem(name: 'HDFC Bank', acronym: 'HDFC'),
                              _BankGridItem(name: 'ICICI Bank', acronym: 'ICICI'),
                              _BankGridItem(name: 'SBI Bank', acronym: 'SBI'),
                            ],
                          ),
                          SizedBox(height: 32),
                          Center(
                            child: Text(
                              'View All Banks',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: BlocBuilder<PaymentCubit, PaymentState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: state.processing
                          ? null
                          : () => context.read<PaymentCubit>().pay(),
                      child: state.processing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Pay Now'),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToSuccess(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaymentSuccessPage(
          source: PaymentSource.payment,
          doneLabel: 'Done',
          doneRouteBuilder: (_) => FeedbackPage(summary: feedbackSummary),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _RoundedCard extends StatelessWidget {
  const _RoundedCard({required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: padding == null ? child : Padding(padding: padding!, child: child),
      ),
    );
  }
}

class _ListTileItem extends StatelessWidget {
  const _ListTileItem({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.iconColor,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String imagePath;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: _ImagePlaceholder(imagePath: imagePath, iconColor: iconColor),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: Colors.black87,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          subtitle,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.imagePath, required this.iconColor});

  final String imagePath;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
        color: iconColor,
        errorBuilder: (_, error, stackTrace) =>
            Icon(_getFallbackIcon(), color: iconColor, size: 24),
      ),
    );
  }

  IconData _getFallbackIcon() {
    if (imagePath.contains('smartphone')) return Icons.smartphone;
    if (imagePath.contains('google_pay')) return Icons.account_balance_wallet;
    if (imagePath.contains('visa') || imagePath.contains('mastercard')) {
      return Icons.credit_card;
    }
    return Icons.payment;
  }
}

class _BankGridItem extends StatelessWidget {
  const _BankGridItem({required this.name, required this.acronym});

  final String name;
  final String acronym;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFF1F1F1)),
          ),
          child: Text(
            acronym,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
