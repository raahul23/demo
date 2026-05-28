import "package:flutter/material.dart";
import "../../../../core/utils/constants.dart";

class ResponsiveTopUpGrid extends StatefulWidget {
  const ResponsiveTopUpGrid({
    super.key,
    this.onSelected,
    this.onCustomTap,
  });

  final ValueChanged<ResponsiveTopUpOption>? onSelected;
  final VoidCallback? onCustomTap;

  @override
  State<ResponsiveTopUpGrid> createState() => _ResponsiveTopUpGridState();
}

class _ResponsiveTopUpGridState extends State<ResponsiveTopUpGrid> {
  ResponsiveTopUpOption _selected = ResponsiveTopUpOption.preferred;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final gap = width * 0.04;
        final cardWidth = (width - gap) / 2;
        final cardHeight = cardWidth * 0.65;
        final base = cardWidth < cardHeight ? cardWidth : cardHeight;
        final radius = base * 0.06;
        final padding = base * 0.08;
        final titleSize = base * 0.14;
        final amountSize = base * 0.20;
        final checkSize = base * 0.16;
        final checkIconSize = base * 0.09;
        final shadowBlur = base * 0.08;

        final options = [
          _TopUpOptionData(
            label: "Standard",
            amount: "₹200",
            value: ResponsiveTopUpOption.standard,
          ),
          _TopUpOptionData(
            label: "Preferred",
            amount: "₹500",
            value: ResponsiveTopUpOption.preferred,
          ),
          _TopUpOptionData(
            label: "Elite",
            amount: "₹1000",
            value: ResponsiveTopUpOption.elite,
          ),
          _TopUpOptionData(
            label: "Other",
            amount: "Custom",
            value: ResponsiveTopUpOption.other,
          ),
        ];

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: options.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: gap,
            mainAxisSpacing: gap,
            childAspectRatio: cardWidth / cardHeight,
          ),
          itemBuilder: (context, index) {
            final option = options[index];
            return _OptionCard(
              label: option.label,
              amount: option.amount,
              width: cardWidth,
              height: cardHeight,
              radius: radius,
              padding: padding,
              titleSize: titleSize,
              amountSize: amountSize,
              checkSize: checkSize,
              checkIconSize: checkIconSize,
              shadowBlur: shadowBlur,
              selected: _selected == option.value,
              onTap: () => _handleTap(option.value),
            );
          },
        );
      },
    );
  }

  void _handleTap(ResponsiveTopUpOption option) {
    if (option == ResponsiveTopUpOption.other) {
      widget.onCustomTap?.call();
      return;
    }
    if (_selected == option) return;
    setState(() => _selected = option);
    widget.onSelected?.call(option);
  }
}

enum ResponsiveTopUpOption { standard, preferred, elite, other }

class _TopUpOptionData {
  const _TopUpOptionData({
    required this.label,
    required this.amount,
    required this.value,
  });

  final String label;
  final String amount;
  final ResponsiveTopUpOption value;
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.label,
    required this.amount,
    required this.width,
    required this.height,
    required this.radius,
    required this.padding,
    required this.titleSize,
    required this.amountSize,
    required this.checkSize,
    required this.checkIconSize,
    required this.shadowBlur,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String amount;
  final double width;
  final double height;
  final double radius;
  final double padding;
  final double titleSize;
  final double amountSize;
  final double checkSize;
  final double checkIconSize;
  final double shadowBlur;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: selected ? AppColors.green : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: shadowBlur,
              offset: Offset(0, shadowBlur * 0.25),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Checkmark positioned in top right
            if (selected)
              Positioned(
                top: padding * 0.8,
                right: padding * 0.8,
                child: Container(
                  width: checkSize,
                  height: checkSize,
                  decoration: const BoxDecoration(
                    color: AppColors.green,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: checkIconSize,
                    color: Colors.white,
                  ),
                ),
              ),
            // Centered content
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w500,
                        color: AppColors.charcoal,
                      ),
                    ),
                    SizedBox(height: padding * 0.5),
                    Text(
                      amount,
                      style: TextStyle(
                        fontSize: amountSize,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
