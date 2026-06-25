import 'models.dart';
import 'formatters.dart';

class PresuCoParser {
  const PresuCoParser();

  ParsedTransactionDraft parse(String rawText) {
    final normalized = rawText.trim();
    final lower = normalized.toLowerCase();
    final bank = _detectBank(lower);
    final amount = _detectAmount(normalized);
    final detectedCurrency = _detectCurrency(normalized, lower);
    final category = _detectCategory(lower);
    final merchant = _detectMerchant(normalized, lower);
    final recognized = amount != null || bank != null;
    final confidence = _confidenceScore(
      bank: bank,
      amount: amount,
      category: category,
      merchant: merchant,
      lower: lower,
    );

    final hint = recognized
        ? 'Detectamos ${amount == null ? 'un movimiento' : _formatMoney(amount, detectedCurrency)}${bank == null ? '' : ' en $bank'}.'
        : 'No pudimos identificar el gasto. Revisa el texto o agrégalo manualmente.';

    return ParsedTransactionDraft(
      recognized: recognized,
      bank: bank,
      amount: amount,
      detectedCurrency: detectedCurrency,
      category: category,
      note: merchant,
      rawText: normalized,
      hint: hint,
      confidence: confidence,
    );
  }

  String? _detectBank(String lower) {
    if (lower.contains('bancolombia') || lower.contains('891333') || lower.contains('891602')) {
      return 'Bancolombia';
    }
    if (lower.contains('nu')) return 'Nu';
    if (lower.contains('nequi')) return 'Nequi';
    if (lower.contains('davivienda')) return 'Davivienda';
    return null;
  }

  double? _detectAmount(String text) {
    final regex = RegExp(
      r'(?:(?:cop|usd|eur|us\$|€)\s*)?(\$?\s*[0-9]{1,3}(?:[.,][0-9]{3})+(?:[.,][0-9]{2})?|\$?\s*[0-9]+(?:[.,][0-9]{2})?)',
      caseSensitive: false,
    );
    final match = regex.firstMatch(text);
    if (match == null) {
      return null;
    }

    final candidate = match.group(1) ?? '';
    return _parseMoney(candidate);
  }

  String _detectCategory(String lower) {
    if (lower.contains('retiro') || lower.contains('atm') || lower.contains('cajero')) {
      return 'Retiro';
    }
    if (lower.contains('transfer') || lower.contains('envio')) {
      return 'Transferencia';
    }
    return 'Compra';
  }

  String _detectMerchant(String rawText, String lower) {
    final patterns = <RegExp>[
      RegExp(r'(?:compra en|en|de|a favor de)\s+([a-z0-9& ._-]{3,40})', caseSensitive: false),
      RegExp(r'por\s+([a-z0-9& ._-]{3,40})', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(rawText);
      if (match != null) {
        final value = (match.group(1) ?? '').trim();
        if (value.isNotEmpty) {
          return _cleanupMerchant(value);
        }
      }
    }

    if (lower.contains('compra')) return 'Compra sin nombre';
    return 'Movimiento detectado';
  }

  String _cleanupMerchant(String value) {
    return value
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[.,;:]+$'), '')
        .trim();
  }

  String _formatMoney(double? amount, AppCurrency? currency) {
    if (amount == null) {
      return 'un movimiento';
    }
    return formatMoney(amount, currency ?? AppCurrency.cop);
  }

  AppCurrency? _detectCurrency(String text, String lower) {
    if (text.contains('€') || lower.contains(' eur') || lower.contains('euro')) {
      return AppCurrency.eur;
    }
    if (lower.contains('usd') || lower.contains('us\$') || lower.contains('dolar') || lower.contains('dollar')) {
      return AppCurrency.usd;
    }
    if (lower.contains('cop') || lower.contains('peso colombiano') || lower.contains('pesos colombianos')) {
      return AppCurrency.cop;
    }
    return null;
  }

  int _confidenceScore({
    required String? bank,
    required double? amount,
    required String category,
    required String merchant,
    required String lower,
  }) {
    var score = 0;

    if (amount != null) {
      score += 40;
    }
    if (bank != null) {
      score += 25;
    }
    if (merchant != 'Movimiento detectado') {
      score += 15;
    }
    if (merchant != 'Compra sin nombre' && merchant != 'Movimiento detectado') {
      score += 5;
    }
    if (lower.contains('compra') || lower.contains('pago') || lower.contains('aprob') || lower.contains('retiro')) {
      score += 10;
    }
    if (category != 'Compra') {
      score += 5;
    }

    return score.clamp(0, 100).toInt();
  }

  double? _parseMoney(String input) {
    var cleaned = input.replaceAll(RegExp(r'[^0-9,.\-]'), '');
    if (cleaned.isEmpty) {
      return null;
    }

    if (cleaned.contains(',') && cleaned.contains('.')) {
      final lastComma = cleaned.lastIndexOf(',');
      final lastDot = cleaned.lastIndexOf('.');
      if (lastComma > lastDot) {
        cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
      } else {
        cleaned = cleaned.replaceAll(',', '');
      }
    } else if (cleaned.contains(',')) {
      final parts = cleaned.split(',');
      if (parts.length == 2 && parts[1].length <= 2) {
        cleaned = parts.join('.');
      } else {
        cleaned = cleaned.replaceAll(',', '');
      }
    } else if (cleaned.contains('.')) {
      final parts = cleaned.split('.');
      if (parts.length == 2 && parts[1].length <= 2) {
        cleaned = parts.join('.');
      } else {
        cleaned = cleaned.replaceAll('.', '');
      }
    }

    return double.tryParse(cleaned);
  }
}
