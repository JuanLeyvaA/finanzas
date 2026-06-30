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

const List<String> defaultSelectedBankNames = [
  'Bancolombia',
  'Nu',
  'Nequi',
  'Davivienda',
  'BBVA',
  'Banco de Bogota',
  'Banco Popular',
  'Banco Caja Social',
  'Scotiabank Colpatria',
  'Itau',
  'Lulo Bank',
  'RappiPay',
];

const List<BankProfile> bankCatalog = [
  BankProfile(
    name: 'Bancolombia',
    accent: 0xFFF5B700,
    shortcutHint: 'Muy util para compras del dia a dia.',
    notificationHint:
        'Si llega un aviso de compra, la app intenta leerlo sola.',
    officialHint: 'Si algo no coincide, lo revisas en segundos.',
  ),
  BankProfile(
    name: 'Nu',
    accent: 0xFF6A1BFF,
    shortcutHint: 'Ideal para seguir pagos rapidos y sin enredos.',
    notificationHint:
        'Si aparece un movimiento, MisFin lo puede registrar casi sola.',
    officialHint: 'Si dudas del valor, lo corriges antes de guardar.',
  ),
  BankProfile(
    name: 'Nequi',
    accent: 0xFFEF6A00,
    shortcutHint: 'Sirve mucho para gastos pequenos y de todos los dias.',
    notificationHint:
        'Cuando llegue una compra, la app intenta entenderla al momento.',
    officialHint:
        'Si el gasto fue en efectivo o no cuadra, lo dejas en manual.',
  ),
  BankProfile(
    name: 'Davivienda',
    accent: 0xFFE53935,
    shortcutHint: 'Te ayuda a no perder compras importantes.',
    notificationHint:
        'Si ves el aviso en el celular, MisFin lo puede guardar rapido.',
    officialHint: 'Si prefieres, siempre puedes revisar antes de confirmar.',
  ),
  BankProfile(
    name: 'BBVA',
    accent: 0xFF1E4ED8,
    shortcutHint:
        'Bueno para revisar pagos con tarjeta sin abrir mil pantallas.',
    notificationHint:
        'Si llega un mensaje de compra, la app intenta dejarlo listo.',
    officialHint: 'Si algo queda raro, solo corriges una vez y sigues.',
  ),
  BankProfile(
    name: 'Banco de Bogota',
    accent: 0xFF0057B8,
    shortcutHint: 'Sirve para seguir el ritmo de tus compras con mas orden.',
    notificationHint: 'Si recibes un aviso, la app intenta detectarlo sola.',
    officialHint: 'Si no esta claro, lo dejas para revisar despues.',
  ),
  BankProfile(
    name: 'Banco Popular',
    accent: 0xFFE71F3D,
    shortcutHint: 'Practico para ver rapido en que se fue el dinero.',
    notificationHint:
        'Cuando llegue un movimiento, MisFin intenta leerlo de inmediato.',
    officialHint:
        'Si quieres ir seguro, primero miras el resumen y luego guardas.',
  ),
  BankProfile(
    name: 'Banco Caja Social',
    accent: 0xFF00A3E0,
    shortcutHint: 'Te ayuda a ordenar compras pequenas y repetidas.',
    notificationHint:
        'Si entra una notificacion de gasto, la app lo intenta captar sola.',
    officialHint: 'Si hay dudas, lo ajustas antes de dejarlo guardado.',
  ),
  BankProfile(
    name: 'Scotiabank Colpatria',
    accent: 0xFFE1251B,
    shortcutHint: 'Buena opcion para movimientos que quieres ver sin esfuerzo.',
    notificationHint:
        'Si llega la alerta de compra, MisFin intenta dejarla lista.',
    officialHint: 'Si algo no encaja, puedes corregirlo en un toque.',
  ),
  BankProfile(
    name: 'Itau',
    accent: 0xFF2B2E83,
    shortcutHint: 'Ideal para llevar compras importantes con orden.',
    notificationHint:
        'Cuando llegue un aviso, la app intenta leer el monto y el banco.',
    officialHint: 'Si hace falta, revisas antes de confirmar.',
  ),
  BankProfile(
    name: 'Lulo Bank',
    accent: 0xFF00C2A8,
    shortcutHint: 'Muy util para registrar compras rapidas sin pensarlo mucho.',
    notificationHint:
        'Si la notificacion trae el valor, MisFin intenta guardarla sola.',
    officialHint: 'Si algo no cuadra, lo cambias antes de terminar.',
  ),
  BankProfile(
    name: 'RappiPay',
    accent: 0xFFFF6F61,
    shortcutHint: 'Excelente para seguir compras cotidianas y delivery.',
    notificationHint:
        'Si llega el aviso de un pago, la app intenta tomarlo al vuelo.',
    officialHint: 'Si quieres, siempre puedes revisarlo antes de dejarlo fijo.',
  ),
];

class MisFinProfile {
  const MisFinProfile({
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

  factory MisFinProfile.defaults() {
    return const MisFinProfile(
      name: fixedUserName,
      onboardingComplete: false,
      currency: AppCurrency.cop,
      frequency: IncomeFrequency.monthly,
      incomePerPeriod: 0,
      monthlySavingsGoal: 0,
      selectedBanks: defaultSelectedBankNames,
    );
  }

  double get monthlyIncome => incomePerPeriod * frequency.monthlyMultiplier;
  double get monthlyBudget =>
      (monthlyIncome - monthlySavingsGoal).clamp(0, double.infinity).toDouble();

  MisFinProfile copyWith({
    String? name,
    bool? onboardingComplete,
    AppCurrency? currency,
    IncomeFrequency? frequency,
    double? incomePerPeriod,
    double? monthlySavingsGoal,
    List<String>? selectedBanks,
  }) {
    return MisFinProfile(
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

  factory MisFinProfile.fromJson(Map<String, dynamic> json) {
    return MisFinProfile(
      name: fixedUserName,
      onboardingComplete: (json['onboardingComplete'] as bool?) ?? false,
      currency: AppCurrency.fromName((json['currency'] as String?) ?? 'cop'),
      frequency: IncomeFrequencyX.fromName(
          (json['frequency'] as String?) ?? 'monthly'),
      incomePerPeriod: (json['incomePerPeriod'] as num?)?.toDouble() ?? 0,
      monthlySavingsGoal: (json['monthlySavingsGoal'] as num?)?.toDouble() ?? 0,
      selectedBanks: (json['selectedBanks'] as List<dynamic>?)
              ?.map((value) => value.toString())
              .toList() ??
          defaultSelectedBankNames,
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
      monthKey: (json['monthKey'] as String?) ??
          monthKeyOf(DateTime.parse(json['createdAt'] as String)),
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
    required MisFinProfile profile,
  }) {
    final parsedDate = DateTime.parse('$monthKey-01');
    final spent =
        expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
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

  bool get canAutoImport => amount != null && confidence >= 75;
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
