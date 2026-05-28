import 'package:flutter/material.dart';

class NotificationPermissionSheet extends StatelessWidget {
  final VoidCallback onAllow;

  const NotificationPermissionSheet({
    super.key,
    required this.onAllow,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enable notifications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'We use notifications to share driver updates, arrival alerts, and ride status.',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onAllow,
                    child: const Text('Allow'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
