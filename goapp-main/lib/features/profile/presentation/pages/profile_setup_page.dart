import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/onboarding/onboarding_cubit.dart';
import '../../../../core/onboarding/onboarding_storage.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../activity/presentation/widgets/appbar.dart';
import '../../../location/presentation/pages/location_permission_page.dart';
import '../../domain/entities/profile.dart';
import '../../domain/services/profile_validation_service.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../cubit/profile_setup_cubit.dart';
import '../cubit/profile_setup_state.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key, this.allowBack = false});

  final bool allowBack;

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _emergencyController = TextEditingController();

  bool _prefilled = false;
  late final ProfileSetupCubit _cubit;
  late final ProfileBloc _profileBloc;
  late final bool _ownsProfileBloc;

  @override
  void initState() {
    super.initState();
    _cubit = ProfileSetupCubit(
      validationService: getIt<ProfileValidationService>(),
    );
    try {
      _profileBloc = context.read<ProfileBloc>();
      _ownsProfileBloc = false;
    } catch (_) {
      _profileBloc = getIt<ProfileBloc>();
      _ownsProfileBloc = true;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = _profileBloc.state;
      if (state is ProfileSuccess) {
        _prefillFromProfile(state.profile);
      } else {
        _profileBloc.add(ProfileRequested());
      }
    });
  }

  @override
  void dispose() {
    _cubit.close();
    if (_ownsProfileBloc) {
      _profileBloc.close();
    }
    _nameController.dispose();
    _emailController.dispose();
    _emergencyController.dispose();
    super.dispose();
  }

  void _prefillFromProfile(Profile profile) {
    if (_prefilled) return;
    _prefilled = true;
    _nameController.text = profile.name;
    _emailController.text = profile.email;
    _emergencyController.text = profile.emergencyContact;
    _cubit.setInitial(
      name: profile.name,
      gender: profile.gender,
      email: profile.email,
      emergencyContact: profile.emergencyContact,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileBloc>.value(
      value: _profileBloc,
      child: BlocProvider<ProfileSetupCubit>.value(
        value: _cubit,
        child: PopScope(
          canPop: widget.allowBack,
          child: Scaffold(
            appBar: AppAppBar(
              title: 'Profile',
              showBack: widget.allowBack,
            ),
            body: MultiBlocListener(
              listeners: [
                BlocListener<ProfileBloc, ProfileState>(
                  listener: (context, state) {
                    if (state is ProfileSuccess) {
                      final formState = context.read<ProfileSetupCubit>().state;
                      final hasSubmission = formState.submission != null;
                      if (!hasSubmission) {
                        _prefillFromProfile(state.profile);
                        return;
                      }
                      if (widget.allowBack) {
                        Navigator.of(context).pop();
                        return;
                      }
                      try {
                        context
                            .read<OnboardingCubit>()
                            .setStage(OnboardingStage.location);
                      } catch (_) {}
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const LocationPermissionPage(),
                        ),
                      );
                    }
                    if (state is ProfileFailure) {
                      SnackBarUtils.show(context, state.message);
                    }
                  },
                ),
                BlocListener<ProfileSetupCubit, ProfileSetupState>(
                  listenWhen: (previous, current) =>
                      previous.submitRequested != current.submitRequested,
                  listener: (context, state) {
                    if (!state.submitRequested || state.submission == null) {
                      return;
                    }
                    _profileBloc.add(
                      ProfileSubmitted(
                        name: state.submission!.name,
                        gender: state.submission!.gender,
                        email: state.submission!.email,
                        emergencyContact: state.submission!.emergencyContact,
                      ),
                    );
                    context.read<ProfileSetupCubit>().consumeSubmit();
                  },
                ),
              ],
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: BlocBuilder<ProfileSetupCubit, ProfileSetupState>(
                  builder: (context, formState) {
                    return ListView(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            errorText: formState.showValidation
                                ? formState.nameError
                                : null,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[A-Za-z ]'),
                            ),
                          ],
                          onChanged:
                              context.read<ProfileSetupCubit>().updateName,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: formState.gender,
                          items: const [
                            DropdownMenuItem(
                              value: 'Male',
                              child: Text('Male'),
                            ),
                            DropdownMenuItem(
                              value: 'Female',
                              child: Text('Female'),
                            ),
                            DropdownMenuItem(
                              value: 'Other',
                              child: Text('Other'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            context.read<ProfileSetupCubit>().updateGender(value);
                          },
                          decoration: InputDecoration(
                            labelText: 'Gender',
                            errorText: formState.showValidation
                                ? formState.genderError
                                : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            errorText: formState.showValidation
                                ? formState.emailError
                                : null,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r"[A-Za-z0-9@._+\-]"),
                            ),
                          ],
                          onChanged:
                              context.read<ProfileSetupCubit>().updateEmail,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emergencyController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          decoration: InputDecoration(
                            labelText: 'Emergency Contact Number',
                            errorText: formState.showValidation
                                ? formState.emergencyError
                                : null,
                          ),
                          onChanged: context
                              .read<ProfileSetupCubit>()
                              .updateEmergency,
                        ),
                        const SizedBox(height: 24),
                        BlocBuilder<ProfileBloc, ProfileState>(
                          builder: (context, state) {
                            if (state is ProfileLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            return ElevatedButton(
                              onPressed:
                                  context.read<ProfileSetupCubit>().submit,
                              child: const Text('Save Profile'),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
