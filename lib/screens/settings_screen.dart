// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../utils/excel_export.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _exporting = false;

  Future<void> _exportToExcel() async {
    setState(() => _exporting = true);
    try {
      final p = context.read<AppProvider>();
      await ExcelExportService.exportAndShare(
        transactions: p.transactions,
        accounts: p.accounts,
      );
      if (mounted) {
        showSnack(context, 'تم تصدير البيانات بنجاح', emoji: '📊');
      }
    } catch (e) {
      if (mounted) {
        showSnack(context, 'فشل في التصدير: $e', emoji: '❌', isError: true);
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _exportMonthly() async {
    final p = context.read<AppProvider>();
    setState(() => _exporting = true);
    try {
      final path = await ExcelExportService.exportMonthlyReport(
        transactions: p.transactions,
        accounts: p.accounts,
        month: p.selectedMonth.month,
        year: p.selectedMonth.year,
      );
      if (mounted) {
        showSnack(context, 'تم حفظ التقرير: $path', emoji: '📄');
      }
    } catch (e) {
      if (mounted) {
        showSnack(context, 'فشل في التصدير: $e', emoji: '❌', isError: true);
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // قسم المظهر
          _SectionTitle(title: 'المظهر', icon: Icons.palette_outlined),
          _SettingsTile(
            icon: Icons.dark_mode_rounded,
            title: 'الوضع الداكن',
            subtitle: p.isDark ? 'مفعّل' : 'معطّل',
            trailing: Switch(
              value: p.isDark,
              onChanged: (_) => p.toggleTheme(),
              activeColor: AppTheme.gold,
            ),
          ),
          const SizedBox(height: 24),

          // قسم العملة
          _SectionTitle(title: 'العملة الرئيسية', icon: Icons.attach_money_rounded),
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A24),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: kCurrencies.take(9).map((cur) => _CurrencyTile(
                currency: cur,
                selected: p.mainCurrency == cur.code,
                onTap: () => p.setMainCurrency(cur.code),
              )).toList(),
            ),
          ),
          TextButton(
            onPressed: () => _showAllCurrencies(context, p),
            child: const Text('عرض جميع العملات...'),
          ),
          const SizedBox(height: 24),

          // قسم التصدير
          _SectionTitle(title: 'تصدير البيانات', icon: Icons.download_rounded),
          const SizedBox(height: 8),
          _ActionCard(
            icon: Icons.table_chart_rounded,
            iconColor: const Color(0xFF10B981),
            title: 'تصدير إلى Excel',
            subtitle: 'تصدير جميع المعاملات والحسابات',
            loading: _exporting,
            onTap: _exporting ? null : _exportToExcel,
          ),
          const SizedBox(height: 12),
          _ActionCard(
            icon: Icons.calendar_month_rounded,
            iconColor: const Color(0xFF3B82F6),
            title: 'تصدير تقرير الشهر',
            subtitle: 'تصدير معاملات الشهر الحالي',
            loading: _exporting,
            onTap: _exporting ? null : _exportMonthly,
          ),
          const SizedBox(height: 24),

          // قسم البيانات
          _SectionTitle(title: 'البيانات', icon: Icons.storage_rounded),
          const SizedBox(height: 8),
          _ActionCard(
            icon: Icons.analytics_rounded,
            iconColor: AppTheme.purple,
            title: 'إحصائيات متقدمة',
            subtitle: 'تحليل مفصل للمصاريف والدخل',
            onTap: () => Navigator.pushNamed(context, '/statistics'),
          ),
          const SizedBox(height: 12),
          _ActionCard(
            icon: Icons.currency_exchange_rounded,
            iconColor: AppTheme.cyan,
            title: 'محول العملات',
            subtitle: 'تحويل بين ${kCurrencies.length} عملة',
            onTap: () => Navigator.pushNamed(context, '/converter'),
          ),
          const SizedBox(height: 12),
          _ActionCard(
            icon: Icons.tune_rounded,
            iconColor: AppTheme.orange,
            title: 'أسعار الصرف المخصصة',
            subtitle: p.customExchangeRates.isEmpty 
                ? 'استخدم الأسعار الافتراضية'
                : '${p.customExchangeRates.length} سعر مخصص',
            onTap: () => Navigator.pushNamed(context, '/exchange-rates'),
          ),
          const SizedBox(height: 12),
          _ActionCard(
            icon: Icons.info_outline_rounded,
            iconColor: Colors.white54,
            title: 'ملخص الحساب',
            subtitle: '${p.transactions.length} معاملة • ${p.accounts.length} حساب',
            onTap: () => _showStats(context, p),
          ),
          const SizedBox(height: 32),

          // معلومات التطبيق
          Center(
            child: Column(
              children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.gold, AppTheme.gold2],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text('💰', style: TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Fulus - فُلُس', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                Text('الإصدار 2.1.0', style: TextStyle(color: Colors.white38, fontSize: 12)),
                const SizedBox(height: 4),
                Text('مدير المصاري الذكي الاحترافي', style: TextStyle(color: Colors.white24, fontSize: 11)),
                const SizedBox(height: 8),
                Text('29 عملة • أسعار صرف مخصصة • تصميم زجاجي', style: TextStyle(color: AppTheme.gold.withOpacity(0.5), fontSize: 10)),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showAllCurrencies(BuildContext ctx, AppProvider p) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: const Color(0xFF111118),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(width: 36, height: 4,
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 16),
                  const Text('اختر العملة الرئيسية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: kCurrencies.length,
                itemBuilder: (_, i) {
                  final cur = kCurrencies[i];
                  final selected = p.mainCurrency == cur.code;
                  return ListTile(
                    onTap: () {
                      p.setMainCurrency(cur.code);
                      Navigator.pop(ctx);
                      showSnack(ctx, 'تم تغيير العملة إلى ${cur.nameAr}', emoji: cur.flag);
                    },
                    leading: Text(cur.flag, style: const TextStyle(fontSize: 24)),
                    title: Text(cur.nameAr, style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: selected ? AppTheme.gold : Colors.white,
                    )),
                    subtitle: Text('${cur.code} • ${cur.symbol}', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                    trailing: selected
                        ? const Icon(Icons.check_circle_rounded, color: AppTheme.gold)
                        : Text('${cur.rateToUSD}', style: const TextStyle(color: Colors.white24, fontSize: 11)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStats(BuildContext ctx, AppProvider p) {
    final totalIncome = p.transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (s, t) => s + t.amount);
    final totalExpense = p.transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (s, t) => s + t.amount);
    
    showModalBottomSheet(
      context: ctx,
      backgroundColor: const Color(0xFF111118),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 36, height: 4,
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          const Text('📊 إحصائيات شاملة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 24),
          _StatRow(label: 'عدد الحسابات', value: '${p.accounts.length}'),
          _StatRow(label: 'عدد المعاملات', value: '${p.transactions.length}'),
          _StatRow(label: 'إجمالي الدخل', value: fmtAmount(totalIncome, p.mainCurrency), color: AppTheme.green),
          _StatRow(label: 'إجمالي المصروفات', value: fmtAmount(totalExpense, p.mainCurrency), color: AppTheme.red),
          _StatRow(label: 'إجمالي الرصيد', value: fmtAmount(p.totalBalance, p.mainCurrency), color: AppTheme.gold),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      Icon(icon, size: 18, color: AppTheme.gold),
      const SizedBox(width: 8),
      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.gold)),
    ]),
  );
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  const _SettingsTile({required this.icon, required this.title, required this.subtitle, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    tileColor: const Color(0xFF1A1A24),
    leading: Container(
      width: 42, height: 42,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.white54),
    ),
    title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
    subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.white38)),
    trailing: trailing,
  );
}

class _CurrencyTile extends StatelessWidget {
  final Currency currency;
  final bool selected;
  final VoidCallback onTap;
  const _CurrencyTile({required this.currency, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    tileColor: selected ? AppTheme.gold.withOpacity(0.1) : Colors.transparent,
    leading: Text(currency.flag, style: const TextStyle(fontSize: 22)),
    title: Text(currency.nameAr, style: TextStyle(
      fontSize: 14, fontWeight: FontWeight.w600,
      color: selected ? AppTheme.gold : Colors.white70,
    )),
    trailing: selected
        ? const Icon(Icons.check_circle_rounded, color: AppTheme.gold, size: 20)
        : Text(currency.code, style: const TextStyle(fontSize: 12, color: Colors.white38)),
  );
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool loading;
  final VoidCallback? onTap;
  const _ActionCard({
    required this.icon, required this.iconColor,
    required this.title, required this.subtitle,
    this.loading = false, this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A24),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: loading
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54),
                )
              : Icon(icon, color: iconColor),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.white38)),
          ],
        )),
        Icon(Icons.chevron_right_rounded, color: Colors.white24),
      ]),
    ),
  );
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _StatRow({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: Colors.white54)),
      Text(value, style: TextStyle(fontWeight: FontWeight.w700, color: color ?? Colors.white, fontFamily: 'monospace')),
    ]),
  );
}
