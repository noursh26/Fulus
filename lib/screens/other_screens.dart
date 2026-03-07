// lib/screens/accounts_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('الحسابات'), centerTitle: true),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.gold, foregroundColor: const Color(0xFF1A1000),
        onPressed: () => _showAddDialog(context, p),
        child: const Icon(Icons.add_rounded),
      ),
      body: p.accounts.isEmpty
          ? EmptyState(emoji: '🏦', message: 'لا يوجد حسابات\nاضغط ＋ لإضافة حساب', buttonLabel: 'إضافة حساب', onButton: () => _showAddDialog(context, p))
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: p.accounts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _AccountTile(account: p.accounts[i], onDelete: () async {
                final name = p.accounts[i].name;
                await p.deleteAccount(p.accounts[i].id);
                if (context.mounted) showSnack(context, 'تم حذف حساب "$name"', emoji: '🗑️');
              }),
            ),
    );
  }

  void _showAddDialog(BuildContext ctx, AppProvider p) {
    final nameCtrl = TextEditingController();
    final balCtrl = TextEditingController();
    String currency = 'USD';
    int colorVal = 0xFF10B981;
    final colors = [0xFF10B981, 0xFF3B82F6, 0xFF8B5CF6, 0xFFF59E0B, 0xFFEF4444, 0xFFEC4899, 0xFFF0C060, 0xFF64748B];

    showModalBottomSheet(
      context: ctx, isScrollControlled: true, backgroundColor: const Color(0xFF111118),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => StatefulBuilder(builder: (ctx2, ss) => Padding(
        padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(ctx2).viewInsets.bottom + 40),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          const Text('حساب جديد', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم الحساب', hintText: 'مثال: المحفظة الرئيسية')),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: currency, dropdownColor: const Color(0xFF1A1A24),
            decoration: const InputDecoration(labelText: 'العملة'),
            items: kCurrencies.map((c) => DropdownMenuItem(value: c.code, child: Text('${c.flag} ${c.nameAr} (${c.code})'))).toList(),
            onChanged: (v) => ss(() => currency = v!),
          ),
          const SizedBox(height: 12),
          TextField(controller: balCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            decoration: const InputDecoration(labelText: 'الرصيد الابتدائي')),
          const SizedBox(height: 12),
          const Text('اللون', style: TextStyle(fontSize: 12, color: Colors.white54, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(children: colors.map((c) => GestureDetector(
            onTap: () => ss(() => colorVal = c),
            child: Container(
              width: 32, height: 32, margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(color: Color(c), shape: BoxShape.circle,
                border: colorVal == c ? Border.all(color: Colors.white, width: 3) : null),
            ),
          )).toList()),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) { showSnack(ctx, 'أدخل اسم الحساب', emoji: '⚠️', isError: true); return; }
              final acc = Account(id: const Uuid().v4(), name: nameCtrl.text.trim(), currency: currency,
                balance: double.tryParse(balCtrl.text) ?? 0, colorValue: colorVal, createdAt: DateTime.now());
              await p.addAccount(acc);
              Navigator.pop(ctx2);
              if (ctx.mounted) showSnack(ctx, 'تم إضافة "${acc.name}" بنجاح', emoji: '🏦');
            },
            child: const Text('حفظ الحساب'),
          ),
        ]),
      )),
    );
  }
}

