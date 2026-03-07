// lib/providers/app_provider.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../utils/database.dart';

const _uuid = Uuid();

class AppProvider extends ChangeNotifier {
  List<Account> accounts = [];
  List<Transaction> transactions = [];
  List<Budget> budgets = [];
  List<Transfer> transfers = [];
  DateTime selectedMonth = DateTime.now();
  bool isDark = true;
  String mainCurrency = 'USD';

  // ── Computed ──────────────────────────────────────────
  double get totalBalance => accounts.fold(0, (s, a) => s + a.balance);

  List<Transaction> get monthlyTransactions {
    final m = selectedMonth.month;
    final y = selectedMonth.year;
    return transactions.where((t) => t.date.month == m && t.date.year == y).toList();
  }

  double get monthlyIncome =>
      monthlyTransactions.where((t) => t.type == TransactionType.income).fold(0, (s, t) => s + t.amount);
  double get monthlyExpense =>
      monthlyTransactions.where((t) => t.type == TransactionType.expense).fold(0, (s, t) => s + t.amount);
  double get monthlySavings => monthlyIncome - monthlyExpense;

  Map<String, double> get expensesByCategory {
    final map = <String, double>{};
    for (final t in monthlyTransactions.where((t) => t.type == TransactionType.expense)) {
      final id = t.categoryId ?? 'other_exp';
      map[id] = (map[id] ?? 0) + t.amount;
    }
    final sorted = map.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted);
  }

  // ── Init ──────────────────────────────────────────────
  Future<void> load() async {
    accounts = await DB.getAccounts();
    transactions = await DB.getTransactions();
    budgets = await DB.getBudgets(selectedMonth.month, selectedMonth.year);
    transfers = await DB.getTransfers();
    // Add demo data if fresh install
    if (accounts.isEmpty) await _addDemoData();
    notifyListeners();
  }

  Future<void> _addDemoData() async {
    final a1 = Account(
      id: _uuid.v4(), name: 'المحفظة الرئيسية',
      currency: 'USD', balance: 2450.75,
      colorValue: 0xFF10B981, createdAt: DateTime.now(),
    );
    final a2 = Account(
      id: _uuid.v4(), name: 'حساب التوفير',
      currency: 'USD', balance: 8200.00,
      colorValue: 0xFF3B82F6, createdAt: DateTime.now(),
    );
    await DB.insertAccount(a1);
    await DB.insertAccount(a2);
    final now = DateTime.now();
    final sampleTx = [
      Transaction(id:_uuid.v4(), accountId:a1.id, categoryId:'salary',    amount:3000, type:TransactionType.income,  date:now.subtract(const Duration(days:2)), currency:'USD', description:''),
      Transaction(id:_uuid.v4(), accountId:a1.id, categoryId:'food',      amount:45.5, type:TransactionType.expense, date:now.subtract(const Duration(days:1)), currency:'USD', description:'مطعم الشرق'),
      Transaction(id:_uuid.v4(), accountId:a1.id, categoryId:'shopping',  amount:120,  type:TransactionType.expense, date:now.subtract(const Duration(hours:5)),currency:'USD', description:''),
      Transaction(id:_uuid.v4(), accountId:a1.id, categoryId:'transport', amount:35,   type:TransactionType.expense, date:now.subtract(const Duration(hours:2)),currency:'USD', description:''),
    ];
    for (final t in sampleTx) await DB.insertTransaction(t);
    accounts = [a1, a2];
    transactions = sampleTx.reversed.toList();
  }

  Future<void> _reloadBudgets() async {
    budgets = await DB.getBudgets(selectedMonth.month, selectedMonth.year);
  }

  // ── Accounts ──────────────────────────────────────────
  Future<void> addAccount(Account a) async {
    await DB.insertAccount(a);
    accounts.add(a);
    notifyListeners();
  }
  Future<void> updateAccount(Account a) async {
    await DB.updateAccount(a);
    final i = accounts.indexWhere((x) => x.id == a.id);
    if (i >= 0) accounts[i] = a;
    notifyListeners();
  }
  Future<void> deleteAccount(String id) async {
    await DB.deleteAccount(id);
    accounts.removeWhere((a) => a.id == id);
    transactions.removeWhere((t) => t.accountId == id);
    notifyListeners();
  }

  // ── Transactions ──────────────────────────────────────
  Future<void> addTransaction(Transaction t) async {
    await DB.insertTransaction(t);
    transactions.insert(0, t);
    final acc = accounts.firstWhere((a) => a.id == t.accountId);
    acc.balance += t.type == TransactionType.income ? t.amount : -t.amount;
    await DB.updateAccount(acc);
    notifyListeners();
  }
  Future<void> deleteTransaction(Transaction t) async {
    await DB.deleteTransaction(t.id);
    transactions.removeWhere((x) => x.id == t.id);
    final acc = accounts.firstWhere((a) => a.id == t.accountId, orElse: () => accounts.first);
    acc.balance += t.type == TransactionType.income ? -t.amount : t.amount;
    await DB.updateAccount(acc);
    notifyListeners();
  }

  // ── Budgets ───────────────────────────────────────────
  Future<void> addBudget(Budget b) async {
    await DB.insertBudget(b);
    budgets.removeWhere((x) => x.categoryId == b.categoryId && x.month == b.month && x.year == b.year);
    budgets.add(b);
    notifyListeners();
  }
  Future<void> deleteBudget(String id) async {
    await DB.deleteBudget(id);
    budgets.removeWhere((b) => b.id == id);
    notifyListeners();
  }

  // ── Transfers ─────────────────────────────────────────
  Future<void> addTransfer(Transfer t) async {
    await DB.insertTransfer(t);
    transfers.insert(0, t);
    final from = accounts.firstWhere((a) => a.id == t.fromAccountId);
    final to = accounts.firstWhere((a) => a.id == t.toAccountId);
    from.balance -= t.amount;
    to.balance += t.convertedAmount;
    await DB.updateAccount(from);
    await DB.updateAccount(to);
    notifyListeners();
  }

  // ── Settings ──────────────────────────────────────────
  void toggleTheme() { isDark = !isDark; notifyListeners(); }
  void setMainCurrency(String c) { mainCurrency = c; notifyListeners(); }
  Future<void> changeMonth(int delta) async {
    selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + delta);
    await _reloadBudgets();
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────
  Account? accountById(String id) => accounts.where((a) => a.id == id).firstOrNull;
  double spentForCategory(String catId) =>
      monthlyTransactions.where((t) => t.type == TransactionType.expense && t.categoryId == catId)
          .fold(0, (s, t) => s + t.amount);
}
