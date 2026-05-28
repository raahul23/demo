import '../entities/service_item.dart';
import '../repositories/services_repository.dart';

class GetServicesUseCase {
  final ServicesRepository repository;

  GetServicesUseCase(this.repository);

  Future<List<ServiceItem>> call() {
    return repository.getServices();
  }
}
