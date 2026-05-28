import '../../domain/entities/feedback_submission.dart';

abstract class FeedbackRemoteDataSource {
  Future<void> submit(FeedbackSubmission submission);
}