class _AccountTile extends StatelessWidget {
  final Account account;
  final VoidCallback onDelete;
  const _AccountTile({required this.account, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final cur = currencyByCode(account.currency);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A24),
        borderRadius: BorderRadius.circular(20),
        border: Border(right: BorderSide(color: account.color, width: 4)),
      ),
      child: Row(children: [
        Container(width: 52, height: 52, decoration: BoxDecoration(color: account.color, borderRadius: BorderRadius.circular(14)),
          child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(account.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          Text('${cur.flag} ${account.currency}', style: const TextStyle(color: Colors.white38, fontSize: 12)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(fmtAmount(account.balance, account.currency),
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: account.balance >= 0 ? AppTheme.green : AppTheme.red, fontFamily: 'monospace')),
          GestureDetector(onTap: onDelete, child: const Text('حذف', style: TextStyle(fontSize: 11, color: AppTheme.red))),
        ]),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────
// lib/screens/transactions_screen.dart
class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});
  @override State<TransactionsScreen> createState() => _TxState();
}
class _TxState extends State<TransactionsScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final txs = _filter == 'all' ? p.transactions
        : _filter == 'income' ? p.transactions.where((t) => t.type == TransactionType.income).toList()
        : p.transactions.where((t) => t.type == TransactionType.expense).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('المعاملات'), centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.add_rounded), onPressed: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTransactionScreen())))]),
      body: Column(children: [
        // Filter
        Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(children: [
            _chip('all', 'الكل', Colors.white),
            const SizedBox(width: 8),
            _chip('expense', 'مصاريف', AppTheme.red),
            const SizedBox(width: 8),
            _chip('income', 'إيرادات', AppTheme.green),
          ])),
        Expanded(child: txs.isEmpty
          ? EmptyState(emoji: '🧾', message: 'لا يوجد معاملات', buttonLabel: 'إضافة معاملة',
              onButton: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTransactionScreen())))
          : ListView.builder(
              itemCount: txs.length,
              itemBuilder: (_, i) => TxItem(tx: txs[i], onTap: () => _confirmDelete(context, p, txs[i])),
            )),
      ]),
    );
  }

  Widget _chip(String val, String label, Color color) => GestureDetector(
    onTap: () => setState(() => _filter = val),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _filter == val ? color.withOpacity(0.2) : const Color(0xFF1A1A24),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _filter == val ? color : Colors.white12),
      ),
      child: Text(label, style: TextStyle(color: _filter == val ? color : Colors.white38, fontSize: 13, fontWeight: FontWeight.w700)),
    ),
  );

  void _confirmDelete(BuildContext ctx, AppProvider p, tx) {
    showDialog(context: ctx, builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF1A1A24),
      title: const Text('حذف المعاملة؟'),
      content: const Text('لا يمكن التراجع عن هذا الإجراء'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
        TextButton(onPressed: () async {
          Navigator.pop(ctx);
          await p.deleteTransaction(tx);
          if (ctx.mounted) showSnack(ctx, 'تم حذف المعاملة', emoji: '🗑️');
        }, child: const Text('حذف', style: TextStyle(color: AppTheme.red))),
      ],
    ));
  }
}

// ─────────────────────────────────────────────────────────
// lib/screens/budget_screen.dart
class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('الميزانية'), centerTitle: true),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.gold, foregroundColor: const Color(0xFF1A1000),
        onPressed: () => _showAdd(context, p),
        child: const Icon(Icons.add_rounded),
      ),
      body: p.budgets.isEmpty
          ? EmptyState(emoji: '🎯', message: 'لا يوجد ميزانية\nاضغط ＋ لإضافة ميزانية')
          : ListView(padding: const EdgeInsets.all(16), children: p.budgets.map((b) {
              final cat = categoryById(b.categoryId);
              final spent = p.spentForCategory(b.categoryId);
              final pct = (spent / b.amount).clamp(0.0, 1.0);
              final over = spent > b.amount;
              final color = over ? AppTheme.red : pct > 0.75 ? AppTheme.gold : AppTheme.green;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(padding: const EdgeInsets.all(18), child: Column(children: [
                  Row(children: [
                    Text(cat?.emoji ?? '📦', style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(cat?.nameAr ?? b.categoryId, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                      Text('${fmtAmount(spent, p.mainCurrency)} / ${fmtAmount(b.amount, p.mainCurrency)}',
                        style: const TextStyle(color: Colors.white38, fontSize: 12)),
                    ])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('${(pct * 100).toInt()}%', style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 16)),
                      GestureDetector(onTap: () async {
                        await p.deleteBudget(b.id);
                        if (context.mounted) showSnack(context, 'تم حذف ميزانية "${cat?.nameAr}"', emoji: '🗑️');
                      }, child: const Text('حذف', style: TextStyle(fontSize: 11, color: AppTheme.red))),
                    ]),
                  ]),
                  const SizedBox(height: 10),
                  ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(
                    value: pct, minHeight: 7,
                    backgroundColor: color.withOpacity(0.15),
                    valueColor: AlwaysStoppedAnimation(color),
                  )),
                  if (over) ...[
                    const SizedBox(height: 6),
                    Row(children: [const Icon(Icons.warning_rounded, color: AppTheme.red, size: 14), const SizedBox(width: 4),
                      Text('تجاوزت الميزانية بـ ${fmtAmount(spent - b.amount, p.mainCurrency)}', style: const TextStyle(color: AppTheme.red, fontSize: 12))]),
                  ],
                ])),
              );
            }).toList()),
    );
  }

  void _showAdd(BuildContext ctx, AppProvider p) {
    String? catId;
    final amtCtrl = TextEditingController();
    showModalBottomSheet(
      context: ctx, isScrollControlled: true, backgroundColor: const Color(0xFF111118),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => StatefulBuilder(builder: (ctx2, ss) => Padding(
        padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(ctx2).viewInsets.bottom + 40),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          const Text('ميزانية جديدة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          CategoryGrid(type: TransactionType.expense, selected: catId, onSelect: (id) => ss(() => catId = id)),
          const SizedBox(height: 16),
          TextField(controller: amtCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'المبلغ الشهري')),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              if (catId == null) { showSnack(ctx, 'اختر تصنيفاً', emoji: '⚠️', isError: true); return; }
              final amt = double.tryParse(amtCtrl.text);
              if (amt == null || amt <= 0) { showSnack(ctx, 'أدخل مبلغاً صحيحاً', emoji: '⚠️', isError: true); return; }
              final cat = categoryById(catId);
              await p.addBudget(Budget(id: const Uuid().v4(), categoryId: catId!, amount: amt,
                month: DateTime.now().month, year: DateTime.now().year));
              Navigator.pop(ctx2);
              if (ctx.mounted) showSnack(ctx, 'تم حفظ ميزانية "${cat?.nameAr}" بنجاح', emoji: '🎯');
            },
            child: const Text('حفظ الميزانية'),
          ),
        ]),
      )),
    );
  }
}

