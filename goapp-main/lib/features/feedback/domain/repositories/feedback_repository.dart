import '../entities/feedback_submission.dart';

abstract class FeedbackRepository {
  Future<void> submitFeedback(FeedbackSubmission submission);
}
