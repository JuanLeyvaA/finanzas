import 'models.dart';

String formatMoney(num value, AppCurrency currency) {
  final digits = value.round().abs().toString();
  final groups = <String>[];
  for (var end = digits.length; end > 0; end -= 3) {
    final start = (end - 3).clamp(0, digits.length).toInt();
    groups.add(digits.substring(start, end));
  }

  final grouped = groups.reversed.join('.');
  final prefix = value < 0 ? '-' : '';
  final symbol = switch (currency) {
    AppCurrency.cop => r'$',
    AppCurrency.usd => 'USD ',
    AppCurrency.eur => 'EUR ',
  };

  return '$prefix$symbol$grouped';
}

String formatCop(num value) {
  return formatMoney(value, AppCurrency.cop);
}
