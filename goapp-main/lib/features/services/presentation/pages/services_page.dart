import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/service_item.dart';
import '../cubit/services_cubit.dart';
import '../cubit/services_state.dart';
import '../utils/service_icon_mapper.dart';
import '../../../activity/presentation/widgets/appbar.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(
        title: 'Services',
        showBack: false,
      ),
      body: BlocBuilder<ServicesCubit, ServicesState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.errorMessage!),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => context.read<ServicesCubit>().load(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state.items.isEmpty) {
            return const Center(child: Text('No services available'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = state.items[index];
              return _ServiceCard(item: item);
            },
          );
        },
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.item});

  final ServiceItem item;

  @override
  Widget build(BuildContext context) {
    final icon = ServiceIconMapper.fromKey(item.iconKey);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            color: Color(0x14000000),
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha:0.12),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(item.name),
        subtitle: item.description == null ? null : Text(item.description!),
        trailing: item.featured
            ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha:0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Popular',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
