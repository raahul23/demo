import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/utils/app_assets.dart';
import '../navigation/auth_route_transitions.dart';
import '../theme/auth_ui_tokens.dart';
import '../widgets/onboarding_flow_scope.dart';
import '../widgets/onboarding_common.dart';
import 'parcel_delivery_onboarding_page.dart';

class CabAutoOnboardingPage extends StatelessWidget {
  const CabAutoOnboardingPage({super.key});

  static const Color _yellow = Color(0xFFF8C84A);

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
            final subtitlePad = tight ? 34.0 : 40.0;
            final sectionHeight = height * (8 / 13);
            final imageWidthByScreen =
                screenWidth * (tight ? 0.72 : (compact ? 0.78 : 0.85));
            final imageWidthByHeight =
                sectionHeight * (tight ? 1.05 : (compact ? 1.12 : 1.2));
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
                                painter: _CurvedYellowPainter(),
                              ),
                            ),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: SizedBox(
                                  width: imageWidth,
                                  height: imageHeight,
                                  child: Image.asset(
                                    AppAssets.onboardingCabAuto,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.directions_car,
                                        size: 120,
                                        color: Color(0xFF8A6C00),
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
                        'Cab & Auto Rides',
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
                          'Comfortable rides for every journey. Premium\nservice tailored for your elite lifestyle.',
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
                      const OnboardingPageDots(activeIndex: 1),
                      const Spacer(),
                      OnboardingNavigationRow(
                        onBack: () => Navigator.pop(context),
                        onNext: () {
                          final nextPage = OnboardingFlowScope.wrapNext(
                            context,
                            const ParcelDeliveryOnboardingPage(),
                          );
                          Navigator.of(context).push(
                            onboardingSlideRoute(nextPage),
                          );
                        },
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

class _CurvedYellowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CabAutoOnboardingPage._yellow
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.18);
    path.quadraticBezierTo(
      size.width * 0.22,
      size.height * 0.08,
      size.width * 0.52,
      size.height * 0.12,
    );
    path.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.16,
      size.width,
      size.height * 0.12,
    );
    path.lineTo(size.width, size.height * 0.74);
    path.quadraticBezierTo(
      size.width * 0.78,
      size.height * 0.84,
      size.width * 0.52,
      size.height * 0.78,
    );
    path.quadraticBezierTo(
      size.width * 0.24,
      size.height * 0.72,
      0,
      size.height * 0.78,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
