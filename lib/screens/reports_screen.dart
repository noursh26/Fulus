// lib/screens/reports_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../widgets/shared_widgets.dart';
import 'transaction_details_screen.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final months = ['يناير','فبراير','مارس','أبريل','مايو','يونيو','يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'];
    final monthLabel = '${months[p.selectedMonth.month - 1]} ${p.selectedMonth.year}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_rounded),
            tooltip: 'إحصائيات متقدمة',
            onPressed: () => Navigator.pushNamed(context, '/statistics'),
          ),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // ─── Month Selector ─────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: const Color(0xFF1A1A24), borderRadius: BorderRadius.circular(14)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            IconButton(icon: const Icon(Icons.chevron_left_rounded), onPressed: () => p.changeMonth(-1)),
            Text(monthLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            IconButton(icon: const Icon(Icons.chevron_right_rounded), onPressed: () => p.changeMonth(1)),
          ]),
        ),
        const SizedBox(height: 16),

        // ─── Summary Row ────────────────────────────
        Row(children: [
          Expanded(child: StatCard(label: 'دخل', amount: p.monthlyIncome, currency: p.mainCurrency, color: AppTheme.green, icon: Icons.trending_up_rounded)),
          const SizedBox(width: 10),
          Expanded(child: StatCard(label: 'مصاريف', amount: p.monthlyExpense, currency: p.mainCurrency, color: AppTheme.red, icon: Icons.trending_down_rounded)),
          const SizedBox(width: 10),
          Expanded(child: StatCard(label: 'صافي', amount: p.monthlySavings, currency: p.mainCurrency,
            color: p.monthlySavings >= 0 ? AppTheme.green : AppTheme.red, icon: Icons.account_balance_rounded)),
        ]),
        const SizedBox(height: 20),

        // ─── Pie Chart ──────────────────────────────
        if (p.expensesByCategory.isNotEmpty) ...[
          Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('توزيع المصاريف', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            SizedBox(height: 200, child: PieChart(PieChartData(
              sections: p.expensesByCategory.entries.map((e) {
                final cat = categoryById(e.key);
                final pct = e.value / p.monthlyExpense * 100;
                return PieChartSectionData(
                  value: e.value, title: '${pct.toStringAsFixed(0)}%',
                  color: cat?.color ?? Colors.grey,
                  radius: 70, titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                );
              }).toList(),
              sectionsSpace: 2, centerSpaceRadius: 45,
            ))),
            const SizedBox(height: 16),
            // Legend
            Wrap(spacing: 12, runSpacing: 8, children: p.expensesByCategory.entries.map((e) {
              final cat = categoryById(e.key);
              return Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: cat?.color ?? Colors.grey, shape: BoxShape.circle)),
                const SizedBox(width: 5),
                Text('${cat?.emoji ?? ''} ${cat?.nameAr ?? e.key}', style: const TextStyle(fontSize: 12, color: Colors.white60)),
              ]);
            }).toList()),
          ]))),
          const SizedBox(height: 16),
        ],

        // ─── Bar Chart (last 6 months) ──────────────
        Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('آخر 6 أشهر', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          SizedBox(height: 180, child: _BarChart(p: p)),
        ]))),
        const SizedBox(height: 16),

        // ─── Monthly Transactions ───────────────────
        const SectionHeader(title: 'معاملات الشهر'),
        ...p.monthlyTransactions.asMap().entries.map((e) => TxItem(
          tx: e.value,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TransactionDetailsScreen(transaction: e.value),
            ),
          ),
        ).animate().fadeIn(delay: (e.key * 30).ms)),
        const SizedBox(height: 120),
      ]),
    );
  }
}

class _BarChart extends StatelessWidget {
  final AppProvider p;
  const _BarChart({required this.p});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final data = List.generate(6, (i) {
      final m = DateTime(now.year, now.month - 5 + i);
      final txs = p.transactions.where((t) => t.date.month == m.month && t.date.year == m.year);
      final inc = txs.where((t) => t.type == TransactionType.income).fold(0.0, (s, t) => s + t.amount);
      final exp = txs.where((t) => t.type == TransactionType.expense).fold(0.0, (s, t) => s + t.amount);
      return (month: m, income: inc, expense: exp);
    });

    final maxY = data.fold(0.0, (m, d) => [m, d.income, d.expense].reduce((a, b) => a > b ? a : b));
    final months = ['يناير','فبراير','مارس','أبريل','مايو','يونيو','يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'];

    return BarChart(BarChartData(
      maxY: maxY * 1.2,
      barGroups: data.asMap().entries.map((e) => BarChartGroupData(x: e.key, barRods: [
        BarChartRodData(toY: e.value.income, color: AppTheme.green, width: 10, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
        BarChartRodData(toY: e.value.expense, color: AppTheme.red.withOpacity(0.7), width: 10, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
      ])).toList(),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 26,
          getTitlesWidget: (v, _) => Text(months[data[v.toInt()].month.month - 1].substring(0, 3),
            style: const TextStyle(fontSize: 10, color: Colors.white38)))),
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: FlGridData(show: false),
      borderData: FlBorderData(show: false),
    ));
  }
}
