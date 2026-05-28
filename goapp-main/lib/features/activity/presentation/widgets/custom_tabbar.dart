import "package:flutter/material.dart";
import "../../../../core/utils/constants.dart";
import "../../../../core/utils/responsive.dart";

class CustomTabBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomTabBar({
    super.key,
    required this.tabs,
    this.controller,
    this.selectedColor = AppColors.emerald,
    this.unselectedColor = AppColors.gray,
    this.indicatorColor = AppColors.emerald,
    this.indicatorThickness = 2,
    this.labelFontSize = 18,
    this.labelFontWeight = FontWeight.w700,
    this.unselectedFontWeight = FontWeight.w600,
    this.fontFamily,
    this.isScrollable = true,
    this.alignment = TabAlignment.start,
    this.paddingHorizontal = 16,
    this.paddingVertical = 8,
    this.labelPaddingRight = 16,
    this.showBottomDivider = true,
    this.dividerColor = AppColors.silver,
    this.dividerThickness = 1,
  });

  final List<Widget> tabs;
  final TabController? controller;
  final Color selectedColor;
  final Color unselectedColor;
  final Color indicatorColor;
  final double indicatorThickness;
  final double labelFontSize;
  final FontWeight labelFontWeight;
  final FontWeight unselectedFontWeight;
  final String? fontFamily;
  final bool isScrollable;
  final TabAlignment alignment;
  final double paddingHorizontal;
  final double paddingVertical;
  final double labelPaddingRight;
  final bool showBottomDivider;
  final Color dividerColor;
  final double dividerThickness;

  @override
  Size get preferredSize {
    return Size.fromHeight(kToolbarHeight);
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = Responsive.font(context, labelFontSize);
    final indicatorWidth =
    Responsive.size(context, indicatorThickness);
    final dividerHeight =
    Responsive.size(context, dividerThickness);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: Responsive.insetsSymmetric(
            context,
            horizontal: paddingHorizontal,
            vertical: paddingVertical,
          ),
          child: TabBar(
            controller: controller,
            tabs: tabs,
            isScrollable: isScrollable,
            tabAlignment: alignment,
            dividerColor: Colors.transparent,
            labelPadding:
            EdgeInsets.only(right: Responsive.size(context, labelPaddingRight)),
            labelColor: selectedColor,
            unselectedLabelColor: unselectedColor,
            labelStyle: TextStyle(
              fontFamily: fontFamily,
              fontSize: fontSize,
              fontWeight: labelFontWeight,
            ),
            unselectedLabelStyle: TextStyle(
              fontFamily: fontFamily,
              fontSize: fontSize,
              fontWeight: unselectedFontWeight,
            ),
            indicatorSize: TabBarIndicatorSize.label,
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(
                color: indicatorColor,
                width: indicatorWidth,
              ),
            ),
          ),
        ),
        if (showBottomDivider)
          Divider(
            height: dividerHeight,
            thickness: dividerHeight,
            color: dividerColor,
          ),
      ],
    );
  }
}
