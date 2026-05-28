import 'package:flutter_test/flutter_test.dart';

import 'package:goapp/features/services/data/datasources/services_remote_datasource.dart';
import 'package:goapp/features/services/data/repositories/services_repository_impl.dart';
import 'package:goapp/features/services/domain/entities/service_item.dart';
import 'package:goapp/features/services/domain/repositories/services_repository.dart';

class FakeServicesRemoteDataSource implements ServicesRemoteDataSource {
  int calls = 0;
  List<ServiceItem> result = const [];

  @override
  Future<List<ServiceItem>> fetchServices() async {
    calls += 1;
    return result;
  }
}

void main() {
  test('repository delegates to remote datasource', () async {
    final remote = FakeServicesRemoteDataSource()
      ..result = const [
        ServiceItem(id: 'bike', name: 'Bike', iconKey: 'bike'),
      ];
    final ServicesRepository repository = ServicesRepositoryImpl(
      remoteDataSource: remote,
    );

    final items = await repository.getServices();

    expect(remote.calls, 1);
    expect(items.length, 1);
    expect(items.first.id, 'bike');
  });
}
