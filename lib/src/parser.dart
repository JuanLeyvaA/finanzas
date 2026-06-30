import 'dart:math' as math;

import 'models.dart';
import 'formatters.dart';

class MisFinParser {
  const MisFinParser();

  ParsedTransactionDraft parse(String rawText) {
    final normalized = rawText.trim();
    final lower = normalized.toLowerCase();
    final bank = _detectBank(lower);
    final amount = _detectAmount(normalized);
    final detectedCurrency = _detectCurrency(normalized, lower);
    final category = _detectCategory(lower);
    final merchant = _detectMerchant(normalized, lower);
    final blockedReason = _autoImportBlockedReason(lower);
    final recognized = amount != null || bank != null;
    final confidence = _confidenceScore(
      bank: bank,
      amount: amount,
      category: category,
      merchant: merchant,
      detectedCurrency: detectedCurrency,
      lower: lower,
      blockedReason: blockedReason,
    );

    final hint = blockedReason ??
        (recognized
            ? 'Detectamos ${amount == null ? 'un movimiento' : _formatMoney(amount, detectedCurrency)}${bank == null ? '' : ' en $bank'}.'
            : 'No pudimos identificar el gasto. Revisa el texto o agregalo manualmente.');

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
    final candidates = <({String name, List<RegExp> patterns})>[
      (
        name: 'Bancolombia',
        patterns: [
          RegExp(r'\bbancolombia\b'),
          RegExp(r'\b891333\b'),
          RegExp(r'\b891602\b'),
        ],
      ),
      (
        name: 'Nu',
        patterns: [
          RegExp(r'\bnu\b'),
        ],
      ),
      (
        name: 'Nequi',
        patterns: [
          RegExp(r'\bnequi\b'),
        ],
      ),
      (
        name: 'Davivienda',
        patterns: [
          RegExp(r'\bdavivienda\b'),
        ],
      ),
      (
        name: 'BBVA',
        patterns: [
          RegExp(r'\bbbva\b'),
        ],
      ),
      (
        name: 'Banco de Bogota',
        patterns: [
          RegExp(r'banco\s+de\s+bogota'),
          RegExp(r'\bbancobogota\b'),
        ],
      ),
      (
        name: 'Banco Popular',
        patterns: [
          RegExp(r'\bbanco\s+popular\b'),
        ],
      ),
      (
        name: 'Banco Caja Social',
        patterns: [
          RegExp(r'banco\s+caja\s+social'),
          RegExp(r'\bcajasocial\b'),
        ],
      ),
      (
        name: 'Scotiabank Colpatria',
        patterns: [
          RegExp(r'scotiabank'),
          RegExp(r'colpatria'),
        ],
      ),
      (
        name: 'Itau',
        patterns: [
          RegExp(r'\bitau\b'),
          RegExp(r'\bita[uú]\b'),
        ],
      ),
      (
        name: 'Lulo Bank',
        patterns: [
          RegExp(r'lulo\s+bank'),
          RegExp(r'\blulo\b'),
        ],
      ),
      (
        name: 'RappiPay',
        patterns: [
          RegExp(r'rappipay'),
          RegExp(r'rappi\s+pay'),
        ],
      ),
    ];

    for (final candidate in candidates) {
      if (candidate.patterns.any((pattern) => pattern.hasMatch(lower))) {
        return candidate.name;
      }
    }

    return null;
  }

  double? _detectAmount(String text) {
    final regex = RegExp(
      r'(?:(?:cop|usd|eur|us\$)\s*|\$\s*|€\s*)?(?:[0-9]{1,3}(?:[.,][0-9]{3})+(?:[.,][0-9]{2})?|[0-9]+(?:[.,][0-9]{2})?)',
      caseSensitive: false,
    );
    final startsLikeManualEntry =
        RegExp(r'^\s*[0-9][0-9.,]*\s+\D').hasMatch(text);
    ({double amount, int score})? best;

    for (final match in regex.allMatches(text)) {
      final token = (match.group(0) ?? '').trim();
      final amount = _parseMoney(token);
      if (amount == null || amount <= 0) {
        continue;
      }

      final leftStart = math.max(0, match.start - 42);
      final rightEnd = math.min(text.length, match.end + 42);
      final left = text.substring(leftStart, match.start).toLowerCase();
      final context = text.substring(leftStart, rightEnd).toLowerCase();
      var score = 0;

      if (match.start == 0 && match.end == text.trim().length) {
        score += 50;
      }
      if (match.start == 0 && startsLikeManualEntry) {
        score += 25;
      }

      if (RegExp(r'(?:cop|usd|eur|us\$|\$|€)', caseSensitive: false)
          .hasMatch(token)) {
        score += 50;
      }
      if (token.contains('.') || token.contains(',')) {
        score += 18;
      }
      if (_containsAny(context, [
        RegExp(r'\bcompra\b'),
        RegExp(r'\bpago\b'),
        RegExp(r'\bvalor\b'),
        RegExp(r'\bmonto\b'),
        RegExp(r'\bpor\b'),
        RegExp(r'\bretiro\b'),
        RegExp(r'\btransfer'),
        RegExp(r'\bconsumo\b'),
        RegExp(r'\bcargo\b'),
      ])) {
        score += 42;
      }
      if (amount >= 100) {
        score += 5;
      }
      if (RegExp(
        r'(?:tarjeta|cuenta|referencia|ref|codigo|clave|hora|fecha)(?:\s|[:*#-])*$',
      ).hasMatch(left)) {
        score -= 60;
      }

      if (score >= 20 && (best == null || score > best.score)) {
        best = (amount: amount, score: score);
      }
    }

    return best?.amount;
  }

