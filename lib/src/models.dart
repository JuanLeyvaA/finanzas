import 'month_utils.dart';
import 'app_identity.dart';

enum IncomeFrequency {
  weekly,
  biweekly,
  monthly;

  String get label {
    switch (this) {
      case IncomeFrequency.weekly:
        return 'Semanal';
      case IncomeFrequency.biweekly:
        return 'Quincenal';
      case IncomeFrequency.monthly:
        return 'Mensual';
    }
  }
}

enum AppCurrency {
  cop,
  usd,
  eur;

  String get label => switch (this) {
        AppCurrency.cop => 'Peso Colombiano',
        AppCurrency.usd => 'Dolar',
        AppCurrency.eur => 'Euro',
      };

  String get symbol => switch (this) {
        AppCurrency.cop => r'$',
        AppCurrency.usd => r'$',
        AppCurrency.eur => 'EUR',
      };

  String get shortLabel => switch (this) {
        AppCurrency.cop => 'COP',
        AppCurrency.usd => 'USD',
        AppCurrency.eur => 'EUR',
      };

  static AppCurrency fromName(String value) => switch (value) {
        'usd' => AppCurrency.usd,
        'eur' => AppCurrency.eur,
        _ => AppCurrency.cop,
      };
}

extension IncomeFrequencyX on IncomeFrequency {
  String get label => switch (this) {
        IncomeFrequency.weekly => 'Semanal',
        IncomeFrequency.biweekly => 'Quincenal',
        IncomeFrequency.monthly => 'Mensual',
      };

  String get gainsPrompt => switch (this) {
        IncomeFrequency.weekly => 'semanalmente',
        IncomeFrequency.biweekly => 'quincenalmente',
        IncomeFrequency.monthly => 'mensualmente',
      };

  double get monthlyMultiplier => switch (this) {
        IncomeFrequency.weekly => 4.0,
        IncomeFrequency.biweekly => 2.0,
        IncomeFrequency.monthly => 1.0,
      };

  static IncomeFrequency fromName(String value) => switch (value) {
        'weekly' => IncomeFrequency.weekly,
        'biweekly' => IncomeFrequency.biweekly,
        _ => IncomeFrequency.monthly,
      };
}

class BankProfile {
  const BankProfile({
    required this.name,
    required this.accent,
    required this.shortcutHint,
    required this.notificationHint,
    required this.officialHint,
  });

  final String name;
  final int accent;
  final String shortcutHint;
  final String notificationHint;
  final String officialHint;

  Map<String, Object?> toJson() => {
        'name': name,
        'accent': accent,
        'shortcutHint': shortcutHint,
        'notificationHint': notificationHint,
        'officialHint': officialHint,
      };

  factory BankProfile.fromJson(Map<String, dynamic> json) {
    return BankProfile(
      name: json['name'] as String,
      accent: json['accent'] as int,
      shortcutHint: json['shortcutHint'] as String,
      notificationHint: json['notificationHint'] as String,
      officialHint: json['officialHint'] as String,
    );
  }
}

const List<BankProfile> bankCatalog = [
  BankProfile(
    name: 'Bancolombia',
    accent: 0xFFF5B700,
    shortcutHint: 'SMS y notificaciones de compra',
    notificationHint: 'Atajo iOS recomendado para mensajes y push',
    officialHint: 'Cobertura parcial en SMS; mejor combinar con Atajos',
  ),
  BankProfile(
    name: 'Nu',
    accent: 0xFF6A1BFF,
    shortcutHint: 'Notificaciones push',
    notificationHint: 'Atajo iOS para texto de notificacion',
    officialHint: 'Muy bueno para automatizacion con notificaciones',
  ),
  BankProfile(
    name: 'Nequi',
    accent: 0xFFEF6A00,
    shortcutHint: 'Notificaciones push',
    notificationHint: 'Atajo iOS para texto de notificacion',
    officialHint: 'Ideal para un flujo semi-automatico en iPhone',
  ),
  BankProfile(
    name: 'Davivienda',
    accent: 0xFFE53935,
    shortcutHint: 'Push y texto compartido',
    notificationHint: 'Atajo iOS para mensajes de la app',
    officialHint: 'Funciona bien con el flujo de compartir texto',
  ),
];

