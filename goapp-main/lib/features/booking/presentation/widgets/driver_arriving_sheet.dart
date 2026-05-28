import 'package:flutter/material.dart';

import '../../domain/entities/driver_info.dart';

class DriverArrivingSheet extends StatelessWidget {
  final double distanceKm;
  final int etaMin;
  final int arrivedInMin;
  final bool hasArrived;
  final DriverInfo driver;
  final VoidCallback onCancel;
  final VoidCallback onCall;
  final VoidCallback onMessage;

  const DriverArrivingSheet({
    super.key,
    required this.distanceKm,
    required this.etaMin,
    required this.arrivedInMin,
    required this.hasArrived,
    required this.driver,
    required this.onCancel,
    required this.onCall,
    required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: DecoratedBox(
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    hasArrived ? 'Driver arrived' : 'Driver arriving',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (hasArrived) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7F6ED),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Arrived',
                        style: TextStyle(
                          color: Color(0xFF1B8E4B),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.black87,
                    child: Text(
                      driver.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driver.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${driver.vehicleModel} • ${driver.plateNumber}',
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      const Text(
                        'OTP',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        driver.otp,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (hasArrived)
                Text(
                  'Arrived in $arrivedInMin min',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ETA: $etaMin min'),
                    Text('${distanceKm.toStringAsFixed(1)} km away'),
                  ],
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onCall,
                      icon: const Icon(Icons.call),
                      label: const Text('Call'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onMessage,
                      icon: const Icon(Icons.message),
                      label: const Text('Message'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onCancel,
                  child: const Text('Cancel Ride'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
