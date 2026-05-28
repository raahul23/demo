import 'package:flutter_test/flutter_test.dart';
import 'package:goapp/features/feedback/domain/entities/feedback_submission.dart';
import 'package:goapp/features/feedback/domain/repositories/feedback_repository.dart';
import 'package:goapp/features/feedback/domain/usecases/submit_feedback_usecase.dart';
import 'package:goapp/features/feedback/presentation/cubit/feedback_cubit.dart';

class FakeFeedbackRepository implements FeedbackRepository {
  FeedbackSubmission? lastSubmission;

  @override
  Future<void> submitFeedback(FeedbackSubmission submission) async {
    lastSubmission = submission;
  }
}

void main() {
  test('submits feedback with rating', () async {
    final repo = FakeFeedbackRepository();
    final cubit = FeedbackCubit(
      submitFeedbackUseCase: SubmitFeedbackUseCase(repo),
    );

    cubit.updateRating(4);
    cubit.updateComment('Nice ride');

    await cubit.submit(
      FeedbackSubmission(
        driverName: 'A',
        vehicle: 'Bike',
        plateNumber: 'TN01',
        pickupLabel: 'Pickup',
        dropLabel: 'Drop',
        distanceKm: 2.5,
        durationMin: 8,
        rating: 0,
        comment: null,
      ),
    );

    expect(cubit.state.submitted, true);
    expect(repo.lastSubmission?.rating, 4);
    expect(repo.lastSubmission?.comment, 'Nice ride');

    await cubit.close();
  });
}
