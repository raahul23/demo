import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:goapp/features/activity/presentation/pages/transaction_successful.dart";
import "../../../../core/utils/constants.dart";
import "../cubit/custom_amount_cubit.dart";
import "../widgets/appbar.dart";

class EnterCustomAmountPage extends StatelessWidget {
  const EnterCustomAmountPage({
    super.key,
    this.initialAmount,
    this.minAmount = 100,
    this.maxAmount = 50000,
    this.onProceed,
  });

  final String? initialAmount;
  final double minAmount;
  final double maxAmount;
  final Function(double amount)? onProceed;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EnterCustomAmountCubit(
        initialAmount: initialAmount,
        minAmount: minAmount,
        maxAmount: maxAmount,
      ),
      child: BlocBuilder<EnterCustomAmountCubit, EnterCustomAmountState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.coolwhite,
            appBar: AppAppBar(
              title: "Enter Custom Amount",
              centerTitle: false,
              backgroundColor: Colors.white,
              foregroundColor: AppColors.black,
              elevation: 0,
              onBack: () => Navigator.pop(context),
            ),
            body: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final height = constraints.maxHeight;

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: height * 0.06),
                            _AmountDisplay(amount: state.amount, width: width),
                            SizedBox(height: height * 0.03),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: width * 0.08,
                              ),
                              child: Text(
                                "Enter an amount between Rs${state.minAmount.toInt()} and Rs${state.maxAmount.toInt()}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: AppFonts.saira,
                                  fontSize: width * 0.035,
                                  color: AppColors.charcoal,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            SizedBox(height: height * 0.03),
                            _NumericKeypad(
                              onKeyPress: context
                                  .read<EnterCustomAmountCubit>()
                                  .onKeyPress,
                              width: width,
                              height: height,
                            ),
                          ],
                        ),
                      ),
                    ),
                    _BottomSection(
                      isValid: state.isValidAmount,
                      width: width,
                      onProceed: () {
                        final value = state.parsedAmount;
                        if (!state.isValidAmount || value == null) return;
                        onProceed?.call(value);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const TransactionSuccessPage(),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _AmountDisplay extends StatelessWidget {
  const _AmountDisplay({required this.amount, required this.width});

  final String amount;
  final double width;

  @override
  Widget build(BuildContext context) {
    final fontSize = width * 0.18;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: fontSize * 0.1),
          child: Text(
            "Rs",
            style: TextStyle(
              fontFamily: AppFonts.saira,
              fontSize: fontSize * 0.4,
              fontWeight: FontWeight.w400,
              color: AppColors.charcoal,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          amount.isEmpty ? "0" : amount,
          style: const TextStyle(
            fontFamily: AppFonts.saira,
            fontSize: 62,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }
}

class _NumericKeypad extends StatelessWidget {
  const _NumericKeypad({
    required this.onKeyPress,
    required this.width,
    required this.height,
  });

  final Function(String) onKeyPress;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final keypadWidth = width * 0.85;
    final buttonSize = keypadWidth / 3.5;
    final spacing = height * 0.02;

    final keys = [
      ["1", "2", "3"],
      ["4", "5", "6"],
      ["7", "8", "9"],
      [".", "0", "backspace"],
    ];

    return SizedBox(
      width: keypadWidth,
      child: Column(
        children: keys
            .map(
              (row) => Padding(
            padding: EdgeInsets.only(bottom: spacing),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row
                  .map(
                    (key) => _KeypadButton(
                  label: key,
                  onPressed: () => onKeyPress(key),
                  size: buttonSize,
                  fontSize: 24,
                ),
              )
                  .toList(),
            ),
          ),
        )
            .toList(),
      ),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  const _KeypadButton({
    required this.label,
    required this.onPressed,
    required this.size,
    required this.fontSize,
  });

  final String label;
  final VoidCallback onPressed;
  final double size;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final Widget content;

    if (label == "backspace") {
      content = Icon(
        Icons.backspace_outlined,
        size: fontSize,
        color: AppColors.charcoal,
      );
    } else {
      content = Text(
        label,
        style: TextStyle(
          fontFamily: AppFonts.saira,
          fontSize: fontSize,
          fontWeight: FontWeight.w400,
          color: AppColors.charcoal,
        ),
      );
    }

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(size / 2),
      child: SizedBox(
        width: size,
        height: size,
        child: Center(child: content),
      ),
    );
  }
}

class _BottomSection extends StatelessWidget {
  const _BottomSection({
    required this.isValid,
    required this.width,
    required this.onProceed,
  });

  final bool isValid;
  final double width;
  final VoidCallback onProceed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(width * 0.05),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: width * 0.14,
              child: ElevatedButton(
                onPressed: isValid ? onProceed : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  disabledBackgroundColor: AppColors.silver,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(width * 0.03),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Proceed",
                      style: TextStyle(
                        fontFamily: AppFonts.saira,
                        fontSize: width * 0.042,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: width * 0.02),
                    Icon(
                      Icons.arrow_forward,
                      size: width * 0.045,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: width * 0.03),
            const Text(
              "Funds will be added to your primary wallet.",
              style: TextStyle(
                fontFamily: AppFonts.saira,
                fontSize: 12,
                color: AppColors.charcoal,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

