import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/onboarding/onboarding_cubit.dart';
import '../../../../core/onboarding/onboarding_storage.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../domain/usecases/resend_otp_usecase.dart';
import '../../../profile/presentation/pages/profile_setup_page.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../cubit/auth_session_cubit.dart';
import '../cubit/otp_cubit.dart';
import '../theme/auth_ui_tokens.dart';
import '../widgets/auth_primary_button.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({
    super.key,
    required this.phoneNumber,
    required this.otpId,
    this.cubit,
  });

  final String phoneNumber;
  final String otpId;
  final OtpCubit? cubit;

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> with CodeAutoFill {
  static const int _maxOtpLength = 6;

  bool _successHandled = false;
  late final OtpCubit _otpCubit;
  late final bool _ownsCubit;
  late final List<TextEditingController> _controllers = List.generate(
    OtpCubit.otpLength,
    (_) => TextEditingController(),
  );
  late final List<FocusNode> _focusNodes = List.generate(
    OtpCubit.otpLength,
    (_) => FocusNode(),
  );

  @override
  void initState() {
    super.initState();
    _ownsCubit = widget.cubit == null;
    _otpCubit =
        widget.cubit ?? OtpCubit(resendOtpUseCase: getIt<ResendOtpUseCase>());
    if (!const bool.fromEnvironment('FLUTTER_TEST')) {
      listenForCode();
    }
  }

  @override
  void dispose() {
    if (!const bool.fromEnvironment('FLUTTER_TEST')) {
      cancel();
    }
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    if (_ownsCubit) {
      _otpCubit.close();
    }
    super.dispose();
  }

  void _handleSuccess({required bool syncSession}) {
    if (_successHandled) return;
    _successHandled = true;

    AuthSessionCubit? authSessionCubit;
    OnboardingCubit? onboardingCubit;

    try {
      authSessionCubit = context.read<AuthSessionCubit>();
    } catch (_) {
      authSessionCubit = null;
    }
    try {
      onboardingCubit = context.read<OnboardingCubit>();
    } catch (_) {
      onboardingCubit = null;
    }

    if (syncSession) {
      authSessionCubit?.check();
    } else {
      authSessionCubit?.markAuthenticatedForFlow();
    }
    onboardingCubit?.setStage(OnboardingStage.profile);

    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ProfileSetupPage()),
      (_) => false,
    );
  }

  @override
  void codeUpdated() {
    if (!mounted) return;
    final received = (code ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    final trimmed = received.length > _maxOtpLength
        ? received.substring(0, _maxOtpLength)
        : received;
    _otpCubit.updateCode(trimmed);
    _syncBoxesFromCode(trimmed);
  }

  void _syncBoxesFromCode(String otp) {
    for (var i = 0; i < OtpCubit.otpLength; i++) {
      final next = i < otp.length ? otp[i] : '';
      if (_controllers[i].text != next) {
        _controllers[i].text = next;
      }
    }
  }

  void _onOtpChanged(int index, String value) {
    final digit = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digit != value) {
      _controllers[index].text = digit;
      _controllers[index].selection = TextSelection.collapsed(
        offset: digit.length,
      );
    }
    if (digit.isNotEmpty && index < OtpCubit.otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (digit.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    _otpCubit.updateCode(_controllers.map((c) => c.text).join());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OtpCubit>.value(
      value: _otpCubit,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: MultiBlocListener(
            listeners: [
              BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthSuccess) {
                    _handleSuccess(syncSession: true);
                  }
                  if (state is AuthFailure) {
                    SnackBarUtils.show(context, state.message);
                  }
                },
              ),
              BlocListener<OtpCubit, OtpState>(
                listenWhen: (previous, current) =>
                    previous.code != current.code ||
                    previous.submitRequested != current.submitRequested ||
                    previous.submitError != current.submitError ||
                    previous.resendMessage != current.resendMessage ||
                    previous.errorMessage != current.errorMessage ||
                    previous.isLoading != current.isLoading,
                listener: (context, state) {
                  _syncBoxesFromCode(state.code);
                  if (state.submitError != null) {
                    SnackBarUtils.show(context, state.submitError!);
                    _otpCubit.consumeActions();
                    return;
                  }
                  if (state.submitRequested) {
                    _otpCubit.consumeActions();
                    _handleSuccess(syncSession: false);
                    return;
                  }
                  if (state.resendMessage != null) {
                    SnackBarUtils.show(context, state.resendMessage!);
                    _otpCubit.consumeActions();
                  }
                  if (state.errorMessage != null) {
                    SnackBarUtils.show(context, state.errorMessage!);
                    _otpCubit.consumeActions();
                  }
                },
              ),
            ],
            child: BlocBuilder<OtpCubit, OtpState>(
              builder: (context, otpState) {
                final timer = otpState.secondsLeft > 0
                    ? '00:${otpState.secondsLeft.toString().padLeft(2, '0')}'
                    : '00:00';
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                const SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: InkWell(
                                    onTap: () => Navigator.of(context).pop(),
                                    child: const Padding(
                                      padding: EdgeInsets.all(4),
                                      child: Icon(
                                        Icons.arrow_back_ios_new,
                                        size: 18,
                                        color: AuthUiColors.textDarkAlt,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 30),
                                const Text(
                                  'Verification',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: AuthUiColors.textDarkAlt,
                                    letterSpacing: -0.2,
                                    fontFamily: 'Saira',
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Please enter the 4-digit code sent to',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    color: AuthUiColors.textMuted,
                                    height: 1.4,
                                    fontFamily: 'Saira',
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  widget.phoneNumber.isEmpty
                                      ? '+1 (555) 012-3456'
                                      : widget.phoneNumber,
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w600,
                                    color: AuthUiColors.textDarkAlt,
                                    fontFamily: 'Saira',
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    OtpCubit.otpLength,
                                    (index) => Padding(
                                      padding: EdgeInsets.only(
                                        right: index == OtpCubit.otpLength - 1
                                            ? 0
                                            : 12,
                                      ),
                                      child: _OtpBox(
                                        fieldKey: index == 0
                                            ? const Key('otp_text_field')
                                            : null,
                                        controller: _controllers[index],
                                        focusNode: _focusNodes[index],
                                        autoFocus: index == 0,
                                        onChanged: (value) =>
                                            _onOtpChanged(index, value),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 34),
                                const Text(
                                  "Didn't receive the code?",
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: AuthUiColors.textMuted,
                                    fontFamily: 'Saira',
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap:
                                          otpState.canResend && !otpState.isLoading
                                              ? () => _otpCubit.resend(
                                                  widget.phoneNumber,
                                                )
                                              : null,
                                      child: Text(
                                        'RESEND CODE',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          color: otpState.canResend
                                              ? AuthUiColors.danger
                                              : AuthUiColors.danger.withValues(
                                                  alpha: 0.5,
                                                ),
                                          letterSpacing: 0.5,
                                          fontFamily: 'Saira',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE4F4ED),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Text(
                                        timer,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AuthUiColors.brandGreen,
                                          letterSpacing: 0.2,
                                          fontFamily: 'Saira',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                SizedBox(
                                  width: double.infinity,
                                  height: 46,
                                  child: AuthPrimaryButton(
                                    label: 'Verify Now',
                                    loading: otpState.isLoading,
                                    onPressed: otpState.isLoading
                                        ? null
                                        : () => _otpCubit.submit(
                                              widget.phoneNumber,
                                              widget.otpId,
                                            ),
                                  ),
                                ),
                                const SizedBox(height: 36),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    this.fieldKey,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.autoFocus = false,
  });

  final Key? fieldKey;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final bool autoFocus;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        key: fieldKey,
        controller: controller,
        focusNode: focusNode,
        autofocus: autoFocus,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AuthUiColors.textDarkAlt,
          fontFamily: 'Saira',
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
