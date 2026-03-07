// lib/models/models.dart
import 'package:flutter/material.dart';

// ─── Enums ────────────────────────────────────────────────
enum TransactionType { income, expense }
enum RecurringType { none, daily, weekly, monthly, yearly }

// ─── Currency ─────────────────────────────────────────────
class Currency {
  final String code;
  final String symbol;
  final String nameAr;
  final String flag;
  const Currency({required this.code, required this.symbol, required this.nameAr, required this.flag});
}

const List<Currency> kCurrencies = [
  Currency(code: 'USD', symbol: r'$',   nameAr: 'دولار أمريكي',   flag: '🇺🇸'),
  Currency(code: 'EUR', symbol: '€',    nameAr: 'يورو',            flag: '🇪🇺'),
  Currency(code: 'SYP', symbol: 'ل.س', nameAr: 'ليرة سورية',     flag: '🇸🇾'),
  Currency(code: 'SAR', symbol: '﷼',   nameAr: 'ريال سعودي',     flag: '🇸🇦'),
  Currency(code: 'AED', symbol: 'د.إ', nameAr: 'درهم إماراتي',   flag: '🇦🇪'),
  Currency(code: 'TRY', symbol: '₺',   nameAr: 'ليرة تركية',     flag: '🇹🇷'),
  Currency(code: 'GBP', symbol: '£',   nameAr: 'جنيه إسترليني',  flag: '🇬🇧'),
  Currency(code: 'JOD', symbol: 'د.أ', nameAr: 'دينار أردني',    flag: '🇯🇴'),
  Currency(code: 'EGP', symbol: 'ج.م', nameAr: 'جنيه مصري',     flag: '🇪🇬'),
];

Currency currencyByCode(String code) =>
    kCurrencies.firstWhere((c) => c.code == code, orElse: () => kCurrencies.first);

// ─── Category ─────────────────────────────────────────────
class TxCategory {
  final String id;
  final String nameAr;
  final String emoji;
  final Color color;
  final TransactionType type;

  const TxCategory({
    required this.id, required this.nameAr,
    required this.emoji, required this.color, required this.type,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'nameAr': nameAr, 'emoji': emoji,
    'color': color.value, 'type': type.name,
  };
  factory TxCategory.fromMap(Map<String, dynamic> m) => TxCategory(
    id: m['id'], nameAr: m['nameAr'], emoji: m['emoji'],
    color: Color(m['color']), type: TransactionType.values.byName(m['type']),
  );
}

const List<TxCategory> kDefaultCategories = [
  TxCategory(id:'food',       nameAr:'طعام',       emoji:'🍽️', color:Color(0xFFF59E0B), type:TransactionType.expense),
  TxCategory(id:'transport',  nameAr:'مواصلات',    emoji:'🚗', color:Color(0xFF3B82F6), type:TransactionType.expense),
  TxCategory(id:'shopping',   nameAr:'تسوق',       emoji:'🛍️', color:Color(0xFF8B5CF6), type:TransactionType.expense),
  TxCategory(id:'bills',      nameAr:'فواتير',     emoji:'📱', color:Color(0xFFEF4444), type:TransactionType.expense),
  TxCategory(id:'health',     nameAr:'صحة',        emoji:'💊', color:Color(0xFF10B981), type:TransactionType.expense),
  TxCategory(id:'entertainment',nameAr:'ترفيه',    emoji:'🎬', color:Color(0xFFF43F5E), type:TransactionType.expense),
  TxCategory(id:'education',  nameAr:'تعليم',      emoji:'📚', color:Color(0xFF06B6D4), type:TransactionType.expense),
  TxCategory(id:'travel',     nameAr:'سفر',        emoji:'✈️', color:Color(0xFF6366F1), type:TransactionType.expense),
  TxCategory(id:'home',       nameAr:'منزل',       emoji:'🏠', color:Color(0xFFA16207), type:TransactionType.expense),
  TxCategory(id:'other_exp',  nameAr:'أخرى',       emoji:'💸', color:Color(0xFF64748B), type:TransactionType.expense),
  TxCategory(id:'salary',     nameAr:'راتب',       emoji:'💼', color:Color(0xFF10B981), type:TransactionType.income),
  TxCategory(id:'freelance',  nameAr:'فريلانس',    emoji:'💻', color:Color(0xFF3B82F6), type:TransactionType.income),
  TxCategory(id:'investment', nameAr:'استثمار',    emoji:'📈', color:Color(0xFFF59E0B), type:TransactionType.income),
  TxCategory(id:'gift',       nameAr:'هدية',       emoji:'🎁', color:Color(0xFFEC4899), type:TransactionType.income),
  TxCategory(id:'other_inc',  nameAr:'دخل آخر',   emoji:'💰', color:Color(0xFF8B5CF6), type:TransactionType.income),
];

TxCategory? categoryById(String? id) =>
    id == null ? null : kDefaultCategories.where((c) => c.id == id).firstOrNull;

// ─── Account ──────────────────────────────────────────────
class Account {
  final String id;
  String name;
  String currency;
  double balance;
  int colorValue;
  DateTime createdAt;

