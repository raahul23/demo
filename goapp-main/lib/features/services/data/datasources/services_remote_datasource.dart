import '../../domain/entities/service_item.dart';

abstract class ServicesRemoteDataSource {
  Future<List<ServiceItem>> fetchServices();
}
