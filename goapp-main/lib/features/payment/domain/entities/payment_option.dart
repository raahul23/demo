enum PaymentMethodType {
  upi,
  card,
  wallet,
  cash,
}

class PaymentOption {
  final String id;
  final PaymentMethodType type;
  final String title;
  final String subtitle;
  final bool isRecommended;

  const PaymentOption({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.isRecommended,
  });
}
