// lib/screens/account_details_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import 'transaction_details_screen.dart';

class AccountDetailsScreen extends StatefulWidget {
  final Account account;
  
  const AccountDetailsScreen({super.key, required this.account});

  @override
  State<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  late Account _account;
  
  @override
  void initState() {
    super.initState();
    _account = widget.account;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    _account = p.accountById(widget.account.id) ?? _account;
    final transactions = p.getTransactionsByAccount(_account.id);
    final currency = currencyByCode(_account.currency);
    
    final totalIncome = transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalExpense = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 320,
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
                onPressed: () => _showEditDialog(context, p),
              ),
              PopupMenuButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.more_vert_rounded, size: 20),
                ),
                color: AppTheme.darkCard,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                onSelected: (value) {
                  if (value == 'toggle_hidden') _toggleHidden(p);
                  if (value == 'toggle_archive') _toggleArchive(p);
                  if (value == 'delete') _confirmDelete(context, p);
                },
                itemBuilder: (_) => <PopupMenuEntry<String>>[
                  PopupMenuItem(
                    value: 'toggle_hidden',
                    child: Row(
                      children: [
                        Icon(
                          _account.isHiddenFromTotal
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                          size: 20,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 12),
                        Text(_account.isHiddenFromTotal ? 'إظهار في المجموع' : 'إخفاء من المجموع'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'toggle_archive',
                    child: Row(
                      children: [
                        Icon(
                          _account.isArchived
                              ? Icons.unarchive_rounded
                              : Icons.archive_rounded,
                          size: 20,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 12),
                        Text(_account.isArchived ? 'إلغاء الأرشفة' : 'أرشفة الحساب'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: const [
                        Icon(Icons.delete_rounded, size: 20, color: AppTheme.red),
                        SizedBox(width: 12),
                        Text('حذف الحساب', style: TextStyle(color: AppTheme.red)),
                      ],
                    ),
                  ),
                ],
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
                      _account.color.withOpacity(0.4),
                      AppTheme.darkBg,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),
                      // Account Icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: _account.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: _account.color.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(_account.icon, style: const TextStyle(fontSize: 36)),
                        ),
                      ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
                      const SizedBox(height: 16),
                      // Account Name
                      Text(
                        _account.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ).animate().fadeIn(delay: 100.ms),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_account.typeIcon, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(
                            _account.typeNameAr,
                            style: const TextStyle(color: Colors.white54),
                          ),
                          const SizedBox(width: 12),
                          Text(currency.flag, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Text(
                            currency.code,
                            style: const TextStyle(color: Colors.white54),
                          ),
                        ],
                      ).animate().fadeIn(delay: 150.ms),
                      const SizedBox(height: 20),
                      // Balance
                      Text(
                        fmtAmount(_account.balance, _account.currency),
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: _account.balance >= 0 ? AppTheme.green : AppTheme.red,
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                      if (_account.isHiddenFromTotal) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.visibility_off_rounded, size: 14, color: Colors.orange),
                              SizedBox(width: 4),
                              Text(
                                'مخفي من المجموع',
                                style: TextStyle(color: Colors.orange, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Stats
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Income/Expense Stats
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.arrow_downward_rounded,
                          label: 'إجمالي الدخل',
                          value: fmtAmount(totalIncome, _account.currency),
                          color: AppTheme.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.arrow_upward_rounded,
                          label: 'إجمالي المصروفات',
                          value: fmtAmount(totalExpense, _account.currency),
                          color: AppTheme.red,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                  
                  const SizedBox(height: 16),
                  
                  // Info Card
                  _GlassCard(
                    child: Column(
                      children: [
                        _InfoRow(
                          icon: Icons.calendar_today_rounded,
                          label: 'تاريخ الإنشاء',
                          value: fmtFullDate(_account.createdAt),
                        ),
                        const Divider(color: Colors.white12, height: 24),
                        _InfoRow(
                          icon: Icons.receipt_long_rounded,
                          label: 'عدد المعاملات',
                          value: '${transactions.length} معاملة',
                        ),
                        if (_account.creditLimit != null) ...[
                          const Divider(color: Colors.white12, height: 24),
                          _InfoRow(
                            icon: Icons.credit_card_rounded,
                            label: 'حد الائتمان',
                            value: fmtAmount(_account.creditLimit!, _account.currency),
                          ),
                        ],
                        if (_account.targetBalance != null) ...[
                          const Divider(color: Colors.white12, height: 24),
                          _InfoRow(
                            icon: Icons.flag_rounded,
                            label: 'الرصيد المستهدف',
                            value: fmtAmount(_account.targetBalance!, _account.currency),
                          ),
                        ],
                        if (_account.note.isNotEmpty) ...[
                          const Divider(color: Colors.white12, height: 24),
                          _InfoRow(
                            icon: Icons.note_rounded,
                            label: 'ملاحظات',
                            value: _account.note,
                          ),
                        ],
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                  
                  if (transactions.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    
                    // Chart
                    _GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'توزيع المعاملات',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 200,
                            child: _buildChart(transactions),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
                    
                    const SizedBox(height: 24),
                    
                    // Recent Transactions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'آخر المعاملات',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to filtered transactions
                          },
                          child: const Text('عرض الكل'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    ...transactions.take(5).map((tx) => _TransactionItem(
                      transaction: tx,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TransactionDetailsScreen(transaction: tx),
                        ),
                      ),
                    )).toList(),
                  ],
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(List<Transaction> transactions) {
    final expensesByCategory = <String, double>{};
    for (final tx in transactions.where((t) => t.type == TransactionType.expense)) {
      final catId = tx.categoryId ?? 'other_exp';
      expensesByCategory[catId] = (expensesByCategory[catId] ?? 0) + tx.amount;
    }
    
    if (expensesByCategory.isEmpty) {
      return const Center(
        child: Text('لا توجد مصروفات', style: TextStyle(color: Colors.white54)),
      );
    }

    final entries = expensesByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 50,
        sections: entries.take(5).map((e) {
          final cat = categoryById(e.key);
          return PieChartSectionData(
            value: e.value,
            color: cat?.color ?? Colors.grey,
            radius: 40,
            title: '',
            badgeWidget: Text(cat?.emoji ?? '💸', style: const TextStyle(fontSize: 16)),
            badgePositionPercentageOffset: 1.8,
          );
        }).toList(),
      ),
    );
  }

  void _toggleHidden(AppProvider p) async {
    final updated = _account.copyWith(isHiddenFromTotal: !_account.isHiddenFromTotal);
    await p.updateAccount(updated);
    setState(() => _account = updated);
    if (mounted) {
      showSnack(
        context,
        updated.isHiddenFromTotal ? 'تم إخفاء الحساب من المجموع' : 'تم إظهار الحساب في المجموع',
        emoji: updated.isHiddenFromTotal ? '👁️‍🗨️' : '👁️',
      );
    }
  }

  void _toggleArchive(AppProvider p) async {
    final updated = _account.copyWith(isArchived: !_account.isArchived);
    await p.updateAccount(updated);
    setState(() => _account = updated);
    if (mounted) {
      showSnack(
        context,
        updated.isArchived ? 'تم أرشفة الحساب' : 'تم إلغاء أرشفة الحساب',
        emoji: updated.isArchived ? '📦' : '📂',
      );
    }
  }

  void _showEditDialog(BuildContext ctx, AppProvider p) {
    final nameCtrl = TextEditingController(text: _account.name);
    final noteCtrl = TextEditingController(text: _account.note);
    var selectedType = _account.accountType;

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A24),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'تعديل الحساب',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'اسم الحساب',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('نوع الحساب', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AccountType.values.map((type) {
                    final isSelected = selectedType == type;
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedType = type),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.gold.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppTheme.gold : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(kAccountTypeIcons[type] ?? '💼'),
                            const SizedBox(width: 6),
                            Text(
                              kAccountTypeNames[type] ?? 'أخرى',
                              style: TextStyle(
                                color: isSelected ? AppTheme.gold : Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: noteCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'ملاحظات (اختياري)',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (nameCtrl.text.trim().isEmpty) return;
                      final updated = _account.copyWith(
                        name: nameCtrl.text.trim(),
                        accountType: selectedType,
                        note: noteCtrl.text.trim(),
                      );
                      await p.updateAccount(updated);
                      if (context.mounted) {
                        Navigator.pop(context);
                        showSnack(context, 'تم تحديث الحساب', emoji: '✅');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.gold,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('حفظ التغييرات', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext ctx, AppProvider p) {
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
              'حذف الحساب؟',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'سيتم حذف الحساب وجميع المعاملات المرتبطة به.\nلا يمكن التراجع عن هذا الإجراء.',
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
                      await p.deleteAccount(_account.id);
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        showSnack(ctx, 'تم حذف الحساب', emoji: '🗑️');
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

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
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
              Text(
                label,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white54, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onTap;

  const _TransactionItem({required this.transaction, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cat = categoryById(transaction.categoryId);
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? AppTheme.green : AppTheme.red;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (cat?.color ?? color).withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  cat?.emoji ?? (isIncome ? '💰' : '💸'),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cat?.nameAr ?? (isIncome ? 'دخل' : 'مصروف'),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    fmtDate(transaction.date),
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              '${isIncome ? '+' : '-'}${fmtAmount(transaction.amount, transaction.currency)}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
