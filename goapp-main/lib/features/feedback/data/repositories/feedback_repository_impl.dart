import '../../domain/entities/feedback_submission.dart';
import '../../domain/repositories/feedback_repository.dart';
import '../datasources/feedback_remote_datasource.dart';

class FeedbackRepositoryImpl implements FeedbackRepository {
  final FeedbackRemoteDataSource remoteDataSource;

  FeedbackRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> submitFeedback(FeedbackSubmission submission) {
    return remoteDataSource.submit(submission);
  }
}
