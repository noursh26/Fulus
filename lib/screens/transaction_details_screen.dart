// lib/screens/transaction_details_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import 'edit_transaction_screen.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final Transaction transaction;
  
  const TransactionDetailsScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final tx = p.getTransactionById(transaction.id) ?? transaction;
    final cat = categoryById(tx.categoryId);
    final acc = p.accountById(tx.accountId);
    final isIncome = tx.type == TransactionType.income;
    final color = isIncome ? AppTheme.green : AppTheme.red;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: CustomScrollView(
        slivers: [
          // Header with gradient
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppTheme.darkBg,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_rounded, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.edit_rounded, size: 20),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditTransactionScreen(transaction: tx),
                  ),
                ),
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete_rounded, size: 20, color: AppTheme.red),
                ),
                onPressed: () => _confirmDelete(context, p, tx),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      color.withOpacity(0.3),
                      AppTheme.darkBg,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Category Icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: (cat?.color ?? color).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: (cat?.color ?? color).withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            cat?.emoji ?? (isIncome ? '💰' : '💸'),
                            style: const TextStyle(fontSize: 36),
                          ),
                        ),
                      ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
                      const SizedBox(height: 16),
                      // Amount
                      Text(
                        '${isIncome ? '+' : '-'}${fmtAmount(tx.amount, tx.currency)}',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: color,
                          fontFamily: 'monospace',
                        ),
                      ).animate().fadeIn(delay: 100.ms),
                      const SizedBox(height: 8),
                      // Category name
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          cat?.nameAr ?? (isIncome ? 'دخل' : 'مصروف'),
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Info Card
                  _GlassCard(
                    child: Column(
                      children: [
                        _DetailRow(
                          icon: Icons.calendar_today_rounded,
                          label: 'التاريخ',
                          value: fmtFullDate(tx.date),
                        ),
                        const Divider(color: Colors.white12, height: 24),
                        _DetailRow(
                          icon: Icons.access_time_rounded,
                          label: 'الوقت',
                          value: '${tx.date.hour.toString().padLeft(2, '0')}:${tx.date.minute.toString().padLeft(2, '0')}',
                        ),
                        const Divider(color: Colors.white12, height: 24),
                        _DetailRow(
                          icon: Icons.account_balance_wallet_rounded,
                          label: 'الحساب',
                          value: acc?.name ?? 'غير محدد',
                          valueColor: acc?.color,
                        ),
                        const Divider(color: Colors.white12, height: 24),
                        _DetailRow(
                          icon: Icons.attach_money_rounded,
                          label: 'العملة',
                          value: '${currencyByCode(tx.currency).flag} ${currencyByCode(tx.currency).nameAr}',
                        ),
                        if (tx.recurring != RecurringType.none) ...[
                          const Divider(color: Colors.white12, height: 24),
                          _DetailRow(
                            icon: Icons.repeat_rounded,
                            label: 'التكرار',
                            value: _getRecurringLabel(tx.recurring),
                          ),
                        ],
                      ],
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                  
                  const SizedBox(height: 16),
                  
                  // Description
                  if (tx.description.isNotEmpty)
                    _GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.description_rounded, color: AppTheme.gold, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'الوصف',
                                style: TextStyle(
                                  color: AppTheme.gold,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            tx.description,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                  
                  if (tx.note != null && tx.note!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.note_rounded, color: AppTheme.blue, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'ملاحظات',
                                style: TextStyle(
                                  color: AppTheme.blue,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            tx.note!,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
                  ],
                  
                  if (tx.location != null && tx.location!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _GlassCard(
                      child: _DetailRow(
                        icon: Icons.location_on_rounded,
                        label: 'الموقع',
                        value: tx.location!,
                      ),
                    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
                  ],
                  
                  if (tx.payee != null && tx.payee!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _GlassCard(
                      child: _DetailRow(
                        icon: Icons.person_rounded,
                        label: 'المستفيد',
                        value: tx.payee!,
                      ),
                    ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1),
                  ],
                  
                  if (tx.tags.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.tag_rounded, color: AppTheme.purple, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'الوسوم',
                                style: TextStyle(
                                  color: AppTheme.purple,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: tx.tags.map((tag) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.purple.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppTheme.purple.withOpacity(0.3)),
                              ),
                              child: Text(
                                '#$tag',
                                style: const TextStyle(
                                  color: AppTheme.purple,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )).toList(),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.1),
                  ],
                  
                  // Timestamps
                  const SizedBox(height: 16),
                  _GlassCard(
                    child: Column(
                      children: [
                        _DetailRow(
                          icon: Icons.add_circle_outline_rounded,
                          label: 'تاريخ الإنشاء',
                          value: fmtDateTime(tx.createdAt),
                          small: true,
                        ),
                        if (tx.updatedAt != null) ...[
                          const Divider(color: Colors.white12, height: 16),
                          _DetailRow(
                            icon: Icons.update_rounded,
                            label: 'آخر تعديل',
                            value: fmtDateTime(tx.updatedAt!),
                            small: true,
                          ),
                        ],
                      ],
                    ),
                  ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.1),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getRecurringLabel(RecurringType type) {
    switch (type) {
      case RecurringType.daily: return 'يومي';
      case RecurringType.weekly: return 'أسبوعي';
      case RecurringType.monthly: return 'شهري';
      case RecurringType.yearly: return 'سنوي';
      default: return 'مرة واحدة';
    }
  }

  void _confirmDelete(BuildContext ctx, AppProvider p, Transaction tx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A24),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.red.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.delete_rounded, color: AppTheme.red, size: 32),
            ),
            const SizedBox(height: 16),
            const Text(
              'حذف المعاملة؟',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'هل أنت متأكد من حذف هذه المعاملة؟\nلا يمكن التراجع عن هذا الإجراء.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                      minimumSize: const Size(0, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('إلغاء'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await p.deleteTransaction(tx);
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        showSnack(ctx, 'تم حذف المعاملة', emoji: '🗑️');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('حذف'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
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

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool small;
  
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: small ? 32 : 40,
          height: small ? 32 : 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(small ? 8 : 12),
          ),
          child: Icon(icon, color: Colors.white54, size: small ? 16 : 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: small ? 11 : 12,
                  color: Colors.white38,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: small ? 13 : 15,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
