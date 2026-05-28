import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/utils/app_assets.dart';
import '../navigation/auth_route_transitions.dart';
import '../theme/auth_ui_tokens.dart';
import '../widgets/onboarding_flow_scope.dart';
import '../widgets/onboarding_common.dart';
import 'cab_auto_onboarding_page.dart';

class BikeTaxiOnboardingPage extends StatelessWidget {
  const BikeTaxiOnboardingPage({super.key});

  static const Color _blue = Color(0xFF0F4CB9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            OnboardingSkipButton(
              onTap: () => OnboardingFlowScope.finishToLogin(context),
              fontWeight: FontWeight.w600,
            ),
            Expanded(
              flex: 8,
              child: LayoutBuilder(
                builder: (context, area) {
                  final shortest = MediaQuery.of(context).size.shortestSide;
                  final isTablet = shortest >= 600;
                  final imageWidth = area.maxWidth * (isTablet ? 0.54 : 0.68);
                  final imageHeightCap =
                      area.maxHeight * (isTablet ? 0.7 : 0.84);
                  final imageHeight = math.min(imageHeightCap, area.maxHeight);
                  return ClipRect(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(painter: _DiagonalBluePainter()),
                        ),
                        Center(
                          child: SizedBox(
                            width: imageWidth,
                            height: imageHeight,
                            child: Image.asset(
                              AppAssets.onboardingBikeTaxi,
                              fit: BoxFit.contain,
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
                  const SizedBox(height: 22),
                  const Text(
                    'Bike Taxi',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w700,
                      color: AuthUiColors.textDark,
                      letterSpacing: -0.2,
                      fontFamily: 'Saira',
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 54),
                    child: Text(
                      'Beat traffic and reach faster with our\npremium luxury service.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.55,
                        color: AuthUiColors.textMuted,
                        fontFamily: 'Saira',
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const OnboardingPageDots(activeIndex: 0, activeWidth: 28),
                  const Spacer(),
                  OnboardingNavigationRow(
                    onBack: () => Navigator.of(context).pop(),
                    onNext: () {
                      final nextPage = OnboardingFlowScope.wrapNext(
                        context,
                        const CabAutoOnboardingPage(),
                      );
                      Navigator.of(
                        context,
                      ).push(onboardingSlideRoute(nextPage));
                    },
                    backIcon: Icons.arrow_back,
                    nextIcon: Icons.arrow_forward,
                    iconSize: 18,
                    iconTextGap: 8,
                    bottomPadding: 24,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiagonalBluePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = BikeTaxiOnboardingPage._blue
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, size.height * 0.18)
      ..lineTo(size.width, size.height * 0.36)
      ..lineTo(size.width, size.height * 0.86)
      ..lineTo(0, size.height * 0.66)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
