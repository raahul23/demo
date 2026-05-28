import 'package:flutter/material.dart';

import '../../domain/entities/driver_info.dart';

class RideInProgressSheet extends StatelessWidget {
  final DriverInfo driver;
  final String pickupLabel;
  final String dropLabel;
  final VoidCallback onEmergency;
  final VoidCallback onSos;
  final VoidCallback onHelp;

  const RideInProgressSheet({
    super.key,
    required this.driver,
    required this.pickupLabel,
    required this.dropLabel,
    required this.onEmergency,
    required this.onSos,
    required this.onHelp,
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
              const Text(
                'Ride started',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              const Text(
                'Happy, safe and secure ride.',
                style: TextStyle(color: Colors.black54),
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
              const SizedBox(height: 16),
              _AddressRow(
                label: 'Pickup',
                value: pickupLabel,
                color: const Color(0xFF1B8E4B),
              ),
              const SizedBox(height: 8),
              _AddressRow(
                label: 'Drop',
                value: dropLabel,
                color: const Color(0xFFB42318),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onEmergency,
                      icon: const Icon(Icons.warning_amber),
                      label: const Text('Emergency'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onSos,
                      icon: const Icon(Icons.sos),
                      label: const Text('SOS'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onHelp,
                  child: const Text('Help'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddressRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _AddressRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
