import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/entities/booking_service.dart';

class DriverSearchSheet extends StatefulWidget {
  final VoidCallback? onCancel;
  final BookingService? service;

  const DriverSearchSheet({
    super.key,
    this.onCancel,
    this.service,
  });

  @override
  State<DriverSearchSheet> createState() => _DriverSearchSheetState();
}

class _DriverSearchSheetState extends State<DriverSearchSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();

  late final Animation<double> _pulse = Tween<double>(begin: 0.9, end: 1.05)
      .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _dotOpacity(int index) {
    final t = (_controller.value + index * 0.2) % 1.0;
    final wave = (math.sin(t * math.pi * 2) + 1) / 2;
    return 0.3 + wave * 0.7;
  }

  IconData _iconForService(BookingService? service) {
    switch (service) {
      case BookingService.auto:
        return Icons.electric_rickshaw;
      case BookingService.car:
        return Icons.directions_car;
      case BookingService.bike:
      default:
        return Icons.directions_bike;
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconData = _iconForService(widget.service);
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ScaleTransition(
              scale: _pulse,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(36),
                ),
                child: Icon(
                  iconData,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Searching for a driver',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Hang tight, we are finding the best match nearby.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return AnimatedOpacity(
                      opacity: _dotOpacity(index),
                      duration: const Duration(milliseconds: 150),
                      child: Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: widget.onCancel ?? () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
