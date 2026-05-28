import '../pages/otp_page.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/di/injection.dart';
import '../../domain/services/phone_number_service.dart';
import '../cubit/login_form_cubit.dart';
import '../cubit/login_form_state.dart';
import '../theme/auth_font_scope.dart';
import '../theme/auth_ui_tokens.dart';
import 'auth_primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          LoginFormCubit(phoneNumberService: getIt<PhoneNumberService>()),
      child: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is OtpRequestSuccess) {
                final phone = context.read<LoginFormCubit>().state.phoneE164;
                if (phone == null) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AuthFontScope(
                      child: OtpPage(phoneNumber: phone, otpId: state.otpId),
                    ),
                  ),
                );
                SnackBarUtils.show(context, 'OTP sent');
              }
              if (state is AuthFailure) {
                SnackBarUtils.show(context, state.message);
              }
            },
          ),
          BlocListener<LoginFormCubit, LoginFormState>(
            listenWhen: (previous, current) =>
                previous.submitRequested != current.submitRequested ||
                previous.submitError != current.submitError,
            listener: (context, state) {
              if (state.submitError != null) {
                SnackBarUtils.show(context, state.submitError!);
                context.read<LoginFormCubit>().consumeSubmit();
                return;
              }
              if (state.submitRequested && state.phoneE164 != null) {
                context.read<AuthBloc>().add(
                  RequestOtpRequested(phone: state.phoneE164!),
                );
                context.read<LoginFormCubit>().consumeSubmit();
              }
            },
          ),
        ],
        child: BlocBuilder<LoginFormCubit, LoginFormState>(
          builder: (context, formState) {
            if (_controller.text != formState.digits) {
              _controller.value = TextEditingValue(
                text: formState.digits,
                selection: TextSelection.collapsed(
                  offset: formState.digits.length,
                ),
              );
            }
            return SafeArea(
              child: LayoutBuilder(
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 84),
                              const Text(
                                'Welcome to Goapp',
                                style: TextStyle(
                                  fontSize: 48 / 2,
                                  fontWeight: FontWeight.w700,
                                  color: AuthUiColors.textDarkAlt,
                                  letterSpacing: -0.2,
                                  fontFamily: 'Saira',
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Enter your mobile number to begin your\njourney.',
                                style: TextStyle(
                                  fontSize: 27 / 2,
                                  height: 1.45,
                                  color: AuthUiColors.textMuted,
                                  fontFamily: 'Saira',
                                ),
                              ),
                              const SizedBox(height: 30),
                              const Padding(
                                padding: EdgeInsets.only(left: 14),
                                child: Text(
                                  'Mobil Number',
                                  style: TextStyle(
                                    fontSize: 25 / 2,
                                    fontWeight: FontWeight.w600,
                                    color: AuthUiColors.textMuted,
                                    letterSpacing: 0.2,
                                    fontFamily: 'Saira',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const SizedBox(width: 14),
                                  const Text(
                                    '+91',
                                    style: TextStyle(
                                      fontSize: 30 / 2,
                                      fontWeight: FontWeight.w600,
                                      color: AuthUiColors.textDarkAlt,
                                      fontFamily: 'Saira',
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    width: 1,
                                    height: 38 / 2,
                                    color: AuthUiColors.textMuted.withValues(
                                      alpha: 0.45,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextField(
                                      controller: _controller,
                                      keyboardType: TextInputType.phone,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(10),
                                      ],
                                      decoration: const InputDecoration(
                                        isCollapsed: true,
                                        hintText: '0000000000',
                                        hintStyle: TextStyle(
                                          color: AuthUiColors.textMuted,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.1,
                                          fontFamily: 'Saira',
                                        ),
                                        border: InputBorder.none,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AuthUiColors.textDarkAlt,
                                        letterSpacing: 1.1,
                                        fontFamily: 'Saira',
                                      ),
                                      onChanged: context
                                          .read<LoginFormCubit>()
                                          .onInputChanged,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Container(
                                height: 1,
                                color: AuthUiColors.textMuted.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              const SizedBox(height: 18),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text.rich(
                                  TextSpan(
                                    style: TextStyle(
                                      fontSize: 23 / 2,
                                      height: 1.45,
                                      color: AuthUiColors.textMuted,
                                      fontFamily: 'Saira',
                                    ),
                                    children: [
                                      TextSpan(
                                        text:
                                            'By continuing, you agree to our  ',
                                      ),
                                      TextSpan(
                                        text: 'Terms of Service',
                                        style: TextStyle(
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                      TextSpan(text: ' and\n'),
                                      TextSpan(
                                        text: 'Privacy Policy',
                                        style: TextStyle(
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            '. Standard messaging rates may apply.',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: double.infinity,
                                height: 46,
                                child: BlocBuilder<AuthBloc, AuthState>(
                                  builder: (context, state) {
                                    final bool loading = state is AuthLoading;
                                    return AuthPrimaryButton(
                                      label: 'Get Verification Code',
                                      loading: loading,
                                      onPressed: context
                                          .read<LoginFormCubit>()
                                          .submit,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 34),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
