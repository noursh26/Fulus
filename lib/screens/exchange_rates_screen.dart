// lib/screens/exchange_rates_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class ExchangeRatesScreen extends StatefulWidget {
  const ExchangeRatesScreen({super.key});
  @override State<ExchangeRatesScreen> createState() => _State();
}

class _State extends State<ExchangeRatesScreen> {
  final _rateCtrl = TextEditingController();
  String? _selectedFrom;
  String? _selectedTo;
  bool _loading = false;

  @override
  void dispose() {
    _rateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    final p = ctx.watch<AppProvider>();
    final mainCur = p.mainCurrency;

    return Scaffold(
      appBar: AppBar(
        title: const Text('أسعار الصرف المخصصة'),
        centerTitle: true,
        actions: [
          if (p.customExchangeRates.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'إعادة تعيين الكل',
              onPressed: () => _confirmReset(ctx, p),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── Info Card ─────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.purple.withOpacity(0.3), AppTheme.blue.withOpacity(0.3)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.purple.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.info_outline_rounded, color: AppTheme.purple, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'تخصيص أسعار الصرف',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'العملة الرئيسية: ${currencyByCode(mainCur).nameAr} ($mainCur)',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ─── Add Custom Rate Section ───────────────────
          const Text('إضافة سعر صرف جديد', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 12),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                // From Currency
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedFrom,
                        decoration: InputDecoration(
                          labelText: 'من عملة',
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        items: kCurrencies.map((c) => DropdownMenuItem(
                          value: c.code,
                          child: Row(
                            children: [
                              Text(c.flag, style: const TextStyle(fontSize: 18)),
                              const SizedBox(width: 8),
                              Text('${c.nameAr} (${c.code})', style: const TextStyle(fontSize: 13)),
                            ],
                          ),
                        )).toList(),
                        onChanged: (v) => setState(() => _selectedFrom = v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.gold.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_forward_rounded, color: AppTheme.gold),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedTo,
                        decoration: InputDecoration(
                          labelText: 'إلى عملة',
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        items: kCurrencies.map((c) => DropdownMenuItem(
                          value: c.code,
                          child: Row(
                            children: [
                              Text(c.flag, style: const TextStyle(fontSize: 18)),
                              const SizedBox(width: 8),
                              Text('${c.nameAr} (${c.code})', style: const TextStyle(fontSize: 13)),
                            ],
                          ),
                        )).toList(),
                        onChanged: (v) => setState(() => _selectedTo = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Rate Input
                TextField(
                  controller: _rateCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'سعر الصرف (كم يساوي 1 ${_selectedFrom ?? '...'} بالـ ${_selectedTo ?? '...'}؟)',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calculate_rounded, color: Colors.white38),
                      onPressed: _showDefaultRate,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Add Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _canAdd() ? () => _addRate(ctx, p) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.gold,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _loading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                        : const Text('إضافة السعر', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // ─── Custom Rates List ─────────────────────────
          Row(
            children: [
              const Text('الأسعار المخصصة', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const Spacer(),
              if (p.customExchangeRates.isNotEmpty)
                Text('${p.customExchangeRates.length} سعر', style: TextStyle(color: Colors.white38, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),

          if (p.customExchangeRates.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  Icon(Icons.currency_exchange_rounded, size: 48, color: Colors.white24),
                  const SizedBox(height: 16),
                  const Text('لم يتم إضافة أسعار مخصصة', style: TextStyle(color: Colors.white38)),
                  const SizedBox(height: 8),
                  Text('يتم استخدام الأسعار الافتراضية تلقائياً', style: TextStyle(color: Colors.white24, fontSize: 12)),
                ],
              ),
            )
          else
            ...p.customExchangeRates.entries.map((e) {
              final parts = e.key.split('_');
              final fromCur = currencyByCode(parts[0]);
              final toCur = currencyByCode(parts[1]);
              final rate = e.value;
              final defaultRate = fromCur.rateToUSD / toCur.rateToUSD;
              final isDifferent = (rate - defaultRate).abs() > 0.001;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDifferent ? AppTheme.orange.withOpacity(0.5) : Colors.white10,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(fromCur.flag, style: const TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 8),
                    Text(fromCur.code, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.white38),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(toCur.flag, style: const TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 8),
                    Text(toCur.code, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        rate.toStringAsFixed(4),
                        style: TextStyle(color: AppTheme.green, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.red),
                      onPressed: () => _deleteRate(ctx, p, parts[0], parts[1]),
                    ),
                  ],
                ),
              );
            }),

          const SizedBox(height: 32),

          // ─── Default Rates Reference ───────────────────
          const Text('الأسعار الافتراضية (للرجوع إليها)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                Text(
                  'الأسعار بالنسبة للدولار الأمريكي (USD)',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: kCurrencies.take(15).map((c) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${c.flag} ${c.code}: ${c.rateToUSD.toStringAsFixed(c.rateToUSD >= 100 ? 0 : 2)}',
                      style: const TextStyle(fontSize: 11),
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _canAdd() {
    return _selectedFrom != null &&
        _selectedTo != null &&
        _selectedFrom != _selectedTo &&
        _rateCtrl.text.isNotEmpty &&
        double.tryParse(_rateCtrl.text) != null &&
        !_loading;
  }

  void _showDefaultRate() {
    if (_selectedFrom == null || _selectedTo == null) return;
    final from = currencyByCode(_selectedFrom!);
    final to = currencyByCode(_selectedTo!);
    final defaultRate = from.rateToUSD / to.rateToUSD;
    _rateCtrl.text = defaultRate.toStringAsFixed(6);
    setState(() {});
  }

  Future<void> _addRate(BuildContext ctx, AppProvider p) async {
    final rate = double.parse(_rateCtrl.text);
    setState(() => _loading = true);
    await p.setCustomExchangeRate(_selectedFrom!, _selectedTo!, rate);
    if (mounted) {
      showSnack(ctx, 'تم إضافة سعر الصرف', emoji: '💱');
      _rateCtrl.clear();
      setState(() {
        _selectedFrom = null;
        _selectedTo = null;
        _loading = false;
      });
    }
  }

  void _deleteRate(BuildContext ctx, AppProvider p, String from, String to) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            const Icon(Icons.delete_rounded, color: AppTheme.red, size: 48),
            const SizedBox(height: 16),
            const Text('حذف سعر الصرف؟', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('سيتم العودة للسعر الافتراضي', style: TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('إلغاء'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await p.removeCustomExchangeRate(from, to);
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        showSnack(ctx, 'تم حذف سعر الصرف', emoji: '🗑️');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('حذف'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmReset(BuildContext ctx, AppProvider p) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            const Icon(Icons.refresh_rounded, color: AppTheme.orange, size: 48),
            const SizedBox(height: 16),
            const Text('إعادة تعيين الكل؟', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('سيتم حذف جميع الأسعار المخصصة', style: TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('إلغاء'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await p.resetAllExchangeRates();
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        showSnack(ctx, 'تم إعادة تعيين الأسعار', emoji: '🔄');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.orange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('إعادة تعيين'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
