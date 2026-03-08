// lib/screens/currency_converter_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final _amountCtrl = TextEditingController(text: '1');
  Currency _fromCurrency = kCurrencies.first;
  Currency _toCurrency = kCurrencies[2]; // SYP
  double _result = 0;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    final amount = double.tryParse(_amountCtrl.text) ?? 0;
    final p = context.read<AppProvider>();
    final rate = p.getExchangeRate(_fromCurrency.code, _toCurrency.code);
    setState(() {
      _result = amount * rate;
    });
  }

  void _swap() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
      _calculate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('محول العملات'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // From Currency
            _CurrencyCard(
              label: 'من',
              currency: _fromCurrency,
              amount: _amountCtrl.text,
              isInput: true,
              controller: _amountCtrl,
              onChanged: (_) => _calculate(),
              onCurrencyTap: () => _showCurrencyPicker(true),
            ).animate().fadeIn().slideY(begin: -0.1),

            const SizedBox(height: 16),

            // Swap Button
            GestureDetector(
              onTap: _swap,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.gold, AppTheme.gold2],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.gold.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.swap_vert_rounded,
                  color: Colors.black,
                  size: 28,
                ),
              ),
            ).animate().scale(delay: 200.ms),

            const SizedBox(height: 16),

            // To Currency
            _CurrencyCard(
              label: 'إلى',
              currency: _toCurrency,
              amount: fmtNumber(_result),
              isInput: false,
              onCurrencyTap: () => _showCurrencyPicker(false),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),

            const SizedBox(height: 32),

            // Exchange Rate Info
            Builder(
              builder: (context) {
                final p = context.watch<AppProvider>();
                final rate1 = p.getExchangeRate(_fromCurrency.code, _toCurrency.code);
                final rate2 = p.getExchangeRate(_toCurrency.code, _fromCurrency.code);
                final hasCustomRate = p.getCustomRate(_fromCurrency.code, _toCurrency.code) != null ||
                    p.getCustomRate(_toCurrency.code, _fromCurrency.code) != null;
                return _GlassCard(
                  child: Column(
                    children: [
                      _RateRow(
                        from: _fromCurrency,
                        to: _toCurrency,
                        rate: rate1,
                      ),
                      const Divider(color: Colors.white12, height: 24),
                      _RateRow(
                        from: _toCurrency,
                        to: _fromCurrency,
                        rate: rate2,
                      ),
                      if (hasCustomRate) ...[
                        const Divider(color: Colors.white12, height: 24),
                        Row(
                          children: [
                            Icon(Icons.info_outline_rounded, size: 14, color: AppTheme.gold),
                            const SizedBox(width: 8),
                            Text('يستخدم سعر صرف مخصص', 
                              style: TextStyle(fontSize: 11, color: AppTheme.gold)),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              },
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

            const SizedBox(height: 24),

            // Quick Amounts
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [1, 10, 100, 1000, 10000].map((amount) {
                return GestureDetector(
                  onTap: () {
                    _amountCtrl.text = amount.toString();
                    _calculate();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Text(
                      '$amount ${_fromCurrency.symbol}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                );
              }).toList(),
            ).animate().fadeIn(delay: 400.ms),
          ],
        ),
      ),
    );
  }

  void _showCurrencyPicker(bool isFrom) {
    showModalBottomSheet(
      context: context,
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
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isFrom ? 'اختر العملة المصدر' : 'اختر العملة الهدف',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: kCurrencies.length,
                itemBuilder: (_, i) {
                  final cur = kCurrencies[i];
                  final selected = isFrom
                      ? _fromCurrency.code == cur.code
                      : _toCurrency.code == cur.code;
                  return ListTile(
                    onTap: () {
                      setState(() {
                        if (isFrom) {
                          _fromCurrency = cur;
                        } else {
                          _toCurrency = cur;
                        }
                        _calculate();
                      });
                      Navigator.pop(context);
                    },
                    leading: Text(cur.flag, style: const TextStyle(fontSize: 28)),
                    title: Text(
                      cur.nameAr,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: selected ? AppTheme.gold : Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      '${cur.code} • ${cur.symbol}',
                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                    trailing: selected
                        ? const Icon(Icons.check_circle_rounded, color: AppTheme.gold)
                        : Text(
                            '${cur.rateToUSD}',
                            style: const TextStyle(color: Colors.white24, fontSize: 11),
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrencyCard extends StatelessWidget {
  final String label;
  final Currency currency;
  final String amount;
  final bool isInput;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback onCurrencyTap;

  const _CurrencyCard({
    required this.label,
    required this.currency,
    required this.amount,
    required this.isInput,
    this.controller,
    this.onChanged,
    required this.onCurrencyTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  GestureDetector(
                    onTap: onCurrencyTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(currency.flag, style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currency.code,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                currency.nameAr,
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white54),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: isInput
                        ? TextField(
                            controller: controller,
                            onChanged: onChanged,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'monospace',
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: '0',
                            ),
                          )
                        : Text(
                            amount,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'monospace',
                              color: AppTheme.gold,
                            ),
                          ),
                  ),
                ],
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

class _RateRow extends StatelessWidget {
  final Currency from;
  final Currency to;
  final double rate;

  const _RateRow({
    required this.from,
    required this.to,
    required this.rate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(from.flag, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Text(
          '1 ${from.code}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.white38),
        const SizedBox(width: 8),
        Text(to.flag, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '${fmtNumber(rate)} ${to.code}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppTheme.gold,
            ),
          ),
        ),
      ],
    );
  }
}
