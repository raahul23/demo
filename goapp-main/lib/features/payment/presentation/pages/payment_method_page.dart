import 'package:flutter/material.dart';
import 'payment_success_page.dart';

class PaymentMethodPage extends StatelessWidget {
  const PaymentMethodPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Payment Methods',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.black, // back icon color
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1 — UPI Payments
            const _SectionHeader(title: 'UPI Payments'),
            const SizedBox(height: 12),
            _RoundedCard(
              child: ListTile(
                onTap: () => _navigateToSuccess(context),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                leading: const _ImagePlaceholder(
                  imagePath: 'assets/images/payment/smartphone.png',
                  iconColor: Color(0xFF9C27B0), // Purple for wallet icon
                ),
                title: const Text(
                  'GoApp Wallet',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                subtitle: const Text(
                  'GoApp Balance : 500',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 2 — Saved Cards (UPI Apps in disguise)
            const _SectionHeader(
              title: 'Saved Cards',
            ), // Following image exactly
            const SizedBox(height: 12),
            _RoundedCard(
              child: Column(
                children: [
                  _ListTileItem(
                    title: 'Google Pay',
                    subtitle: 'Directly from bank account',
                    imagePath: 'assets/images/payment/google_pay.png',
                    iconColor: const Color(0xFF1976D2), // Blue
                    onTap: () => _navigateToSuccess(context),
                  ),
                  const Divider(
                    height: 1,
                    indent: 72,
                    color: Color(0xFFF1F1F1),
                  ),
                  _ListTileItem(
                    title: 'PhonePe',
                    subtitle: 'Fast and secure UPI',
                    imagePath: 'assets/images/payment/smartphone.png',
                    iconColor: const Color(0xFF9C27B0), // Purple
                    onTap: () => _navigateToSuccess(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 3 — Saved Cards (Real Cards)
            const _SectionHeader(title: 'Saved Cards'),
            const SizedBox(height: 12),
            _RoundedCard(
              child: Column(
                children: [
                  _ListTileItem(
                    title: 'Visa •••• 1122',
                    subtitle: 'Expires 09/27',
                    imagePath: 'assets/images/payment/visa.png',
                    iconColor: const Color(0xFF0D47A1), // Visa Blue
                    onTap: () => _navigateToSuccess(context),
                  ),
                  const Divider(
                    height: 1,
                    indent: 72,
                    color: Color(0xFFF1F1F1),
                  ),
                  _ListTileItem(
                    title: 'Mastercard •••• 4455',
                    subtitle: 'Expires 12/25',
                    imagePath: 'assets/images/payment/mastercard.png',
                    iconColor: const Color(0xFFF44336), // Mastercard Red
                    onTap: () => _navigateToSuccess(context),
                  ),
                  const Divider(
                    height: 1,
                    indent: 72,
                    color: Color(0xFFF1F1F1),
                  ),
                  // Add New Card
                  ListTile(
                    onTap: () {
                      // Add new card logic
                    },
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: const SizedBox(
                      width: 48,
                      height: 48,
                      child: Icon(
                        Icons.add_circle,
                        color: Color(0xFF0D47A1),
                        size: 28,
                      ),
                    ),
                    title: const Text(
                      'Add New Card',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 4 — Net Banking
            const _SectionHeader(title: 'Net Banking'),
            const SizedBox(height: 12),
            _RoundedCard(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      _BankGridItem(name: 'HDFC Bank', acronym: 'HDFC'),
                      _BankGridItem(name: 'ICICI Bank', acronym: 'ICICI'),
                      _BankGridItem(name: 'SBI Bank', acronym: 'SBI'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Center(
                    child: Text(
                      'View All Banks',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _navigateToSuccess(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const PaymentSuccessPage(source: PaymentSource.payment),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
        letterSpacing: 0.2,
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
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 5),
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

class _ListTileItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final Color iconColor;
  final VoidCallback? onTap;

  const _ListTileItem({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: _ImagePlaceholder(imagePath: imagePath, iconColor: iconColor),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: Colors.black87,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          subtitle,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final String imagePath;
  final Color iconColor;

  const _ImagePlaceholder({required this.imagePath, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
        color:
            iconColor, // Tinting the icon if needed, or removing color if png has color
        errorBuilder: (context, error, stackTrace) {
          return Icon(_getFallbackIcon(), color: iconColor, size: 24);
        },
      ),
    );
  }

  IconData _getFallbackIcon() {
    if (imagePath.contains('smartphone')) return Icons.smartphone;
    if (imagePath.contains('google_pay')) return Icons.account_balance_wallet;
    if (imagePath.contains('visa') || imagePath.contains('mastercard')) {
      return Icons.credit_card;
    }
    return Icons.payment;
  }
}

class _BankGridItem extends StatelessWidget {
  final String name;
  final String acronym;

  const _BankGridItem({required this.name, required this.acronym});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFF1F1F1)),
          ),
          child: Text(
            acronym,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
