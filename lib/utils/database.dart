// lib/utils/database.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart' as m;

class DB {
  static Database? _db;

  static Future<Database> get instance async {
    _db ??= await _init();
    return _db!;
  }

  static Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'fulus.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''CREATE TABLE accounts(
      id TEXT PRIMARY KEY, name TEXT, currency TEXT,
      balance REAL, colorValue INTEGER, createdAt INTEGER)''');
    await db.execute('''CREATE TABLE transactions(
      id TEXT PRIMARY KEY, accountId TEXT, categoryId TEXT,
      amount REAL, type TEXT, description TEXT,
      date INTEGER, currency TEXT, recurring TEXT)''');
    await db.execute('''CREATE TABLE budgets(
      id TEXT PRIMARY KEY, categoryId TEXT,
      amount REAL, month INTEGER, year INTEGER)''');
    await db.execute('''CREATE TABLE transfers(
      id TEXT PRIMARY KEY, fromAccountId TEXT, toAccountId TEXT,
      amount REAL, convertedAmount REAL, exchangeRate REAL,
      note TEXT, date INTEGER)''');
  }

  // ── Accounts ──────────────────────────────────────────
  static Future<List<m.Account>> getAccounts() async {
    final db = await instance;
    final maps = await db.query('accounts', orderBy: 'createdAt ASC');
    return maps.map(m.Account.fromMap).toList();
  }
  static Future<void> insertAccount(m.Account a) async =>
      (await instance).insert('accounts', a.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  static Future<void> updateAccount(m.Account a) async =>
      (await instance).update('accounts', a.toMap(), where: 'id=?', whereArgs: [a.id]);
  static Future<void> deleteAccount(String id) async {
    final db = await instance;
    await db.delete('accounts', where: 'id=?', whereArgs: [id]);
    await db.delete('transactions', where: 'accountId=?', whereArgs: [id]);
  }

  // ── Transactions ──────────────────────────────────────
  static Future<List<m.Transaction>> getTransactions() async {
    final db = await instance;
    final maps = await db.query('transactions', orderBy: 'date DESC');
    return maps.map(m.Transaction.fromMap).toList();
  }
  static Future<List<m.Transaction>> getTransactionsByMonth(int month, int year) async {
    final db = await instance;
    final start = DateTime(year, month, 1).millisecondsSinceEpoch;
    final end = DateTime(year, month + 1, 0, 23, 59, 59).millisecondsSinceEpoch;
    final maps = await db.query('transactions',
        where: 'date >= ? AND date <= ?', whereArgs: [start, end], orderBy: 'date DESC');
    return maps.map(m.Transaction.fromMap).toList();
  }
  static Future<void> insertTransaction(m.Transaction t) async =>
      (await instance).insert('transactions', t.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  static Future<void> deleteTransaction(String id) async =>
      (await instance).delete('transactions', where: 'id=?', whereArgs: [id]);

  // ── Budgets ───────────────────────────────────────────
  static Future<List<m.Budget>> getBudgets(int month, int year) async {
    final db = await instance;
    final maps = await db.query('budgets', where: 'month=? AND year=?', whereArgs: [month, year]);
    return maps.map(m.Budget.fromMap).toList();
  }
  static Future<void> insertBudget(m.Budget b) async =>
      (await instance).insert('budgets', b.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  static Future<void> deleteBudget(String id) async =>
      (await instance).delete('budgets', where: 'id=?', whereArgs: [id]);

  // ── Transfers ─────────────────────────────────────────
  static Future<List<m.Transfer>> getTransfers() async {
    final db = await instance;
    final maps = await db.query('transfers', orderBy: 'date DESC');
    return maps.map(m.Transfer.fromMap).toList();
  }
  static Future<void> insertTransfer(m.Transfer t) async =>
      (await instance).insert('transfers', t.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
}