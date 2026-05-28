import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/utils/app_assets.dart';
import '../theme/auth_ui_tokens.dart';
import '../widgets/onboarding_flow_scope.dart';
import '../widgets/onboarding_common.dart';

class ParcelDeliveryOnboardingPage extends StatelessWidget {
  const ParcelDeliveryOnboardingPage({super.key});

  static const Color _navy = Color(0xFF0F4CB9);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final height = constraints.maxHeight;
            final compact = height < 700;
            final tight = height < 640;
            final topPad = tight ? 8.0 : 12.0;
            final titleSize = tight ? 22.0 : (compact ? 24.0 : 26.0);
            final subtitleSize = tight ? 12.5 : (compact ? 13.0 : 14.0);
            final subtitlePad = tight ? 38.0 : 46.0;
            final sectionHeight = height * (8 / 13);
            final imageWidthByScreen =
                screenWidth * (tight ? 0.55 : (compact ? 0.6 : 0.65));
            final imageWidthByHeight =
                sectionHeight * (tight ? 0.8 : (compact ? 0.86 : 0.92));
            final imageWidth = math.min(imageWidthByScreen, imageWidthByHeight);
            final bottomPad = tight ? 18.0 : 24.0;
            final spaceLarge = tight ? 20.0 : 28.0;
            final spaceMid = tight ? 10.0 : 14.0;
            final spaceDots = tight ? 18.0 : 28.0;

            return Column(
              children: [
                OnboardingSkipButton(
                  onTap: () => OnboardingFlowScope.finishToLogin(context),
                  topPadding: topPad,
                  textColor: const Color(0x99111217),
                ),
                Expanded(
                  flex: 8,
                  child: LayoutBuilder(
                    builder: (context, area) {
                      final imageHeight = math.min(
                        area.maxHeight * (tight ? 0.74 : 0.82),
                        area.maxHeight,
                      );
                      return ClipRect(
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _DiagonalNavyPainter(),
                              ),
                            ),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: SizedBox(
                                  width: imageWidth,
                                  height: imageHeight,
                                  child: Image.asset(
                                    AppAssets.onboardingParcel,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.local_shipping,
                                        size: 120,
                                        color: Color(0xFF0F4CB9),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      SizedBox(height: spaceLarge),
                      Text(
                        'Parcel Delivery',
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w700,
                          color: AuthUiColors.textDark,
                          letterSpacing: -0.5,
                          fontFamily: 'Saira',
                        ),
                      ),
                      SizedBox(height: spaceMid),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: subtitlePad),
                        child: Text(
                          'Send packages safely and quickly with\nour elite delivery partners.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: subtitleSize,
                            height: 1.5,
                            color: AuthUiColors.textMuted,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Saira',
                          ),
                        ),
                      ),
                      SizedBox(height: spaceDots),
                      const OnboardingPageDots(activeIndex: 2),
                      const Spacer(),
                      OnboardingNavigationRow(
                        onBack: () => Navigator.pop(context),
                        onNext: () => OnboardingFlowScope.finishToLogin(context),
                        bottomPadding: bottomPad,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DiagonalNavyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ParcelDeliveryOnboardingPage._navy
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.86);
    path.lineTo(size.width, size.height * 0.72);
    path.lineTo(size.width, size.height * 0.10);
    path.lineTo(0, size.height * 0.25);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
