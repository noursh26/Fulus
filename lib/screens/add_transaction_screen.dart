// lib/screens/add_transaction_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});
  @override State<AddTransactionScreen> createState() => _State();
}

class _State extends State<AddTransactionScreen> {
  TransactionType _type = TransactionType.expense;
  String? _categoryId;
  String? _accountId;
  final _amountCtrl = TextEditingController();
  final _descCtrl   = TextEditingController();
  DateTime _date    = DateTime.now();
  RecurringType _recurring = RecurringType.none;
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final p = context.read<AppProvider>();
    if (_accountId == null && p.accounts.isNotEmpty) {
      _accountId = p.accounts.first.id;
    }
  }

  void _resetFields() {
    _amountCtrl.clear();
    _descCtrl.clear();
    setState(() { _categoryId = null; _date = DateTime.now(); _recurring = RecurringType.none; });
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      showSnack(context, 'أدخل مبلغاً صحيحاً', emoji: '⚠️', isError: true); return;
    }
    if (_accountId == null) {
      showSnack(context, 'أضف حساباً أولاً', emoji: '⚠️', isError: true); return;
    }
    setState(() => _saving = true);
    final p = context.read<AppProvider>();
    final acc = p.accountById(_accountId!)!;
    final cats = kDefaultCategories.where((c) => c.type == _type).toList();
    final cat = cats.firstWhere((c) => c.id == (_categoryId ?? ''), orElse: () => cats.last);
    final tx = Transaction(
      id: const Uuid().v4(),
      accountId: _accountId!,
      categoryId: cat.id,
      amount: amount,
      type: _type,
      description: _descCtrl.text.trim(),
      date: _date,
      currency: acc.currency,
      recurring: _recurring,
    );
    await p.addTransaction(tx);
    _resetFields();
    setState(() => _saving = false);
    if (mounted) {
      showSnack(context, _type == TransactionType.income ? 'تمت إضافة الدخل بنجاح 🎉' : 'تم تسجيل المصروف',
        emoji: _type == TransactionType.income ? '💚' : '💸');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final selAcc = p.accounts.firstWhere((a) => a.id == (_accountId ?? ''), orElse: () => p.accounts.isNotEmpty ? p.accounts.first : Account(id:'',name:'',currency:'USD',balance:0,colorValue:0xFF10B981,createdAt:DateTime.now()));
    final sym = currencyByCode(selAcc.currency).symbol;

    return Scaffold(
      appBar: AppBar(title: const Text('معاملة جديدة'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ─── Type Toggle ──────────────────────────
          Container(
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.all(4),
            child: Row(children: TransactionType.values.map((t) {
              final sel = _type == t;
              final color = t == TransactionType.income ? AppTheme.green : AppTheme.red;
              return Expanded(child: GestureDetector(
                onTap: () => setState(() { _type = t; _categoryId = null; }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: sel ? color.withOpacity(0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: sel ? Border.all(color: color) : null,
                  ),
                  child: Text(t == TransactionType.expense ? '↓ مصروف' : '↑ دخل',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w800, color: sel ? color : Colors.white38)),
                ),
              ));
            }).toList()),
          ),
          const SizedBox(height: 20),

          // ─── Amount ───────────────────────────────
          Text('المبلغ', style: _labelStyle),
          const SizedBox(height: 8),
          TextField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, fontFamily: 'monospace'),
            decoration: InputDecoration(
              hintText: '0.00',
              prefixIcon: Padding(padding: const EdgeInsets.all(14), child: Text(sym, style: TextStyle(fontSize: 22, color: AppTheme.gold, fontWeight: FontWeight.w800))),
              prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            ),
          ),
          const SizedBox(height: 20),

          // ─── Category ─────────────────────────────
          Text('التصنيف', style: _labelStyle),
          const SizedBox(height: 10),
          CategoryGrid(type: _type, selected: _categoryId, onSelect: (id) => setState(() => _categoryId = id)),
          const SizedBox(height: 20),

          // ─── Account ──────────────────────────────
          Text('الحساب', style: _labelStyle),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _accountId,
            decoration: const InputDecoration(),
            dropdownColor: const Color(0xFF1A1A24),
            items: p.accounts.map((a) => DropdownMenuItem(value: a.id,
              child: Row(children: [
                Container(width: 12, height: 12, decoration: BoxDecoration(color: a.color, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text('${a.name} (${a.currency})'),
              ]),
            )).toList(),
            onChanged: (v) => setState(() => _accountId = v),
          ),
          const SizedBox(height: 20),

          // ─── Description ──────────────────────────
          Text('وصف (اختياري)', style: _labelStyle),
          const SizedBox(height: 8),
          TextField(controller: _descCtrl, maxLines: 1, decoration: const InputDecoration(hintText: 'مثال: فاتورة الكهرباء...')),
          const SizedBox(height: 20),

          // ─── Date ─────────────────────────────────
          Text('التاريخ', style: _labelStyle),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final d = await showDatePicker(context: context, initialDate: _date,
                firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 365)));
              if (d != null) setState(() => _date = d);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(color: const Color(0xFF1A1A24), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white12)),
              child: Row(children: [
                const Icon(Icons.calendar_today_rounded, size: 18, color: Colors.white54),
                const SizedBox(width: 10),
                Text(fmtDate(_date), style: const TextStyle(fontSize: 15)),
                const Spacer(),
                const Icon(Icons.arrow_drop_down_rounded, color: Colors.white38),
              ]),
            ),
          ),
          const SizedBox(height: 20),

          // ─── Recurring ────────────────────────────
          Text('تكرار', style: _labelStyle),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: RecurringType.values.map((r) {
              final sel = _recurring == r;
              final labels = {'none':'مرة واحدة','daily':'يومي','weekly':'أسبوعي','monthly':'شهري','yearly':'سنوي'};
              return Padding(padding: const EdgeInsets.only(left: 8),
                child: ChoiceChip(
                  label: Text(labels[r.name]!),
                  selected: sel,
                  onSelected: (_) => setState(() => _recurring = r),
                  selectedColor: AppTheme.gold.withOpacity(0.2),
                  side: BorderSide(color: sel ? AppTheme.gold : Colors.white12),
                  labelStyle: TextStyle(color: sel ? AppTheme.gold : Colors.white54, fontSize: 12),
                  backgroundColor: const Color(0xFF1A1A24),
                ),
              );
            }).toList()),
          ),
          const SizedBox(height: 32),

          // ─── Save Button ──────────────────────────
          ElevatedButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) : const Icon(Icons.save_rounded),
            label: Text(_saving ? 'جاري الحفظ...' : 'حفظ المعاملة'),
          ),
          const SizedBox(height: 40),
        ]),
      ),
    );
  }

  TextStyle get _labelStyle => const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white54, letterSpacing: 0.5);
}
