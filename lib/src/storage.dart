import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class MisFinStore {
  const MisFinStore();

  static const String _profileKey = 'misfin.profile';
  static const String _expensesKey = 'misfin.expenses';
  static const String _historyKey = 'misfin.history';

  Future<MisFinProfile> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profileKey);
    if (raw == null || raw.isEmpty) {
      return MisFinProfile.defaults();
    }

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return MisFinProfile.fromJson(decoded);
  }

  Future<List<ExpenseEntry>> loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_expensesKey);
    if (raw == null || raw.isEmpty) {
      return <ExpenseEntry>[];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => ExpenseEntry.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<MonthlySummary>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null || raw.isEmpty) {
      return <MonthlySummary>[];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => MonthlySummary.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveProfile(MisFinProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  Future<void> saveExpenses(List<ExpenseEntry> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _expensesKey,
      jsonEncode(expenses.map((expense) => expense.toJson()).toList()),
    );
  }

  Future<void> saveHistory(List<MonthlySummary> history) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _historyKey,
      jsonEncode(history.map((entry) => entry.toJson()).toList()),
    );
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
    await prefs.remove(_expensesKey);
    await prefs.remove(_historyKey);
  }
}
