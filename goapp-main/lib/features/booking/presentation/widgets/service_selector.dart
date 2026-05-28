import 'package:flutter/material.dart';

import '../../domain/entities/booking_service.dart';

class ServiceSelector extends StatelessWidget {
  const ServiceSelector({
    super.key,
    required this.selectedService,
    required this.prices,
    required this.onSelected,
  });

  final BookingService? selectedService;
  final Map<BookingService, double> prices;
  final ValueChanged<BookingService> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Service',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        _ServiceTile(
          service: BookingService.bike,
          label: 'Bike',
          icon: Icons.two_wheeler,
          price: prices[BookingService.bike] ?? 0,
          selected: selectedService == BookingService.bike,
          onTap: () => onSelected(BookingService.bike),
        ),
        const SizedBox(height: 8),
        _ServiceTile(
          service: BookingService.auto,
          label: 'Auto',
          icon: Icons.electric_rickshaw,
          price: prices[BookingService.auto] ?? 0,
          selected: selectedService == BookingService.auto,
          onTap: () => onSelected(BookingService.auto),
        ),
        const SizedBox(height: 8),
        _ServiceTile(
          service: BookingService.car,
          label: 'Car',
          icon: Icons.directions_car,
          price: prices[BookingService.car] ?? 0,
          selected: selectedService == BookingService.car,
          onTap: () => onSelected(BookingService.car),
        ),
      ],
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({
    required this.service,
    required this.label,
    required this.icon,
    required this.price,
    required this.selected,
    required this.onTap,
  });

  final BookingService service;
  final String label;
  final IconData icon;
  final double price;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEFF2FF) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? Colors.black87 : const Color(0xFFE0E0E0),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            Text('Rs ${price.toStringAsFixed(0)}'),
            const SizedBox(width: 8),
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