  String _detectCategory(String lower) {
    if (_containsAny(lower, [
      RegExp(r'\bretiro\b'),
      RegExp(r'\batm\b'),
      RegExp(r'\bcajero\b'),
    ])) {
      return 'Retiro';
    }
    if (_containsAny(lower, [
      RegExp(r'\btransfer'),
      RegExp(r'\benvio\b'),
      RegExp(r'\bgiro\b'),
    ])) {
      return 'Transferencia';
    }
    if (_containsAny(lower, [
      RegExp(r'\bpse\b'),
      RegExp(r'\bfactura\b'),
      RegExp(r'\bservicio\b'),
      RegExp(r'\brecarga\b'),
    ])) {
      return 'Pago';
    }
    return 'Compra';
  }

  String _detectMerchant(String rawText, String lower) {
    final patterns = <RegExp>[
      RegExp(
        r'(?:compra|consumo|pago)(?:\s+(?:aprobado|autorizado))?\s+(?:en|a)\s+([a-z0-9& ._-]{3,40})',
        caseSensitive: false,
      ),
      RegExp(
        r'(?:establecimiento|comercio|tienda)\s*[:\-]\s*([a-z0-9& ._-]{3,40})',
        caseSensitive: false,
      ),
      RegExp(r'a favor de\s+([a-z0-9& ._-]{3,40})', caseSensitive: false),
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
    if (text.contains('€') ||
        lower.contains(' eur') ||
        lower.contains('euro')) {
      return AppCurrency.eur;
    }
    if (lower.contains('usd') ||
        lower.contains('us\$') ||
        lower.contains('dolar') ||
        lower.contains('dollar')) {
      return AppCurrency.usd;
    }
    if (lower.contains('cop') ||
        lower.contains('peso colombiano') ||
        lower.contains('pesos colombianos')) {
      return AppCurrency.cop;
    }
    return null;
  }

  int _confidenceScore({
    required String? bank,
    required double? amount,
    required String category,
    required String merchant,
    required AppCurrency? detectedCurrency,
    required String lower,
    required String? blockedReason,
  }) {
    var score = 0;

    if (amount != null) {
      score += 40;
    }
    if (bank != null) {
      score += 25;
    }
    if (merchant != 'Movimiento detectado') {
      score += 10;
    }
    if (merchant != 'Compra sin nombre' && merchant != 'Movimiento detectado') {
      score += 5;
    }
    if (_containsAny(lower, [
      RegExp(r'\bcompra\b'),
      RegExp(r'\bpago\b'),
      RegExp(r'\baprob'),
      RegExp(r'\bautoriz'),
      RegExp(r'\bretiro\b'),
      RegExp(r'\btransfer'),
      RegExp(r'\bmovimient'),
      RegExp(r'\bconsumo\b'),
      RegExp(r'\bcargo\b'),
      RegExp(r'\bdebito\b'),
    ])) {
      score += 15;
    }
    if (category != 'Compra') {
      score += 8;
    }
    if (detectedCurrency != null) {
      score += 5;
    }

    if (blockedReason != null) {
      return score.clamp(0, 35).toInt();
    }

    return score.clamp(0, 100).toInt();
  }

  String? _autoImportBlockedReason(String lower) {
    if (_containsAny(lower, [
      RegExp(r'\brechazad'),
      RegExp(r'\bdeclinad'),
      RegExp(r'\bfallid'),
      RegExp(r'\bno\s+(?:fue\s+)?(?:aprob|autoriz)'),
      RegExp(r'\banulad'),
      RegExp(r'\breversad'),
    ])) {
      return 'El movimiento parece rechazado, anulado o reversado; no lo guardamos como gasto.';
    }

    if (_containsAny(lower, [
      RegExp(r'\bhas recibido\b'),
      RegExp(r'\brecibiste\b'),
      RegExp(r'\bte (?:enviaron|consignaron|depositaron)\b'),
      RegExp(r'\btransferencia recibida\b'),
      RegExp(r'\bdinero recibido\b'),
      RegExp(r'\bdeposito recibido\b'),
      RegExp(r'\babono a (?:tu )?(?:cuenta|favor)\b'),
    ])) {
      return 'Este mensaje parece ser dinero recibido; no lo guardamos como gasto automaticamente.';
    }

    final hasExpenseSignal = _containsAny(lower, [
      RegExp(r'\bcompra\b'),
      RegExp(r'\bpago\b'),
      RegExp(r'\bretiro\b'),
      RegExp(r'\btransferencia enviada\b'),
      RegExp(r'\bconsumo\b'),
      RegExp(r'\bcargo\b'),
    ]);
    if (!hasExpenseSignal &&
        _containsAny(lower, [
          RegExp(r'\bcodigo de seguridad\b'),
          RegExp(r'\bclave dinamica\b'),
          RegExp(r'\bcodigo otp\b'),
          RegExp(r'\bsaldo disponible\b'),
          RegExp(r'\bextracto\b'),
        ])) {
      return 'Este mensaje parece informativo y no un gasto; lo dejamos sin registrar.';
    }

    return null;
  }

  bool _containsAny(String text, List<RegExp> patterns) {
    return patterns.any((pattern) => pattern.hasMatch(text));
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
