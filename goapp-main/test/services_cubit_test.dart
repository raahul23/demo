import 'package:flutter_test/flutter_test.dart';

import 'package:goapp/features/services/domain/entities/service_item.dart';
import 'package:goapp/features/services/domain/repositories/services_repository.dart';
import 'package:goapp/features/services/domain/usecases/get_services_usecase.dart';
import 'package:goapp/features/services/presentation/cubit/services_cubit.dart';

class FakeServicesRepository implements ServicesRepository {
  List<ServiceItem> result = const [];
  bool shouldThrow = false;

  @override
  Future<List<ServiceItem>> getServices() async {
    if (shouldThrow) throw Exception('boom');
    return result;
  }
}

void main() {
  test('load emits services list', () async {
    final repo = FakeServicesRepository()
      ..result = const [
        ServiceItem(id: 'car', name: 'Car', iconKey: 'car'),
      ];
    final usecase = GetServicesUseCase(repo);
    final cubit = ServicesCubit(usecase);

    await cubit.load();

    expect(cubit.state.loading, false);
    expect(cubit.state.items.length, 1);
    expect(cubit.state.items.first.id, 'car');
  });

  test('load emits error message on failure', () async {
    final repo = FakeServicesRepository()..shouldThrow = true;
    final usecase = GetServicesUseCase(repo);
    final cubit = ServicesCubit(usecase);

    await cubit.load();

    expect(cubit.state.loading, false);
    expect(cubit.state.items, isEmpty);
    expect(cubit.state.errorMessage, isNotNull);
  });
}
