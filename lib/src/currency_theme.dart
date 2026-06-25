import 'package:flutter/material.dart';

import 'models.dart';

class CurrencyPalette {
  const CurrencyPalette({
    required this.seed,
    required this.scaffold,
    required this.accent,
    required this.secondary,
    required this.tertiary,
    required this.surface,
  });

  final Color seed;
  final Color scaffold;
  final Color accent;
  final Color secondary;
  final Color tertiary;
  final Color surface;
}

CurrencyPalette paletteForCurrency(AppCurrency currency) {
  return switch (currency) {
    AppCurrency.cop => const CurrencyPalette(
        seed: Color(0xFF7B42D8),
        scaffold: Color(0xFF120814),
        accent: Color(0xFFB26BFF),
        secondary: Color(0xFFFF71C6),
        tertiary: Color(0xFF7ED8FF),
        surface: Color(0xFF201126),
      ),
    AppCurrency.usd => const CurrencyPalette(
        seed: Color(0xFF7449F5),
        scaffold: Color(0xFF100814),
        accent: Color(0xFF8F79FF),
        secondary: Color(0xFF4FC3FF),
        tertiary: Color(0xFFFF8BD8),
        surface: Color(0xFF1C1124),
      ),
    AppCurrency.eur => const CurrencyPalette(
        seed: Color(0xFF6C37D7),
        scaffold: Color(0xFF140818),
        accent: Color(0xFFC66CFF),
        secondary: Color(0xFFFF9E63),
        tertiary: Color(0xFF7FE2D8),
        surface: Color(0xFF23122A),
      ),
  };
}
