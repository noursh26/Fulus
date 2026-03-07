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
  final String nameEn;
  final String flag;
  final int decimalDigits;
  final double rateToUSD;
  
  const Currency({
    required this.code, 
    required this.symbol, 
    required this.nameAr,
    required this.nameEn,
    required this.flag,
    this.decimalDigits = 2,
    this.rateToUSD = 1.0,
  });
  
  double convertTo(Currency other, double amount) {
    if (code == other.code) return amount;
    final inUSD = amount / rateToUSD;
    return inUSD * other.rateToUSD;
  }
}

const List<Currency> kCurrencies = [
  Currency(code: 'USD', symbol: r'$', nameAr: 'دولار أمريكي', nameEn: 'US Dollar', flag: '🇺🇸', rateToUSD: 1.0),
  Currency(code: 'EUR', symbol: '€', nameAr: 'يورو', nameEn: 'Euro', flag: '🇪🇺', rateToUSD: 0.92),
  Currency(code: 'SYP', symbol: 'SYP', nameAr: 'ليرة سورية', nameEn: 'Syrian Pound', flag: '🇸🇾', decimalDigits: 0, rateToUSD: 13000.0),
  Currency(code: 'SAR', symbol: 'ر.س', nameAr: 'ريال سعودي', nameEn: 'Saudi Riyal', flag: '🇸🇦', rateToUSD: 3.75),
  Currency(code: 'AED', symbol: 'د.إ', nameAr: 'درهم إماراتي', nameEn: 'UAE Dirham', flag: '🇦🇪', rateToUSD: 3.67),
  Currency(code: 'TRY', symbol: '₺', nameAr: 'ليرة تركية', nameEn: 'Turkish Lira', flag: '🇹🇷', rateToUSD: 32.0),
  Currency(code: 'GBP', symbol: '£', nameAr: 'جنيه إسترليني', nameEn: 'British Pound', flag: '🇬🇧', rateToUSD: 0.79),
  Currency(code: 'JOD', symbol: 'د.أ', nameAr: 'دينار أردني', nameEn: 'Jordanian Dinar', flag: '🇯🇴', rateToUSD: 0.71),
  Currency(code: 'EGP', symbol: 'ج.م', nameAr: 'جنيه مصري', nameEn: 'Egyptian Pound', flag: '🇪🇬', rateToUSD: 50.0),
  Currency(code: 'KWD', symbol: 'د.ك', nameAr: 'دينار كويتي', nameEn: 'Kuwaiti Dinar', flag: '🇰🇼', rateToUSD: 0.31),
  Currency(code: 'QAR', symbol: 'ر.ق', nameAr: 'ريال قطري', nameEn: 'Qatari Riyal', flag: '🇶🇦', rateToUSD: 3.64),
  Currency(code: 'BHD', symbol: 'د.ب', nameAr: 'دينار بحريني', nameEn: 'Bahraini Dinar', flag: '🇧🇭', rateToUSD: 0.38),
  Currency(code: 'OMR', symbol: 'ر.ع', nameAr: 'ريال عماني', nameEn: 'Omani Rial', flag: '🇴🇲', rateToUSD: 0.38),
  Currency(code: 'LBP', symbol: 'ل.ل', nameAr: 'ليرة لبنانية', nameEn: 'Lebanese Pound', flag: '🇱🇧', decimalDigits: 0, rateToUSD: 89500.0),
  Currency(code: 'IQD', symbol: 'د.ع', nameAr: 'دينار عراقي', nameEn: 'Iraqi Dinar', flag: '🇮🇶', decimalDigits: 0, rateToUSD: 1310.0),
  Currency(code: 'MAD', symbol: 'د.م', nameAr: 'درهم مغربي', nameEn: 'Moroccan Dirham', flag: '🇲🇦', rateToUSD: 10.0),
  Currency(code: 'DZD', symbol: 'د.ج', nameAr: 'دينار جزائري', nameEn: 'Algerian Dinar', flag: '🇩🇿', rateToUSD: 135.0),
  Currency(code: 'TND', symbol: 'د.ت', nameAr: 'دينار تونسي', nameEn: 'Tunisian Dinar', flag: '🇹🇳', rateToUSD: 3.1),
  Currency(code: 'LYD', symbol: 'د.ل', nameAr: 'دينار ليبي', nameEn: 'Libyan Dinar', flag: '🇱🇾', rateToUSD: 4.85),
  Currency(code: 'SDG', symbol: 'ج.س', nameAr: 'جنيه سوداني', nameEn: 'Sudanese Pound', flag: '��🇩', rateToUSD: 601.0),
  Currency(code: 'YER', symbol: 'ر.ي', nameAr: 'ريال يمني', nameEn: 'Yemeni Rial', flag: '🇾🇪', decimalDigits: 0, rateToUSD: 250.0),
  Currency(code: 'INR', symbol: '₹', nameAr: 'روبية هندية', nameEn: 'Indian Rupee', flag: '🇮🇳', rateToUSD: 83.0),
  Currency(code: 'PKR', symbol: 'Rs', nameAr: 'روبية باكستانية', nameEn: 'Pakistani Rupee', flag: '🇵🇰', rateToUSD: 278.0),
  Currency(code: 'CNY', symbol: '¥', nameAr: 'يوان صيني', nameEn: 'Chinese Yuan', flag: '🇨🇳', rateToUSD: 7.24),
  Currency(code: 'JPY', symbol: '¥', nameAr: 'ين ياباني', nameEn: 'Japanese Yen', flag: '🇯🇵', decimalDigits: 0, rateToUSD: 149.0),
  Currency(code: 'RUB', symbol: '₽', nameAr: 'روبل روسي', nameEn: 'Russian Ruble', flag: '🇷🇺', rateToUSD: 92.0),
  Currency(code: 'CHF', symbol: 'CHF', nameAr: 'فرنك سويسري', nameEn: 'Swiss Franc', flag: '🇨🇭', rateToUSD: 0.88),
  Currency(code: 'CAD', symbol: 'C$', nameAr: 'دولار كندي', nameEn: 'Canadian Dollar', flag: '🇨🇦', rateToUSD: 1.36),
  Currency(code: 'AUD', symbol: 'A$', nameAr: 'دولار أسترالي', nameEn: 'Australian Dollar', flag: '🇦🇺', rateToUSD: 1.53),
];

