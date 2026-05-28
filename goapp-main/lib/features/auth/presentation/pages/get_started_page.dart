import 'package:flutter/material.dart';

import '../../../../core/utils/app_assets.dart';
import '../theme/auth_ui_tokens.dart';
import '../widgets/auth_primary_button.dart';

class GetStartedPage extends StatelessWidget {
  const GetStartedPage({
    super.key,
    required this.onGetStarted,
    required this.onSignIn,
  });

  final VoidCallback onGetStarted;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text(
              'GoApp',
              style: TextStyle(
                fontSize: 46 / 2,
                fontWeight: FontWeight.w800,
                color: AuthUiColors.brandGreen,
                letterSpacing: -0.2,
                fontFamily: 'Saira',
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              flex: 11,
              child: Stack(
                children: [
                  Positioned.fill(child: Container(color: Colors.white)),
                  Center(
                    child: Transform.translate(
                      offset: const Offset(0, 10),
                      child: Image.asset(
                        AppAssets.loginHero,
                        width: MediaQuery.of(context).size.width * 0.98,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.person, size: 180);
                        },
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 200,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0x00FFFFFF), Color(0xFFFFFFFF)],
                              stops: [0.0, 0.619],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 48,
                    right: 48,
                    bottom: 10,
                    child: IgnorePointer(
                      child: Container(
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xB3FFFFFF),
                              blurRadius: 8,
                              spreadRadius: 1,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                        height: 1.45,
                        color: AuthUiColors.textDark,
                        fontFamily: 'Saira',
                      ),
                      children: [
                        TextSpan(
                          text: 'Relax ',
                          style: TextStyle(color: AuthUiColors.brandGreen),
                        ),
                        TextSpan(text: 'and '),
                        TextSpan(
                          text: 'go ',
                          style: TextStyle(color: AuthUiColors.brandGreen),
                        ),
                        TextSpan(text: 'wherever\nyou want'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AuthPrimaryButton(
                    height: 50,
                    label: "Let's Get Started",
                    onPressed: onGetStarted,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: GestureDetector(
                      onTap: onSignIn,
                      child: const Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: AuthUiColors.textMuted,
                            fontFamily: 'Saira',
                          ),
                          children: [
                            TextSpan(text: 'Already have an account? '),
                            TextSpan(
                              text: 'Sign in',
                              style: TextStyle(
                                color: AuthUiColors.brandGreen,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
