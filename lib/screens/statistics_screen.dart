// lib/screens/statistics_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _selectedPeriod = 0; // 0: هذا الشهر, 1: آخر 3 أشهر, 2: آخر 6 أشهر, 3: هذه السنة

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final stats = _calculateStats(p);

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('الإحصائيات'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _PeriodChip(label: 'هذا الشهر', selected: _selectedPeriod == 0, onTap: () => setState(() => _selectedPeriod = 0)),
                  _PeriodChip(label: '3 أشهر', selected: _selectedPeriod == 1, onTap: () => setState(() => _selectedPeriod = 1)),
                  _PeriodChip(label: '6 أشهر', selected: _selectedPeriod == 2, onTap: () => setState(() => _selectedPeriod = 2)),
                  _PeriodChip(label: 'هذه السنة', selected: _selectedPeriod == 3, onTap: () => setState(() => _selectedPeriod = 3)),
                ],
              ),
            ).animate().fadeIn(),

            const SizedBox(height: 24),

            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.arrow_downward_rounded,
                    label: 'إجمالي الدخل',
                    amount: stats['income']!,
                    currency: p.mainCurrency,
                    color: AppTheme.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.arrow_upward_rounded,
                    label: 'إجمالي المصروفات',
                    amount: stats['expense']!,
                    currency: p.mainCurrency,
                    color: AppTheme.red,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.account_balance_rounded,
                    label: 'صافي الفترة',
                    amount: stats['net']!,
                    currency: p.mainCurrency,
                    color: stats['net']! >= 0 ? AppTheme.green : AppTheme.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.receipt_long_rounded,
                    label: 'عدد المعاملات',
                    amount: stats['count']!,
                    currency: '',
                    color: AppTheme.blue,
                    isCount: true,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

            const SizedBox(height: 24),

            // Average Card
            _GlassCard(
              child: Row(
                children: [
                  _StatItem(
                    label: 'متوسط الدخل اليومي',
                    value: fmtAmount(stats['avgIncome']!, p.mainCurrency),
                    color: AppTheme.green,
                  ),
                  Container(width: 1, height: 40, color: Colors.white12),
                  _StatItem(
                    label: 'متوسط المصروف اليومي',
                    value: fmtAmount(stats['avgExpense']!, p.mainCurrency),
                    color: AppTheme.red,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

            const SizedBox(height: 24),

            // Top Categories
            const Text(
              'أعلى التصنيفات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            
            ...stats['topCategories'].entries.take(5).toList().asMap().entries.map((entry) {
              final cat = categoryById(entry.value.key);
              final amount = entry.value.value as double;
              final percentage = stats['expense']! > 0 ? (amount / stats['expense']! * 100) : 0.0;
              
              return _CategoryStatItem(
                emoji: cat?.emoji ?? '📦',
                name: cat?.nameAr ?? entry.value.key,
                amount: amount,
                percentage: percentage,
                currency: p.mainCurrency,
                color: cat?.color ?? Colors.grey,
                index: entry.key,
              );
            }).toList(),

            const SizedBox(height: 24),

            // Trend Chart
            const Text(
              'اتجاه المصروفات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            _GlassCard(
              child: SizedBox(
                height: 200,
                child: _buildTrendChart(p),
              ),
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _calculateStats(AppProvider p) {
    final now = DateTime.now();
    DateTime startDate;
    
    switch (_selectedPeriod) {
      case 1:
        startDate = DateTime(now.year, now.month - 2, 1);
        break;
      case 2:
        startDate = DateTime(now.year, now.month - 5, 1);
        break;
      case 3:
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        startDate = DateTime(now.year, now.month, 1);
    }

    final filteredTx = p.transactions.where((t) => t.date.isAfter(startDate)).toList();
    
    final income = filteredTx
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + p.convertToMainCurrency(t.amount, t.currency));
    
    final expense = filteredTx
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + p.convertToMainCurrency(t.amount, t.currency));

    final days = now.difference(startDate).inDays.clamp(1, 365);
    
    final categoryExpenses = <String, double>{};
    for (final tx in filteredTx.where((t) => t.type == TransactionType.expense)) {
      final catId = tx.categoryId ?? 'other_exp';
      categoryExpenses[catId] = (categoryExpenses[catId] ?? 0) + p.convertToMainCurrency(tx.amount, tx.currency);
    }
    
    final sortedCategories = categoryExpenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'income': income,
      'expense': expense,
      'net': income - expense,
      'count': filteredTx.length.toDouble(),
      'avgIncome': income / days,
      'avgExpense': expense / days,
      'topCategories': Map.fromEntries(sortedCategories),
    };
  }

  Widget _buildTrendChart(AppProvider p) {
    final now = DateTime.now();
    final months = _selectedPeriod == 0 ? 1 : _selectedPeriod == 1 ? 3 : _selectedPeriod == 2 ? 6 : 12;
    
    final data = List.generate(months.clamp(1, 12), (i) {
      final m = DateTime(now.year, now.month - (months - 1 - i));
      final txs = p.transactions.where((t) => t.date.month == m.month && t.date.year == m.year);
      final exp = txs.where((t) => t.type == TransactionType.expense).fold(0.0, (s, t) => s + t.amount);
      return FlSpot(i.toDouble(), exp);
    });

    if (data.isEmpty || data.every((d) => d.y == 0)) {
      return const Center(
        child: Text('لا توجد بيانات كافية', style: TextStyle(color: Colors.white54)),
      );
    }

    final maxY = data.fold(0.0, (m, d) => d.y > m ? d.y : m);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.white.withOpacity(0.05),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: data,
            isCurved: true,
            color: AppTheme.red,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.red.withOpacity(0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots.map((spot) => LineTooltipItem(
              fmtAmount(spot.y, p.mainCurrency),
              const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            )).toList(),
          ),
        ),
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PeriodChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.gold.withOpacity(0.2) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppTheme.gold : Colors.white12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppTheme.gold : Colors.white54,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final String currency;
  final Color color;
  final bool isCount;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.amount,
    required this.currency,
    required this.color,
    this.isCount = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(height: 12),
              Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
              const SizedBox(height: 4),
              Text(
                isCount ? amount.toInt().toString() : fmtAmount(amount, currency),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;

  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _CategoryStatItem extends StatelessWidget {
  final String emoji;
  final String name;
  final double amount;
  final double percentage;
  final String currency;
  final Color color;
  final int index;

  const _CategoryStatItem({
    required this.emoji,
    required this.name,
    required this.amount,
    required this.percentage,
    required this.currency,
    required this.color,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      fmtAmount(amount, currency),
                      style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(color: color, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (percentage / 100).clamp(0, 1),
              minHeight: 6,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 50 + 400).ms).slideX(begin: 0.05);
  }
}
