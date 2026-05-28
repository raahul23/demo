import '../../domain/entities/service_item.dart';

class ServicesState {
  final List<ServiceItem> items;
  final bool loading;
  final String? errorMessage;

  const ServicesState({
    required this.items,
    required this.loading,
    required this.errorMessage,
  });

  factory ServicesState.initial() {
    return const ServicesState(
      items: [],
      loading: true,
      errorMessage: null,
    );
  }

  ServicesState copyWith({
    List<ServiceItem>? items,
    bool? loading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ServicesState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
