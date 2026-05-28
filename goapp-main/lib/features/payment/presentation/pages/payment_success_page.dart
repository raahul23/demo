import 'package:flutter/material.dart';
import 'trip_receipt_screen.dart';

enum PaymentSource { tips, payment }

class PaymentSuccessPage extends StatelessWidget {
  final PaymentSource source;
  final VoidCallback? onDone;
  final WidgetBuilder? doneRouteBuilder;
  final String doneLabel;

  const PaymentSuccessPage({
    super.key,
    required this.source,
    this.onDone,
    this.doneRouteBuilder,
    this.doneLabel = 'Back to Home',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
            const SizedBox(height: 32),
            // Top Success Section
            Center(
              child: Column(
                children: [
                  _SuccessIcon(source: source),
                  const SizedBox(height: 12),
                  const Text(
                    'Payment Successful',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Amount Received',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Alexander has been notified of your\ngenerous tip.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Details Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _RoundedCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildDetailsRows(),
                    const SizedBox(height: 24),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFEEEEEE),
                    ),
                    const SizedBox(height: 24),
                    _TotalRow(
                      amount: source == PaymentSource.tips
                          ? '₹47.00'
                          : '₹895.00',
                    ),
                    const SizedBox(height: 24),
                    const _DriverInfoRow(),
                  ],
                ),
              ),
            ),

            // Bottom Section
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TripReceiptScreen(
                      data: TripReceiptUIModel(
                        invoiceNo: '#LX-IN-99281',
                        date: 'Oct 14, 2024',
                        vehicle: 'Black Lux Sedan',
                        tripId: 'in-82-j9p1-m12',
                        duration: '54 Minutes',
                        pickupAddress: '123 Main Street, Downtown',
                        dropAddress: 'VR Mall Anna Nagar, Ch-92',
                        fareItems: [
                          FareItem(label: 'Distance', value: '4.2km'),
                          FareItem(label: 'Base Fare', value: '₹40.00'),
                          FareItem(label: 'GST', value: '₹7.00'),
                          FareItem(
                            label: 'Total',
                            value: '₹47.00',
                            isTotal: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              child: const Text(
                'View Receipt',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: onDone ??
                      () {
                        if (doneRouteBuilder != null) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: doneRouteBuilder!),
                          );
                          return;
                        }
                        Navigator.of(context).maybePop();
                      },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A86B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    doneLabel,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsRows() {
    if (source == PaymentSource.tips) {
      // Mode 1: From Tips Page
      return Column(
        children: const [
          _DetailRow(label: 'Trip Fare', amount: '₹52.00'),
          SizedBox(height: 16),
          _DetailRow(label: 'Discount 10%', amount: '-₹5.00'),
        ],
      );
    } else {
      // Mode 2: From Payment Method Page
      return Column(
        children: const [
          _DetailRow(label: 'Trip Fare', amount: '₹845.00'),
          SizedBox(height: 16),
          _DetailRow(label: 'Tips', amount: '₹50.00'),
        ],
      );
    }
  }
}

// --- Local Widgets ---

class _SuccessIcon extends StatelessWidget {
  final PaymentSource source;

  const _SuccessIcon({required this.source});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          color: Color(0xFF00A86B), // Green check circle background
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 32),
      ),
    );
  }
}

class _RoundedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const _RoundedCard({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: padding != null
            ? Padding(padding: padding!, child: child)
            : child,
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String amount;

  const _DetailRow({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        Text(
          amount,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String amount;

  const _TotalRow({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Total Charged',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500, // Reduced from bold
            color: Colors.black,
          ),
        ),
        Text(
          amount,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500, // Reduced from bold matches image
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

class _DriverInfoRow extends StatelessWidget {
  const _DriverInfoRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ImagePlaceholder(width: 40, height: 40),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Sam Yogi',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Premier Class Chauffeur',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final double width;
  final double height;

  const _ImagePlaceholder({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        shape: BoxShape.circle,
      ),
      // Placeholder for Avatar
    );
  }
}
