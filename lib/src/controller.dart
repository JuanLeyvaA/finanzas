import 'dart:math';

import 'package:flutter/foundation.dart';

import 'month_utils.dart';
import 'app_identity.dart';
import 'models.dart';
import 'parser.dart';
import 'storage.dart';

class PresuCoController extends ChangeNotifier {
  PresuCoController(this._store);

  static const List<String> _dailyMotivations = [
    'Un paso suave hoy tambien cuenta.',
    'Ahorrar poquito tambien es avanzar.',
    'Cada registro te da mas claridad.',
    'Vas construyendo calma compra a compra.',
    'Hoy tambien puedes cuidar tu bolsillo.',
    'Tu esfuerzo de hoy se nota mañana.',
    'Pequenos cambios hacen una gran diferencia.',
    'Lo estas haciendo mejor de lo que crees.',
    'Cada gasto consciente suma a tu meta.',
    'Ordenar tu dinero tambien es cuidarte.',
    'Respira, revisa y sigue paso a paso.',
    'Tu meta sigue viva, incluso en dias lentos.',
    'Hoy puede ser un gran dia para ahorrar un poco.',
    'Mirar tus gastos con calma ya es un logro.',
    'Constancia suave le gana al caos.',
    'Cada decision consciente fortalece tu plan.',
    'Tu progreso no tiene que ser perfecto para valer.',
    'Seguir intentando tambien es avanzar.',
    'Cuidar tus finanzas es una forma de quererte.',
    'Vas creando un futuro mas tranquilo para ti.',
  ];

  final PresuCoStore _store;
  final PresuCoParser _parser = const PresuCoParser();
  final Random _random = Random();

  PresuCoProfile profile = PresuCoProfile.defaults();
  List<ExpenseEntry> expenses = <ExpenseEntry>[];
  List<MonthlySummary> history = <MonthlySummary>[];
  ParsedTransactionDraft? draft;
  bool showOnboardingWizard = false;
  bool loading = true;

  Future<void> load() async {
    profile = await _store.loadProfile();
    profile = profile.copyWith(name: fixedUserName);
    expenses = await _store.loadExpenses();
    history = await _store.loadHistory();
    await _store.saveProfile(profile);
    await _syncHistory();
    loading = false;
    notifyListeners();
  }

  Future<void> beginOnboarding() async {
    showOnboardingWizard = true;
    notifyListeners();
  }

  Future<void> completeOnboarding({
    required String name,
    required IncomeFrequency frequency,
    required double incomePerPeriod,
    required double monthlySavingsGoal,
    required List<String> selectedBanks,
  }) async {
    profile = PresuCoProfile(
      name: fixedUserName,
      onboardingComplete: true,
      currency: profile.currency,
      frequency: frequency,
      incomePerPeriod: incomePerPeriod,
      monthlySavingsGoal: monthlySavingsGoal,
      selectedBanks: selectedBanks,
    );
    showOnboardingWizard = false;
    await _store.saveProfile(profile);
    await _syncHistory();
    notifyListeners();
  }

  Future<void> toggleBank(String bankName) async {
    final next = [...profile.selectedBanks];
    if (next.contains(bankName)) {
      next.remove(bankName);
    } else {
      next.add(bankName);
    }
    profile = profile.copyWith(selectedBanks: next);
    await _store.saveProfile(profile);
    notifyListeners();
  }

  Future<void> updateProfile({
    String? name,
    AppCurrency? currency,
    IncomeFrequency? frequency,
    double? incomePerPeriod,
    double? monthlySavingsGoal,
  }) async {
    profile = profile.copyWith(
      name: fixedUserName,
      currency: currency,
      frequency: frequency,
      incomePerPeriod: incomePerPeriod,
      monthlySavingsGoal: monthlySavingsGoal,
    );
    await _store.saveProfile(profile);
    await _syncHistory();
    notifyListeners();
  }

