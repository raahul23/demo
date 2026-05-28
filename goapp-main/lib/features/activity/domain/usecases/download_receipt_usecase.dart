import '../repositories/activity_repository.dart';

class DownloadReceiptUseCase {
  final ActivityRepository repository;

  DownloadReceiptUseCase(this.repository);

  Future<bool> call(String rideId) {
    return repository.downloadReceipt(rideId);
  }
}