Currency currencyByCode(String code) =>
    kCurrencies.firstWhere((c) => c.code == code, orElse: () => kCurrencies.first);

double convertCurrency(double amount, String fromCode, String toCode) {
  if (fromCode == toCode) return amount;
  final from = currencyByCode(fromCode);
  final to = currencyByCode(toCode);
  return from.convertTo(to, amount);
}

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

// ─── Account Type ─────────────────────────────────────────
enum AccountType { cash, bank, creditCard, savings, investment, wallet, other }

const Map<AccountType, String> kAccountTypeNames = {
  AccountType.cash: 'نقدي',
  AccountType.bank: 'حساب بنكي',
  AccountType.creditCard: 'بطاقة ائتمان',
  AccountType.savings: 'حساب توفير',
  AccountType.investment: 'استثمار',
  AccountType.wallet: 'محفظة إلكترونية',
  AccountType.other: 'أخرى',
};

const Map<AccountType, String> kAccountTypeIcons = {
  AccountType.cash: '💵',
  AccountType.bank: '🏦',
  AccountType.creditCard: '💳',
  AccountType.savings: '👝',
  AccountType.investment: '📈',
  AccountType.wallet: '📱',
  AccountType.other: '💼',
};

// ─── Account ──────────────────────────────────────────────
class Account {
  final String id;
  String name;
  String currency;
  double balance;
  int colorValue;
  DateTime createdAt;
  AccountType accountType;
  bool isHiddenFromTotal;
  bool isArchived;
  String icon;
  String note;
  double? creditLimit;
  double? targetBalance;
  int sortOrder;

  Account({
    required this.id,
    required this.name,
    required this.currency,
    required this.balance,
    required this.colorValue,
    required this.createdAt,
    this.accountType = AccountType.cash,
    this.isHiddenFromTotal = false,
    this.isArchived = false,
    this.icon = '💰',
    this.note = '',
    this.creditLimit,
    this.targetBalance,
    this.sortOrder = 0,
  });

  Color get color => Color(colorValue);
  
