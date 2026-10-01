import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/calculation_record.dart';
import '../models/user_planning_models.dart';

class LocalStore {
  static const _historyKey = 'calculation_history_v1';
  static const _favoritesKey = 'favorite_calculators_v1';
  static const _onboardingKey = 'onboarding_done_v1';
  static const _languageKey = 'app_language_v1';

  static Future<bool> onboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  static Future<String> language() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'en';
  }

  static Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }

  static Future<void> setOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  static Future<List<CalculationRecord>> history() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_historyKey) ?? [];
    return raw
        .map((e) => CalculationRecord.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  static Future<void> addHistory(CalculationRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await history();
    items.removeWhere((e) => e.type == record.type && e.title == record.title);
    items.insert(0, record);
    final trimmed = items.take(30).map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_historyKey, trimmed);
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  static Future<Set<String>> favorites() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_favoritesKey) ?? []).toSet();
  }

  static Future<bool> toggleFavorite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final set = await favorites();
    if (!set.add(id)) set.remove(id);
    await prefs.setStringList(_favoritesKey, set.toList());
    return set.contains(id);
  }

  static const _plansKey = 'saved_plans_v1';
  static const _remindersKey = 'finance_reminders_v1';
  static const _healthKey = 'financial_health_v1';

  static Future<List<SavedPlan>> savedPlans() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_plansKey) ?? [];
    return raw.map((e) => SavedPlan.fromJson(jsonDecode(e) as Map<String, dynamic>)).toList();
  }

  static Future<void> savePlan(SavedPlan plan) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await savedPlans();
    items.removeWhere((e) => e.id == plan.id);
    items.insert(0, plan);
    await prefs.setStringList(_plansKey, items.take(50).map((e) => jsonEncode(e.toJson())).toList());
  }

  static Future<void> deletePlan(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await savedPlans();
    items.removeWhere((e) => e.id == id);
    await prefs.setStringList(_plansKey, items.map((e) => jsonEncode(e.toJson())).toList());
  }

  static Future<List<FinanceReminder>> reminders() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_remindersKey) ?? [];
    return raw.map((e) => FinanceReminder.fromJson(jsonDecode(e) as Map<String, dynamic>)).toList();
  }

  static Future<void> saveReminder(FinanceReminder reminder) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await reminders();
    items.removeWhere((e) => e.id == reminder.id);
    items.insert(0, reminder);
    await prefs.setStringList(_remindersKey, items.take(100).map((e) => jsonEncode(e.toJson())).toList());
  }

  static Future<void> deleteReminder(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await reminders();
    items.removeWhere((e) => e.id == id);
    await prefs.setStringList(_remindersKey, items.map((e) => jsonEncode(e.toJson())).toList());
  }

  static Future<void> setReminderCompleted(String id, bool completed) async {
    final items = await reminders();
    final index = items.indexWhere((e) => e.id == id);
    if (index == -1) return;
    await saveReminder(items[index].copyWith(completed: completed));
  }

  static Future<FinancialHealth?> financialHealth() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_healthKey);
    if (raw == null) return null;
    return FinancialHealth.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  static Future<void> saveFinancialHealth(FinancialHealth health) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_healthKey, jsonEncode(health.toJson()));
  }
}
