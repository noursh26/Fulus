// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'add_transaction_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final cur = p.mainCurrency;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => p.load(),
        color: AppTheme.gold,
        child: CustomScrollView(
          slivers: [
            // ─── App Bar ──────────────────────────────
            SliverAppBar(
              pinned: true, expandedHeight: 0,
              title: const Text('Fulus 💰'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.account_balance_wallet_rounded),
                  onPressed: () => Navigator.pushNamed(context, '/accounts'),
                  tooltip: 'الحسابات',
                ),
              ],
            ),

            SliverToBoxAdapter(child: Column(children: [
              // ─── Balance Card ──────────────────────
              _BalanceCard(p: p, cur: cur),
              const SizedBox(height: 8),

              // ─── Quick Actions ─────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(children: [
                  _QuickAction(icon: Icons.add_rounded, label: 'إضافة', color: AppTheme.green,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTransactionScreen()))),
                  _QuickAction(icon: Icons.swap_horiz_rounded, label: 'تحويل', color: const Color(0xFF60A5FA),
                    onTap: () => Navigator.pushNamed(context, '/transfer')),
                  _QuickAction(icon: Icons.track_changes_rounded, label: 'ميزانية', color: Colors.deepPurple.shade300,
                    onTap: () => Navigator.pushNamed(context, '/budget')),
                  _QuickAction(icon: Icons.bar_chart_rounded, label: 'تقارير', color: AppTheme.gold,
                    onTap: () => Navigator.pushNamed(context, '/reports')),
                ]),
              ),

              // ─── Accounts ─────────────────────────
              const SectionHeader(title: 'الحسابات', action: 'عرض الكل'),
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: p.accounts.length + 1,
                  itemBuilder: (_, i) {
                    if (i == p.accounts.length) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: _AddAccountBtn(onTap: () => Navigator.pushNamed(context, '/accounts')),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: AccountCard(account: p.accounts[i], index: i),
                    );
                  },
                ),
              ),

              // ─── Recent Transactions ───────────────
              SectionHeader(title: 'آخر المعاملات', action: 'عرض الكل',
                onAction: () => Navigator.pushNamed(context, '/transactions')),
            ])),

            // ─── Tx List ──────────────────────────────
            p.transactions.isEmpty
                ? SliverToBoxAdapter(child: EmptyState(
                    emoji: '💸', message: 'لا يوجد معاملات بعد\nاضغط ＋ لإضافة أول معاملة',
                    buttonLabel: 'إضافة معاملة',
                    onButton: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTransactionScreen())),
                  ))
                : SliverList(delegate: SliverChildBuilderDelegate(
                    (_, i) => TxItem(
                      tx: p.transactions[i],
                      onTap: () => _confirmDelete(context, p, p.transactions[i]),
                      index: i,
                    ),
                    childCount: p.transactions.take(10).length,
                  )),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTransactionScreen())),
        backgroundColor: AppTheme.gold,
        foregroundColor: const Color(0xFF1A1000),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }

  void _confirmDelete(BuildContext ctx, AppProvider p, tx) {
    showModalBottomSheet(context: ctx, backgroundColor: const Color(0xFF1A1A24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Text('حذف المعاملة؟', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('هل تريد حذف هذه المعاملة؟ لا يمكن التراجع', style: TextStyle(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: OutlinedButton(
              onPressed: () => Navigator.pop(ctx),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.white70, side: const BorderSide(color: Colors.white24),
                minimumSize: const Size(0, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: const Text('إلغاء'),
            )),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await p.deleteTransaction(tx);
                if (ctx.mounted) showSnack(ctx, 'تم حذف المعاملة', emoji: '🗑️');
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.red, foregroundColor: Colors.white,
                minimumSize: const Size(0, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: const Text('حذف'),
            )),
          ]),
        ]),
      ),
    );
  }
}

// ─── Internal Widgets ─────────────────────────────────────
class _BalanceCard extends StatelessWidget {
  final AppProvider p;
  final String cur;
  const _BalanceCard({required this.p, required this.cur});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xFF1C1A0E), Color(0xFF1A1520), Color(0xFF0E1520)],
      ),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppTheme.gold.withOpacity(0.2)),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 30, offset: const Offset(0, 10))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('إجمالي الرصيد', style: TextStyle(fontSize: 12, color: AppTheme.gold.withOpacity(0.7), letterSpacing: 1)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (p.monthlySavings >= 0 ? AppTheme.green : AppTheme.red).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  p.monthlySavings >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                  size: 14,
                  color: p.monthlySavings >= 0 ? AppTheme.green : AppTheme.red,
                ),
                const SizedBox(width: 4),
                Text(
                  'صافي: ${fmtAmount(p.monthlySavings.abs(), cur)}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: p.monthlySavings >= 0 ? AppTheme.green : AppTheme.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 6),
      Text(fmtAmount(p.totalBalance, cur),
        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: AppTheme.gold, fontFamily: 'monospace')),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: StatCard(label: 'دخل الشهر', amount: p.monthlyIncome, currency: cur, color: AppTheme.green, icon: Icons.trending_up_rounded)),
        const SizedBox(width: 12),
        Expanded(child: StatCard(label: 'مصاريف الشهر', amount: p.monthlyExpense, currency: cur, color: AppTheme.red, icon: Icons.trending_down_rounded)),
      ]),
    ]),
  ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95), duration: 400.ms);
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
          width: 54, height: 54,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color.withOpacity(0.3), color.withOpacity(0.1)]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      ]),
    ),
  );
}

class _AddAccountBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _AddAccountBtn({required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 110,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12, style: BorderStyle.solid),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.add_circle_outline_rounded, color: Colors.white24, size: 30),
        const SizedBox(height: 8),
        Text('حساب جديد', style: TextStyle(fontSize: 11, color: Colors.white38)),
      ]),
    ),
  );
}