class PresuCoProfile {
  const PresuCoProfile({
    required this.name,
    required this.onboardingComplete,
    required this.currency,
    required this.frequency,
    required this.incomePerPeriod,
    required this.monthlySavingsGoal,
    required this.selectedBanks,
  });

  final String name;
  final bool onboardingComplete;
  final AppCurrency currency;
  final IncomeFrequency frequency;
  final double incomePerPeriod;
  final double monthlySavingsGoal;
  final List<String> selectedBanks;

  factory PresuCoProfile.defaults() {
    return const PresuCoProfile(
      name: fixedUserName,
      onboardingComplete: false,
      currency: AppCurrency.cop,
      frequency: IncomeFrequency.monthly,
      incomePerPeriod: 0,
      monthlySavingsGoal: 0,
      selectedBanks: ['Bancolombia', 'Nu', 'Nequi', 'Davivienda'],
    );
  }

  double get monthlyIncome => incomePerPeriod * frequency.monthlyMultiplier;
  double get monthlyBudget =>
      (monthlyIncome - monthlySavingsGoal).clamp(0, double.infinity).toDouble();

  PresuCoProfile copyWith({
    String? name,
    bool? onboardingComplete,
    AppCurrency? currency,
    IncomeFrequency? frequency,
    double? incomePerPeriod,
    double? monthlySavingsGoal,
    List<String>? selectedBanks,
  }) {
    return PresuCoProfile(
      name: name ?? this.name,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      currency: currency ?? this.currency,
      frequency: frequency ?? this.frequency,
      incomePerPeriod: incomePerPeriod ?? this.incomePerPeriod,
      monthlySavingsGoal: monthlySavingsGoal ?? this.monthlySavingsGoal,
      selectedBanks: selectedBanks ?? this.selectedBanks,
    );
  }

  Map<String, Object?> toJson() => {
        'name': name,
        'onboardingComplete': onboardingComplete,
        'currency': currency.name,
        'frequency': frequency.name,
        'incomePerPeriod': incomePerPeriod,
        'monthlySavingsGoal': monthlySavingsGoal,
        'selectedBanks': selectedBanks,
      };

  factory PresuCoProfile.fromJson(Map<String, dynamic> json) {
    return PresuCoProfile(
      name: fixedUserName,
      onboardingComplete: (json['onboardingComplete'] as bool?) ?? false,
      currency: AppCurrency.fromName((json['currency'] as String?) ?? 'cop'),
      frequency: IncomeFrequencyX.fromName((json['frequency'] as String?) ?? 'monthly'),
      incomePerPeriod: (json['incomePerPeriod'] as num?)?.toDouble() ?? 0,
      monthlySavingsGoal: (json['monthlySavingsGoal'] as num?)?.toDouble() ?? 0,
      selectedBanks: (json['selectedBanks'] as List<dynamic>?)
              ?.map((value) => value.toString())
              .toList() ??
          const ['Bancolombia', 'Nu', 'Nequi', 'Davivienda'],
    );
  }
}

class ExpenseEntry {
  const ExpenseEntry({
    required this.id,
    required this.amount,
    required this.note,
    required this.createdAt,
    required this.monthKey,
    required this.source,
    required this.category,
    this.bank,
    this.rawText,
  });

  final String id;
  final double amount;
  final String note;
  final DateTime createdAt;
  final String monthKey;
  final String source;
  final String category;
  final String? bank;
  final String? rawText;

  Map<String, Object?> toJson() => {
        'id': id,
        'amount': amount,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
        'monthKey': monthKey,
        'source': source,
        'category': category,
        'bank': bank,
        'rawText': rawText,
      };

