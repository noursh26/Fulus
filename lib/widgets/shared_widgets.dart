// lib/widgets/shared_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

// ─── Section Header ───────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SectionHeader({super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(action!, style: TextStyle(fontSize: 13, color: AppTheme.gold, fontWeight: FontWeight.w600)),
          ),
      ],
    ),
  );
}

// ─── Transaction Item ─────────────────────────────────────
class TxItem extends StatelessWidget {
  final Transaction tx;
  final VoidCallback? onTap;
  final int? index;
  const TxItem({super.key, required this.tx, this.onTap, this.index});

  @override
  Widget build(BuildContext context) {
    final cat = categoryById(tx.categoryId);
    final color = cat?.color ?? Colors.grey;
    final isIncome = tx.type == TransactionType.income;

    Widget item = GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(children: [
          // Icon
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(child: Text(cat?.emoji ?? '💸', style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tx.description.isNotEmpty ? tx.description : (cat?.nameAr ?? 'معاملة'),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Row(children: [
                Text(cat?.nameAr ?? '', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.4))),
                const SizedBox(width: 6),
                Container(width: 3, height: 3, decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text(fmtDate(tx.date), style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.4))),
              ]),
            ],
          )),
          // Amount
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: (isIncome ? AppTheme.green : AppTheme.red).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${isIncome ? '+' : '-'}${fmtAmount(tx.amount, tx.currency)}',
              style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700,
                color: isIncome ? AppTheme.green : AppTheme.red,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ]),
      ),
    );

    if (index != null) {
      return item
          .animate()
          .fadeIn(delay: Duration(milliseconds: 50 * (index! % 10)))
          .slideX(begin: 0.1, end: 0, delay: Duration(milliseconds: 50 * (index! % 10)));
    }
    return item;
  }
}

// ─── Account Card ─────────────────────────────────────────
class AccountCard extends StatelessWidget {
  final Account account;
  final VoidCallback? onTap;
  final int? index;
  const AccountCard({super.key, required this.account, this.onTap, this.index});

  @override
  Widget build(BuildContext context) {
    final cur = currencyByCode(account.currency);
    Widget card = GestureDetector(
      onTap: onTap,
      child: Container(
        width: 170,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [account.color, account.color.withOpacity(0.6)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: account.color.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 18),
                ),
                const Spacer(),
                Text(cur.flag, style: const TextStyle(fontSize: 18)),
              ],
            ),
            const Spacer(),
            Text(account.name, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              fmtAmount(account.balance, account.currency),
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, fontFamily: 'monospace'),
            ),
            Text(account.currency, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11)),
          ],
        ),
      ),
    );

    if (index != null) {
      return card
          .animate()
          .fadeIn(delay: Duration(milliseconds: 100 * index!))
          .scale(begin: const Offset(0.9, 0.9), delay: Duration(milliseconds: 100 * index!));
    }
    return card;
  }
}

// ─── Stat Card ────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String label;
  final double amount;
  final String currency;
  final Color color;
  final IconData icon;
  const StatCard({super.key, required this.label, required this.amount, required this.currency, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withOpacity(0.2)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
      ]),
      const SizedBox(height: 6),
      Text(fmtAmount(amount, currency),
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color, fontFamily: 'monospace')),
    ]),
  );
}

// ─── Category Grid ────────────────────────────────────────
class CategoryGrid extends StatefulWidget {
  final TransactionType type;
  final String? selected;
  final ValueChanged<String> onSelect;
  const CategoryGrid({super.key, required this.type, this.selected, required this.onSelect});
  @override State<CategoryGrid> createState() => _CategoryGridState();
}
class _CategoryGridState extends State<CategoryGrid> {
  @override
  Widget build(BuildContext context) {
    final cats = kDefaultCategories.where((c) => c.type == widget.type).toList();
    return GridView.builder(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.85,
      ),
      itemCount: cats.length,
      itemBuilder: (_, i) {
        final cat = cats[i];
        final sel = widget.selected == cat.id;
        return GestureDetector(
          onTap: () => widget.onSelect(cat.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: sel ? cat.color.withOpacity(0.2) : AppTheme.darkCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: sel ? cat.color : Colors.white10, width: sel ? 1.5 : 1),
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(cat.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 5),
              Text(cat.nameAr, style: TextStyle(fontSize: 10, color: sel ? cat.color : Colors.white54), textAlign: TextAlign.center, maxLines: 1),
            ]),
          ),
        );
      },
    );
  }
}

// ─── Empty State ──────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final String emoji;
  final String message;
  final String? buttonLabel;
  final VoidCallback? onButton;
  const EmptyState({super.key, required this.emoji, required this.message, this.buttonLabel, this.onButton});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(48),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(emoji, style: const TextStyle(fontSize: 52)),
        const SizedBox(height: 12),
        Text(message, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.4)), textAlign: TextAlign.center),
        if (buttonLabel != null) ...[
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: onButton,
            style: OutlinedButton.styleFrom(foregroundColor: AppTheme.gold, side: const BorderSide(color: AppTheme.gold)),
            child: Text(buttonLabel!),
          ),
        ],
      ]),
    ),
  );
}