  Future<void> updateCurrency(AppCurrency currency) async {
    profile = profile.copyWith(currency: currency);
    await _store.saveProfile(profile);
    notifyListeners();
  }

  Future<void> addManualExpense({
    required double amount,
    required String note,
    String source = 'Manual',
    String category = 'Compra',
    String? bank,
    String? rawText,
  }) async {
    final now = DateTime.now();
    expenses = [
      ExpenseEntry(
        id: 'exp_${now.microsecondsSinceEpoch}_${_random.nextInt(9999)}',
        amount: amount,
        note: note,
        createdAt: now,
        monthKey: monthKeyOf(now),
        source: source,
        category: category,
        bank: bank,
        rawText: rawText,
      ),
      ...expenses,
    ];
    await _store.saveExpenses(expenses);
    await _syncHistory();
    notifyListeners();
  }

  Future<void> updateExpense(
    String id, {
    double? amount,
    String? note,
    String? source,
    String? category,
    String? bank,
    String? rawText,
    DateTime? createdAt,
  }) async {
    expenses = expenses.map((expense) {
      if (expense.id != id) {
        return expense;
      }
      return ExpenseEntry(
        id: expense.id,
        amount: amount ?? expense.amount,
        note: note ?? expense.note,
        createdAt: createdAt ?? expense.createdAt,
        monthKey: expense.monthKey,
        source: source ?? expense.source,
        category: category ?? expense.category,
        bank: bank ?? expense.bank,
        rawText: rawText ?? expense.rawText,
      );
    }).toList();
    await _store.saveExpenses(expenses);
    await _syncHistory();
    notifyListeners();
  }

  Future<void> removeExpense(String id) async {
    expenses = expenses.where((expense) => expense.id != id).toList();
    await _store.saveExpenses(expenses);
    await _syncHistory();
    notifyListeners();
  }

  void parseText(String text) {
    draft = _parser.parse(text);
    notifyListeners();
  }

  Future<bool> ingestText(String text, {bool autoImport = false}) async {
    draft = _parser.parse(text);
    notifyListeners();

    if (autoImport &&
        draft?.canAutoImport == true &&
        !(draft?.hasCurrencyMismatch(profile.currency) ?? false)) {
      await importDraft();
      return true;
    }

    return false;
  }

  void clearDraft() {
    draft = null;
    notifyListeners();
  }

  Future<void> importDraft() async {
    final currentDraft = draft;
    if (currentDraft == null || currentDraft.amount == null) {
      return;
    }

    await addManualExpense(
      amount: currentDraft.amount!,
      note: currentDraft.note,
      source: currentDraft.bank == null ? 'Clipboard' : currentDraft.bank!,
      category: currentDraft.category,
      bank: currentDraft.bank,
      rawText: currentDraft.rawText,
    );
    clearDraft();
  }

  Future<void> resetAll() async {
    await _store.clear();
    profile = PresuCoProfile.defaults();
    expenses = <ExpenseEntry>[];
    history = <MonthlySummary>[];
    draft = null;
    showOnboardingWizard = false;
    notifyListeners();
  }

  double get monthlyIncome => profile.monthlyIncome;
  double get monthlyBudget => profile.monthlyBudget;
  String get currentMonthKey => monthKeyOf(DateTime.now());
  String get currentMonthLabel => monthLabelOf(currentMonthKey);
  List<ExpenseEntry> get currentMonthExpenses =>
      expenses.where((expense) => expense.monthKey == currentMonthKey).toList();
  double get spentThisMonth => currentMonthExpenses.fold<double>(0, (sum, item) => sum + item.amount);
  double get remainingBudget => monthlyBudget - spentThisMonth;
  double get progress =>
      monthlyBudget == 0 ? 0 : (spentThisMonth / monthlyBudget).clamp(0.0, 1.25).toDouble();
  MonthlySummary get currentMonthSummary => _summaryForMonth(currentMonthKey);
  List<MonthlySummary> get orderedHistory =>
      [...history]..sort((a, b) => b.monthKey.compareTo(a.monthKey));