  Account({
    required this.id, required this.name,
    required this.currency, required this.balance,
    required this.colorValue, required this.createdAt,
  });

  Color get color => Color(colorValue);

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'currency': currency,
    'balance': balance, 'colorValue': colorValue,
    'createdAt': createdAt.millisecondsSinceEpoch,
  };
  factory Account.fromMap(Map<String, dynamic> m) => Account(
    id: m['id'], name: m['name'], currency: m['currency'],
    balance: m['balance'], colorValue: m['colorValue'],
    createdAt: DateTime.fromMillisecondsSinceEpoch(m['createdAt']),
  );
}

// ─── Transaction ──────────────────────────────────────────
class Transaction {
  final String id;
  String accountId;
  String? categoryId;
  double amount;
  TransactionType type;
  String description;
  DateTime date;
  String currency;
  RecurringType recurring;

  Transaction({
    required this.id, required this.accountId,
    this.categoryId, required this.amount,
    required this.type, this.description = '',
    required this.date, required this.currency,
    this.recurring = RecurringType.none,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'accountId': accountId, 'categoryId': categoryId,
    'amount': amount, 'type': type.name, 'description': description,
    'date': date.millisecondsSinceEpoch, 'currency': currency,
    'recurring': recurring.name,
  };
  factory Transaction.fromMap(Map<String, dynamic> m) => Transaction(
    id: m['id'], accountId: m['accountId'], categoryId: m['categoryId'],
    amount: m['amount'], type: TransactionType.values.byName(m['type']),
    description: m['description'] ?? '', currency: m['currency'],
    date: DateTime.fromMillisecondsSinceEpoch(m['date']),
    recurring: RecurringType.values.byName(m['recurring'] ?? 'none'),
  );
}

// ─── Budget ───────────────────────────────────────────────
class Budget {
  final String id;
  String categoryId;
  double amount;
  int month;
  int year;

  Budget({
    required this.id, required this.categoryId,
    required this.amount, required this.month, required this.year,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'categoryId': categoryId,
    'amount': amount, 'month': month, 'year': year,
  };
  factory Budget.fromMap(Map<String, dynamic> m) => Budget(
    id: m['id'], categoryId: m['categoryId'],
    amount: m['amount'], month: m['month'], year: m['year'],
  );
}

// ─── Transfer ─────────────────────────────────────────────
class Transfer {
  final String id;
  String fromAccountId;
  String toAccountId;
  double amount;
  double convertedAmount;
  double exchangeRate;
  String note;
  DateTime date;

  Transfer({
    required this.id, required this.fromAccountId, required this.toAccountId,
    required this.amount, required this.convertedAmount,
    this.exchangeRate = 1.0, this.note = '', required this.date,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'fromAccountId': fromAccountId, 'toAccountId': toAccountId,
    'amount': amount, 'convertedAmount': convertedAmount,
    'exchangeRate': exchangeRate, 'note': note,
    'date': date.millisecondsSinceEpoch,
  };
  factory Transfer.fromMap(Map<String, dynamic> m) => Transfer(
    id: m['id'], fromAccountId: m['fromAccountId'], toAccountId: m['toAccountId'],
    amount: m['amount'], convertedAmount: m['convertedAmount'],
    exchangeRate: m['exchangeRate'] ?? 1.0, note: m['note'] ?? '',
    date: DateTime.fromMillisecondsSinceEpoch(m['date']),
  );
}