  String get typeNameAr => kAccountTypeNames[accountType] ?? 'أخرى';
  String get typeIcon => kAccountTypeIcons[accountType] ?? '💼';

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'currency': currency,
    'balance': balance,
    'colorValue': colorValue,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'accountType': accountType.name,
    'isHiddenFromTotal': isHiddenFromTotal ? 1 : 0,
    'isArchived': isArchived ? 1 : 0,
    'icon': icon,
    'note': note,
    'creditLimit': creditLimit,
    'targetBalance': targetBalance,
    'sortOrder': sortOrder,
  };
  
  factory Account.fromMap(Map<String, dynamic> m) => Account(
    id: m['id'],
    name: m['name'],
    currency: m['currency'],
    balance: (m['balance'] as num).toDouble(),
    colorValue: m['colorValue'],
    createdAt: DateTime.fromMillisecondsSinceEpoch(m['createdAt']),
    accountType: AccountType.values.byName(m['accountType'] ?? 'cash'),
    isHiddenFromTotal: m['isHiddenFromTotal'] == 1,
    isArchived: m['isArchived'] == 1,
    icon: m['icon'] ?? '💰',
    note: m['note'] ?? '',
    creditLimit: m['creditLimit']?.toDouble(),
    targetBalance: m['targetBalance']?.toDouble(),
    sortOrder: m['sortOrder'] ?? 0,
  );
  
  Account copyWith({
    String? name,
    String? currency,
    double? balance,
    int? colorValue,
    AccountType? accountType,
    bool? isHiddenFromTotal,
    bool? isArchived,
    String? icon,
    String? note,
    double? creditLimit,
    double? targetBalance,
    int? sortOrder,
  }) => Account(
    id: id,
    name: name ?? this.name,
    currency: currency ?? this.currency,
    balance: balance ?? this.balance,
    colorValue: colorValue ?? this.colorValue,
    createdAt: createdAt,
    accountType: accountType ?? this.accountType,
    isHiddenFromTotal: isHiddenFromTotal ?? this.isHiddenFromTotal,
    isArchived: isArchived ?? this.isArchived,
    icon: icon ?? this.icon,
    note: note ?? this.note,
    creditLimit: creditLimit ?? this.creditLimit,
    targetBalance: targetBalance ?? this.targetBalance,
    sortOrder: sortOrder ?? this.sortOrder,
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
  String? location;
  String? attachment;
  List<String> tags;
  String? payee;
  DateTime createdAt;
  DateTime? updatedAt;
  bool isConfirmed;
  String? note;
  double? originalAmount;
  String? originalCurrency;

  Transaction({
    required this.id,
    required this.accountId,
    this.categoryId,
    required this.amount,
    required this.type,
    this.description = '',
    required this.date,
    required this.currency,
    this.recurring = RecurringType.none,
    this.location,
    this.attachment,
    this.tags = const [],
    this.payee,
    DateTime? createdAt,
    this.updatedAt,
    this.isConfirmed = true,
    this.note,
    this.originalAmount,
    this.originalCurrency,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id,
    'accountId': accountId,
    'categoryId': categoryId,
    'amount': amount,
    'type': type.name,
    'description': description,
    'date': date.millisecondsSinceEpoch,
    'currency': currency,
    'recurring': recurring.name,
    'location': location,
    'attachment': attachment,
    'tags': tags.join(','),
    'payee': payee,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'updatedAt': updatedAt?.millisecondsSinceEpoch,
    'isConfirmed': isConfirmed ? 1 : 0,
    'note': note,
    'originalAmount': originalAmount,
    'originalCurrency': originalCurrency,
  };
  
  factory Transaction.fromMap(Map<String, dynamic> m) => Transaction(
    id: m['id'],
    accountId: m['accountId'],
    categoryId: m['categoryId'],
    amount: (m['amount'] as num).toDouble(),
    type: TransactionType.values.byName(m['type']),
    description: m['description'] ?? '',
    currency: m['currency'],
    date: DateTime.fromMillisecondsSinceEpoch(m['date']),
    recurring: RecurringType.values.byName(m['recurring'] ?? 'none'),
    location: m['location'],
    attachment: m['attachment'],
    tags: (m['tags'] as String?)?.split(',').where((t) => t.isNotEmpty).toList() ?? [],
    payee: m['payee'],
    createdAt: m['createdAt'] != null ? DateTime.fromMillisecondsSinceEpoch(m['createdAt']) : DateTime.now(),
    updatedAt: m['updatedAt'] != null ? DateTime.fromMillisecondsSinceEpoch(m['updatedAt']) : null,
    isConfirmed: m['isConfirmed'] != 0,
    note: m['note'],
    originalAmount: m['originalAmount']?.toDouble(),
    originalCurrency: m['originalCurrency'],
  );
  
  Transaction copyWith({
    String? accountId,
    String? categoryId,
    double? amount,
    TransactionType? type,
    String? description,
    DateTime? date,
    String? currency,
    RecurringType? recurring,
    String? location,
    String? attachment,
    List<String>? tags,
    String? payee,
    DateTime? updatedAt,
    bool? isConfirmed,
    String? note,
    double? originalAmount,
    String? originalCurrency,
  }) => Transaction(
    id: id,
    accountId: accountId ?? this.accountId,
    categoryId: categoryId ?? this.categoryId,
    amount: amount ?? this.amount,
    type: type ?? this.type,
    description: description ?? this.description,
    date: date ?? this.date,
    currency: currency ?? this.currency,
    recurring: recurring ?? this.recurring,
    location: location ?? this.location,
    attachment: attachment ?? this.attachment,
    tags: tags ?? this.tags,
    payee: payee ?? this.payee,
    createdAt: createdAt,
    updatedAt: updatedAt ?? DateTime.now(),
    isConfirmed: isConfirmed ?? this.isConfirmed,
    note: note ?? this.note,
    originalAmount: originalAmount ?? this.originalAmount,
    originalCurrency: originalCurrency ?? this.originalCurrency,
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