  String get statusLabel {
    if (monthlyBudget == 0) return 'Configura tu perfil para empezar.';
    if (spentThisMonth >= monthlyBudget) return 'No te preocupes, siempre se puede mejorar <3.';
    if (spentThisMonth >= monthlyBudget * 0.8) return 'ten cuidado, ya casi llegas al limite!';
    return 'Vas bien. Sigues dentro del plan.';
  }

  String get statusAction {
    if (monthlyBudget == 0) return 'Tu presupuesto se calculara cuando completes el onboarding.';
    if (spentThisMonth >= monthlyBudget) return 'No te preocupes, siempre se puede mejorar <3.';
    if (spentThisMonth >= monthlyBudget * 0.8) return 'ten cuidado, ya casi llegas al limite!';
    return dailyMotivation;
  }

  String get dailyMotivation {
    final today = DateTime.now();
    final dayNumber = DateTime(today.year, today.month, today.day).millisecondsSinceEpoch ~/
        Duration.millisecondsPerDay;
    return _dailyMotivations[dayNumber % _dailyMotivations.length];
  }

  bool get shouldWarn => monthlyBudget > 0 && spentThisMonth >= monthlyBudget * 0.8;
  bool get isOverBudget => monthlyBudget > 0 && spentThisMonth >= monthlyBudget;

  BankProfile bankByName(String name) {
    return bankCatalog.firstWhere(
      (bank) => bank.name == name,
      orElse: () => bankCatalog.first,
    );
  }

  List<ExpenseEntry> expensesForMonth(String monthKey) {
    return expenses.where((expense) => expense.monthKey == monthKey).toList();
  }

  MonthlySummary _summaryForMonth(String monthKey) {
    final monthExpenses = expensesForMonth(monthKey);
    final existing = history.where((item) => item.monthKey == monthKey).toList();
    if (existing.isNotEmpty) {
      final current = existing.first;
      return current.copyWith(
        income: monthKey == currentMonthKey ? profile.monthlyIncome : current.income,
        savingsGoal: monthKey == currentMonthKey ? profile.monthlySavingsGoal : current.savingsGoal,
        budget: monthKey == currentMonthKey ? profile.monthlyBudget : current.budget,
        spent: monthExpenses.fold<double>(0, (sum, item) => sum + item.amount),
        expenseCount: monthExpenses.length,
        lastUpdated: DateTime.now(),
      );
    }

    return MonthlySummary.fromExpenses(
      monthKey: monthKey,
      expenses: monthExpenses,
      profile: profile,
    );
  }

  Future<void> _syncHistory() async {
    final grouped = <String, List<ExpenseEntry>>{};
    for (final expense in expenses) {
      grouped.putIfAbsent(expense.monthKey, () => <ExpenseEntry>[]).add(expense);
    }

    final existing = {for (final item in history) item.monthKey: item};
    final rebuilt = <MonthlySummary>[];

    for (final entry in grouped.entries) {
      final monthExpenses = entry.value;
      final spent = monthExpenses.fold<double>(0, (sum, item) => sum + item.amount);
      final current = existing[entry.key];
      final isCurrentMonth = entry.key == currentMonthKey;
      if (current == null) {
        rebuilt.add(
          MonthlySummary.fromExpenses(
            monthKey: entry.key,
            expenses: monthExpenses,
            profile: profile,
          ),
        );
      } else {
        rebuilt.add(
          current.copyWith(
            income: isCurrentMonth ? profile.monthlyIncome : current.income,
            savingsGoal: isCurrentMonth ? profile.monthlySavingsGoal : current.savingsGoal,
            budget: isCurrentMonth ? profile.monthlyBudget : current.budget,
            spent: spent,
            expenseCount: monthExpenses.length,
            lastUpdated: DateTime.now(),
          ),
        );
      }
    }

    rebuilt.sort((a, b) => b.monthKey.compareTo(a.monthKey));
    history = rebuilt;
    await _store.saveHistory(history);
  }
}
