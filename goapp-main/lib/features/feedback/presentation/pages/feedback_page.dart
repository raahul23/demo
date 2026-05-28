import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../domain/entities/feedback_submission.dart';
import '../../domain/usecases/submit_feedback_usecase.dart';
import '../cubit/feedback_cubit.dart';
import '../cubit/feedback_state.dart';
import 'feedback_success.dart';

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({
    super.key,
    this.summary,
    this.cubit,
  });

  final FeedbackSubmission? summary;
  final FeedbackCubit? cubit;

  @override
  Widget build(BuildContext context) {
    final fallbackSummary =
        summary ??
        const FeedbackSubmission(
          driverName: 'Sam Yogi',
          vehicle: 'Bike',
          plateNumber: 'TN 01 ZZ 0001',
          pickupLabel: 'Pickup',
          dropLabel: 'Drop',
          distanceKm: 0,
          durationMin: 0,
          rating: 0,
        );

    return BlocProvider<FeedbackCubit>(
      create: (_) =>
          cubit ??
          FeedbackCubit(
            submitFeedbackUseCase: getIt<SubmitFeedbackUseCase>(),
          ),
      child: _FeedbackView(summary: fallbackSummary),
    );
  }
}

class _FeedbackView extends StatefulWidget {
  const _FeedbackView({required this.summary});

  final FeedbackSubmission summary;

  @override
  State<_FeedbackView> createState() => _FeedbackViewState();
}

class _FeedbackViewState extends State<_FeedbackView> {
  final TextEditingController _commentController = TextEditingController();
  final Set<String> _selectedTags = <String>{};

  static const List<(String, IconData)> _tags = [
    ('Clean Vehicle', Icons.directions_car_outlined),
    ('Professional', Icons.person_outline),
    ('Safe Driving', Icons.security),
    ('Smooth Route', Icons.alt_route),
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _goHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomePage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: BlocListener<FeedbackCubit, FeedbackState>(
            listenWhen: (previous, current) =>
                previous.errorMessage != current.errorMessage ||
                previous.submitted != current.submitted,
            listener: (context, state) {
              if (state.errorMessage != null) {
                SnackBarUtils.show(context, state.errorMessage!);
              }
              if (state.submitted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const FeedbackSuccessPage(),
                  ),
                );
              }
            },
            child: BlocBuilder<FeedbackCubit, FeedbackState>(
              builder: (context, state) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      const Text(
                        'Feedback',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Share your feedback about the ride',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      Stack(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: AssetImage('assets/images/payment/person.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_circle,
                                color: Color(0xFF00A86B),
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        summary.driverName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${summary.vehicle} • ${summary.plateNumber}',
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${summary.pickupLabel} → ${summary.dropLabel}',
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return IconButton(
                            onPressed: () => context
                                .read<FeedbackCubit>()
                                .updateRating(index + 1),
                            icon: Icon(
                              index < state.rating ? Icons.star : Icons.star_border,
                              color: index < state.rating
                                  ? Colors.amber
                                  : Colors.grey[300],
                              size: 32,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 24),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'What went well?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00A86B),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: _tags.map((tag) {
                          final label = tag.$1;
                          final icon = tag.$2;
                          final isSelected = _selectedTags.contains(label);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedTags.remove(label);
                                } else {
                                  _selectedTags.add(label);
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFE8F5E9)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF00A86B)
                                      : Colors.grey[300]!,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    icon,
                                    size: 18,
                                    color: isSelected
                                        ? const Color(0xFF00A86B)
                                        : Colors.black87,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    label,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? const Color(0xFF00A86B)
                                          : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _commentController,
                        maxLines: 4,
                        onChanged: context.read<FeedbackCubit>().updateComment,
                        decoration: InputDecoration(
                          hintText: 'Additional comments (optional)',
                          hintStyle:
                              const TextStyle(color: Colors.grey, fontSize: 14),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.all(20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide:
                                BorderSide(color: Colors.grey.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide:
                                BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide:
                                const BorderSide(color: Color(0xFF00A86B)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: state.submitting
                              ? null
                              : () => context.read<FeedbackCubit>().submit(
                                    summary,
                                  ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00C853),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: state.submitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Submit',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _goHome,
                        child: const Text('Skip'),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Your feedback helps us improve the experience for everyone in the community.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
