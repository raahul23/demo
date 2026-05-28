import 'package:flutter_test/flutter_test.dart';

import 'package:goapp/features/services/domain/entities/service_item.dart';
import 'package:goapp/features/services/domain/repositories/services_repository.dart';
import 'package:goapp/features/services/domain/usecases/get_services_usecase.dart';

class FakeServicesRepository implements ServicesRepository {
  List<ServiceItem> result = const [];

  @override
  Future<List<ServiceItem>> getServices() async => result;
}

void main() {
  test('usecase returns repository services', () async {
    final repo = FakeServicesRepository()
      ..result = const [
        ServiceItem(id: 'auto', name: 'Auto', iconKey: 'auto'),
      ];
    final usecase = GetServicesUseCase(repo);

    final items = await usecase();

    expect(items.length, 1);
    expect(items.first.id, 'auto');
  });
}