// ─────────────────────────────────────────────────────────
// lib/screens/transfer_screen.dart
class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});
  @override State<TransferScreen> createState() => _TransferState();
}
class _TransferState extends State<TransferScreen> {
  String? _fromId, _toId;
  final _amtCtrl = TextEditingController();
  final _rateCtrl = TextEditingController(text: '1.0');
  final _noteCtrl = TextEditingController();
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final p = context.read<AppProvider>();
    if (p.accounts.length >= 2 && _fromId == null) {
      _fromId = p.accounts[0].id;
      _toId   = p.accounts[1].id;
    }
  }

  bool get _diffCurrency {
    final p = context.read<AppProvider>();
    final from = p.accountById(_fromId ?? '');
    final to   = p.accountById(_toId ?? '');
    return from != null && to != null && from.currency != to.currency;
  }

  Future<void> _save() async {
    final p = context.read<AppProvider>();
    if (_fromId == _toId) { showSnack(context, 'اختر حسابين مختلفين', emoji: '⚠️', isError: true); return; }
    final amt  = double.tryParse(_amtCtrl.text);
    if (amt == null || amt <= 0) { showSnack(context, 'أدخل مبلغاً صحيحاً', emoji: '⚠️', isError: true); return; }
    final rate = double.tryParse(_rateCtrl.text) ?? 1.0;
    setState(() => _saving = true);
    await p.addTransfer(Transfer(id: const Uuid().v4(), fromAccountId: _fromId!, toAccountId: _toId!,
      amount: amt, convertedAmount: amt * rate, exchangeRate: rate, note: _noteCtrl.text.trim(), date: DateTime.now()));
    _amtCtrl.clear(); _noteCtrl.clear(); _rateCtrl.text = '1.0';
    setState(() => _saving = false);
    if (mounted) {
      showSnack(context, 'تم التحويل بنجاح', emoji: '↔️');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final items = p.accounts.map((a) => DropdownMenuItem(value: a.id, child: Row(children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: a.color, shape: BoxShape.circle)),
      const SizedBox(width: 8),
      Text('${a.name} (${fmtAmount(a.balance, a.currency)})'),
    ]))).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('تحويل بين الحسابات'), centerTitle: true),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('من حساب', style: TextStyle(fontSize: 12, color: Colors.white54, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(value: _fromId, dropdownColor: const Color(0xFF1A1A24'),
          decoration: const InputDecoration(), items: items, onChanged: (v) => setState(() => _fromId = v)),
        const SizedBox(height: 12),
        Center(child: GestureDetector(
          onTap: () => setState(() { final t = _fromId; _fromId = _toId; _toId = t; }),
          child: Container(width: 40, height: 40, decoration: BoxDecoration(
            color: const Color(0xFF1A1A24), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
            child: const Icon(Icons.swap_vert_rounded, color: Colors.white54)),
        )),
        const SizedBox(height: 12),
        const Text('إلى حساب', style: TextStyle(fontSize: 12, color: Colors.white54, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(value: _toId, dropdownColor: const Color(0xFF1A1A24),
          decoration: const InputDecoration(), items: items, onChanged: (v) => setState(() => _toId = v)),
        const SizedBox(height: 20),
        const Text('المبلغ', style: TextStyle(fontSize: 12, color: Colors.white54, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextField(controller: _amtCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(hintText: '0.00')),
        if (_diffCurrency) ...[
          const SizedBox(height: 12),
          const Text('سعر الصرف', style: TextStyle(fontSize: 12, color: Colors.white54, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextField(controller: _rateCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
        ],
        const SizedBox(height: 12),
        const Text('ملاحظة', style: TextStyle(fontSize: 12, color: Colors.white54, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextField(controller: _noteCtrl, decoration: const InputDecoration(hintText: 'اختياري')),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: _saving ? null : _save,
          icon: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) : const Icon(Icons.swap_horiz_rounded),
          label: Text(_saving ? 'جاري التحويل...' : 'تحويل'),
        ),
      ])),
    );
  }
}
