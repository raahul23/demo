import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/feedback_submission.dart';
import '../../domain/usecases/submit_feedback_usecase.dart';
import 'feedback_state.dart';

class FeedbackCubit extends Cubit<FeedbackState> {
  final SubmitFeedbackUseCase submitFeedbackUseCase;

  FeedbackCubit({required this.submitFeedbackUseCase})
      : super(FeedbackState.initial());

  void updateRating(int rating) {
    emit(state.copyWith(rating: rating, clearError: true));
  }

  void updateComment(String comment) {
    emit(state.copyWith(comment: comment, clearError: true));
  }

  Future<void> submit(FeedbackSubmission submission) async {
    if (state.rating == 0) {
      emit(state.copyWith(errorMessage: 'Please rate the driver'));
      return;
    }
    emit(state.copyWith(submitting: true, clearError: true));
    try {
      final payload = FeedbackSubmission(
        driverName: submission.driverName,
        vehicle: submission.vehicle,
        plateNumber: submission.plateNumber,
        pickupLabel: submission.pickupLabel,
        dropLabel: submission.dropLabel,
        distanceKm: submission.distanceKm,
        durationMin: submission.durationMin,
        rating: state.rating,
        comment: state.comment.isEmpty ? null : state.comment,
      );
      await submitFeedbackUseCase(payload);
      emit(state.copyWith(submitting: false, submitted: true));
    } catch (_) {
      emit(
        state.copyWith(
          submitting: false,
          errorMessage: 'Failed to submit feedback',
        ),
      );
    }
  }
}
