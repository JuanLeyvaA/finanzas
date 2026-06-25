const List<String> _monthNames = [
  'Enero',
  'Febrero',
  'Marzo',
  'Abril',
  'Mayo',
  'Junio',
  'Julio',
  'Agosto',
  'Septiembre',
  'Octubre',
  'Noviembre',
  'Diciembre',
];

String monthKeyOf(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$year-$month';
}

String monthLabelOf(String monthKey) {
  final parts = monthKey.split('-');
  if (parts.length != 2) {
    return monthKey;
  }

  final year = int.tryParse(parts[0]) ?? DateTime.now().year;
  final month = int.tryParse(parts[1]) ?? DateTime.now().month;
  final safeMonth = month.clamp(1, 12).toInt();
  return '${_monthNames[safeMonth - 1]} $year';
}

String monthShortLabelOf(String monthKey) {
  final parts = monthKey.split('-');
  if (parts.length != 2) {
    return monthKey;
  }

  final month = int.tryParse(parts[1]) ?? DateTime.now().month;
  final safeMonth = month.clamp(1, 12).toInt();
  return _monthNames[safeMonth - 1].substring(0, 3);
}
