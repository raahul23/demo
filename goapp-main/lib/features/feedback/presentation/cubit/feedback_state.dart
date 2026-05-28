class FeedbackState {
  final int rating;
  final String comment;
  final bool submitting;
  final bool submitted;
  final String? errorMessage;

  const FeedbackState({
    required this.rating,
    required this.comment,
    required this.submitting,
    required this.submitted,
    required this.errorMessage,
  });

  factory FeedbackState.initial() {
    return const FeedbackState(
      rating: 0,
      comment: '',
      submitting: false,
      submitted: false,
      errorMessage: null,
    );
  }

  FeedbackState copyWith({
    int? rating,
    String? comment,
    bool? submitting,
    bool? submitted,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FeedbackState(
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      submitting: submitting ?? this.submitting,
      submitted: submitted ?? this.submitted,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
