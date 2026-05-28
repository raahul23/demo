import '../../domain/entities/service_item.dart';
import '../../domain/repositories/services_repository.dart';
import '../datasources/services_remote_datasource.dart';

class ServicesRepositoryImpl implements ServicesRepository {
  final ServicesRemoteDataSource remoteDataSource;

  ServicesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ServiceItem>> getServices() {
    return remoteDataSource.fetchServices();
  }
}
