// lib/screens/edit_transaction_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class EditTransactionScreen extends StatefulWidget {
  final Transaction transaction;
  
  const EditTransactionScreen({super.key, required this.transaction});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  late TextEditingController _amountCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _noteCtrl;
  late TextEditingController _payeeCtrl;
  late TextEditingController _locationCtrl;
  late TransactionType _type;
  late String _accountId;
  late String? _categoryId;
  late DateTime _date;
  late RecurringType _recurring;
  late List<String> _tags;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    _amountCtrl = TextEditingController(text: tx.amount.toString());
    _descCtrl = TextEditingController(text: tx.description);
    _noteCtrl = TextEditingController(text: tx.note ?? '');
    _payeeCtrl = TextEditingController(text: tx.payee ?? '');
    _locationCtrl = TextEditingController(text: tx.location ?? '');
    _type = tx.type;
    _accountId = tx.accountId;
    _categoryId = tx.categoryId;
    _date = tx.date;
    _recurring = tx.recurring;
    _tags = List.from(tx.tags);
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    _noteCtrl.dispose();
    _payeeCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final categories = kDefaultCategories.where((c) => c.type == _type).toList();
    final accounts = p.activeAccounts;
    final selectedAcc = accounts.firstWhere(
      (a) => a.id == _accountId,
      orElse: () => accounts.first,
    );

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('تعديل المعاملة'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type Toggle
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _TypeButton(
                      label: 'مصروف',
                      icon: Icons.arrow_upward_rounded,
                      color: AppTheme.red,
                      isSelected: _type == TransactionType.expense,
                      onTap: () => setState(() {
                        _type = TransactionType.expense;
                        _categoryId = null;
                      }),
                    ),
                  ),
                  Expanded(
                    child: _TypeButton(
                      label: 'دخل',
                      icon: Icons.arrow_downward_rounded,
                      color: AppTheme.green,
                      isSelected: _type == TransactionType.income,
                      onTap: () => setState(() {
                        _type = TransactionType.income;
                        _categoryId = null;
                      }),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: -0.1),

            const SizedBox(height: 24),

            // Amount
            _GlassTextField(
              controller: _amountCtrl,
              label: 'المبلغ',
              hint: '0.00',
              icon: Icons.attach_money_rounded,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              suffix: Text(
                currencyByCode(selectedAcc.currency).symbol,
                style: const TextStyle(
                  color: AppTheme.gold,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),

            const SizedBox(height: 16),

            // Account
            _GlassDropdown<String>(
              label: 'الحساب',
              icon: Icons.account_balance_wallet_rounded,
              value: _accountId,
              items: accounts.map((a) => DropdownMenuItem(
                value: a.id,
                child: Row(
                  children: [
                    Text(a.icon, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(a.name),
                    const Spacer(),
                    Text(
                      currencyByCode(a.currency).symbol,
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              )).toList(),
              onChanged: (v) => setState(() => _accountId = v!),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

            const SizedBox(height: 16),

            // Category Grid
            const Text(
              'التصنيف',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                childAspectRatio: 0.85,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: categories.length,
              itemBuilder: (_, i) {
                final cat = categories[i];
                final isSelected = _categoryId == cat.id;
                return GestureDetector(
                  onTap: () => setState(() => _categoryId = cat.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? cat.color.withOpacity(0.2)
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? cat.color : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(cat.emoji, style: const TextStyle(fontSize: 24)),
                        const SizedBox(height: 4),
                        Text(
                          cat.nameAr,
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected ? cat.color : Colors.white54,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 16),

            // Description
            _GlassTextField(
              controller: _descCtrl,
              label: 'الوصف',
              hint: 'أدخل وصفاً للمعاملة...',
              icon: Icons.description_rounded,
              maxLines: 2,
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

            const SizedBox(height: 16),

            // Date
            GestureDetector(
              onTap: _pickDate,
              child: _GlassField(
                label: 'التاريخ',
                icon: Icons.calendar_today_rounded,
                value: fmtFullDate(_date),
              ),
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),

            const SizedBox(height: 16),

            // Recurring
            _GlassDropdown<RecurringType>(
              label: 'التكرار',
              icon: Icons.repeat_rounded,
              value: _recurring,
              items: const [
                DropdownMenuItem(value: RecurringType.none, child: Text('مرة واحدة')),
                DropdownMenuItem(value: RecurringType.daily, child: Text('يومي')),
                DropdownMenuItem(value: RecurringType.weekly, child: Text('أسبوعي')),
                DropdownMenuItem(value: RecurringType.monthly, child: Text('شهري')),
                DropdownMenuItem(value: RecurringType.yearly, child: Text('سنوي')),
              ],
              onChanged: (v) => setState(() => _recurring = v!),
            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),

            const SizedBox(height: 16),

            // Payee
            _GlassTextField(
              controller: _payeeCtrl,
              label: 'المستفيد (اختياري)',
              hint: 'اسم المستفيد أو الجهة...',
              icon: Icons.person_rounded,
            ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1),

            const SizedBox(height: 16),

            // Location
            _GlassTextField(
              controller: _locationCtrl,
              label: 'الموقع (اختياري)',
              hint: 'أدخل الموقع...',
              icon: Icons.location_on_rounded,
            ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.1),

            const SizedBox(height: 16),

            // Note
            _GlassTextField(
              controller: _noteCtrl,
              label: 'ملاحظات (اختياري)',
              hint: 'أضف ملاحظات إضافية...',
              icon: Icons.note_rounded,
              maxLines: 3,
            ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.1),

            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.gold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Text(
                        'حفظ التغييرات',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.1),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.gold,
              surface: AppTheme.darkCard,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_date),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: AppTheme.gold,
                surface: AppTheme.darkCard,
              ),
            ),
            child: child!,
          );
        },
      );
      setState(() {
        _date = DateTime(
          picked.year,
          picked.month,
          picked.day,
          time?.hour ?? _date.hour,
          time?.minute ?? _date.minute,
        );
      });
    }
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) {
      showSnack(context, 'الرجاء إدخال مبلغ صحيح', emoji: '⚠️', isError: true);
      return;
    }
    if (_categoryId == null) {
      showSnack(context, 'الرجاء اختيار تصنيف', emoji: '⚠️', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final p = context.read<AppProvider>();
    final acc = p.accounts.firstWhere((a) => a.id == _accountId);
    
    final newTx = widget.transaction.copyWith(
      accountId: _accountId,
      categoryId: _categoryId,
      amount: amount,
      type: _type,
      description: _descCtrl.text.trim(),
      date: _date,
      currency: acc.currency,
      recurring: _recurring,
      payee: _payeeCtrl.text.trim().isEmpty ? null : _payeeCtrl.text.trim(),
      location: _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      tags: _tags,
      updatedAt: DateTime.now(),
    );

    await p.updateTransaction(widget.transaction, newTx);

    if (mounted) {
      Navigator.pop(context);
      showSnack(context, 'تم تحديث المعاملة بنجاح', emoji: '✅');
    }
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? color : Colors.white38, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.white38,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final Widget? suffix;

  const _GlassTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                maxLines: maxLines,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(color: Colors.white30),
                  prefixIcon: Icon(icon, color: Colors.white38),
                  suffixIcon: suffix != null
                      ? Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: suffix,
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GlassDropdown<T> extends StatelessWidget {
  final String label;
  final IconData icon;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _GlassDropdown({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: DropdownButtonFormField<T>(
                value: value,
                items: items,
                onChanged: onChanged,
                dropdownColor: AppTheme.darkCard,
                decoration: InputDecoration(
                  prefixIcon: Icon(icon, color: Colors.white38),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                style: const TextStyle(fontSize: 15, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GlassField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;

  const _GlassField({
    required this.label,
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Icon(icon, color: Colors.white38),
                  const SizedBox(width: 12),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 15),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_left_rounded, color: Colors.white38),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