  factory ExpenseEntry.fromJson(Map<String, dynamic> json) {
    return ExpenseEntry(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      note: json['note'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      monthKey: (json['monthKey'] as String?) ?? monthKeyOf(DateTime.parse(json['createdAt'] as String)),
      source: json['source'] as String,
      category: json['category'] as String,
      bank: json['bank'] as String?,
      rawText: json['rawText'] as String?,
    );
  }
}

class MonthlySummary {
  const MonthlySummary({
    required this.monthKey,
    required this.name,
    required this.year,
    required this.income,
    required this.savingsGoal,
    required this.budget,
    required this.spent,
    required this.expenseCount,
    required this.lastUpdated,
  });

  final String monthKey;
  final String name;
  final int year;
  final double income;
  final double savingsGoal;
  final double budget;
  final double spent;
  final int expenseCount;
  final DateTime lastUpdated;

  double get remaining => budget - spent;
  double get progress => budget == 0 ? 0 : spent / budget;
  bool get overBudget => budget > 0 && spent >= budget;
  bool get nearBudget => budget > 0 && spent >= budget * 0.8 && spent < budget;

  Map<String, Object?> toJson() => {
        'monthKey': monthKey,
        'name': name,
        'year': year,
        'income': income,
        'savingsGoal': savingsGoal,
        'budget': budget,
        'spent': spent,
        'expenseCount': expenseCount,
        'lastUpdated': lastUpdated.toIso8601String(),
      };

  factory MonthlySummary.fromJson(Map<String, dynamic> json) {
    return MonthlySummary(
      monthKey: json['monthKey'] as String,
      name: json['name'] as String,
      year: json['year'] as int,
      income: (json['income'] as num).toDouble(),
      savingsGoal: (json['savingsGoal'] as num).toDouble(),
      budget: (json['budget'] as num).toDouble(),
      spent: (json['spent'] as num).toDouble(),
      expenseCount: (json['expenseCount'] as int?) ?? 0,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  MonthlySummary copyWith({
    double? income,
    double? savingsGoal,
    double? budget,
    double? spent,
    int? expenseCount,
    DateTime? lastUpdated,
  }) {
    return MonthlySummary(
      monthKey: monthKey,
      name: name,
      year: year,
      income: income ?? this.income,
      savingsGoal: savingsGoal ?? this.savingsGoal,
      budget: budget ?? this.budget,
      spent: spent ?? this.spent,
      expenseCount: expenseCount ?? this.expenseCount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  factory MonthlySummary.fromExpenses({
    required String monthKey,
    required List<ExpenseEntry> expenses,
    required PresuCoProfile profile,
  }) {
    final parsedDate = DateTime.parse('$monthKey-01');
    final spent = expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
    return MonthlySummary(
      monthKey: monthKey,
      name: monthLabelOf(monthKey),
      year: parsedDate.year,
      income: profile.monthlyIncome,
      savingsGoal: profile.monthlySavingsGoal,
      budget: profile.monthlyBudget,
      spent: spent,
      expenseCount: expenses.length,
      lastUpdated: DateTime.now(),
    );
  }
}

class ParsedTransactionDraft {
  const ParsedTransactionDraft({
    required this.recognized,
    required this.bank,
    required this.amount,
    required this.detectedCurrency,
    required this.category,
    required this.note,
    required this.rawText,
    required this.hint,
    required this.confidence,
  });

  final bool recognized;
  final String? bank;
  final double? amount;
  final AppCurrency? detectedCurrency;
  final String category;
  final String note;
  final String rawText;
  final String hint;
  final int confidence;

  bool get canAutoImport => amount != null && confidence >= 65;
  bool hasCurrencyMismatch(AppCurrency activeCurrency) =>
      detectedCurrency != null && detectedCurrency != activeCurrency;
  String get confidenceLabel => confidence >= 80
      ? 'Muy alta'
      : confidence >= 65
          ? 'Alta'
          : confidence >= 45
              ? 'Media'
              : 'Baja';
}
