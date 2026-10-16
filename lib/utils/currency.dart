/// Formats an amount as Kenyan Shillings, e.g. 2450 -> "2,450 KES".
String formatToKES(double amount, {String symbol = 'KES'}) {
  // Bulatkan ke shilling terdekat (KES tidak memakai desimal).
  final String formattedAmount = amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (Match match) => '${match.group(1)},',
      );

  return '$formattedAmount $symbol';
}

double calculateDiscountedPrice({
  required double originalPrice,
  required double discountPercentage,
}) {
  if (discountPercentage < 0 || discountPercentage > 100) {
    throw ArgumentError('Discount percentage must be between 0 and 100');
  }
  return originalPrice - (originalPrice * (discountPercentage / 100));
}
