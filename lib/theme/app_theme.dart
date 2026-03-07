// lib/theme/app_theme.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';

class AppTheme {
  static const gold = Color(0xFFF0C060);
  static const gold2 = Color(0xFFE8A830);
  static const green = Color(0xFF34D399);
  static const red = Color(0xFFF87171);
  static const blue = Color(0xFF60A5FA);
  static const purple = Color(0xFFA78BFA);
  static const pink = Color(0xFFF472B6);
  static const orange = Color(0xFFFB923C);
  static const cyan = Color(0xFF22D3EE);
  static const darkBg = Color(0xFF0A0A0F);
  static const darkBg2 = Color(0xFF111118);
  static const darkCard = Color(0xFF1A1A24);
  static const glassBg = Color(0x1AFFFFFF);
  static const glassBorder = Color(0x33FFFFFF);
  
  static const List<Color> gradientColors = [
    Color(0xFF667EEA),
    Color(0xFF764BA2),
  ];
  
  static const List<Color> goldGradient = [
    Color(0xFFF0C060),
    Color(0xFFE8A830),
    Color(0xFFD4A520),
  ];
  
  static const List<Color> greenGradient = [
    Color(0xFF34D399),
    Color(0xFF10B981),
    Color(0xFF059669),
  ];
  
  static const List<Color> redGradient = [
    Color(0xFFF87171),
    Color(0xFFEF4444),
    Color(0xFFDC2626),
  ];

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBg,
    colorScheme: const ColorScheme.dark(
      primary: gold, secondary: green, error: red,
      surface: darkBg2,
    ),
    textTheme: GoogleFonts.tajawalTextTheme(ThemeData.dark().textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: darkBg, elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: GoogleFonts.tajawal(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
      iconTheme: const IconThemeData(color: Colors.white70),
    ),
    cardTheme: CardTheme(
      color: darkCard, elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Colors.white10),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: darkCard,
      border:        OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.white12)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.white12)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: gold, width: 1.5)),
      labelStyle: const TextStyle(color: Colors.white54),
      hintStyle:  const TextStyle(color: Colors.white24),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: gold, foregroundColor: Color(0xFF1A1000),
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.w800),
        elevation: 0,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF1E1E2E),
      contentTextStyle: GoogleFonts.tajawal(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      behavior: SnackBarBehavior.floating,
    ),
  );

  static ThemeData get light => ThemeData(
    useMaterial3: true, brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF00897B), secondary: Color(0xFF10B981), error: red,
    ),
    textTheme: GoogleFonts.tajawalTextTheme(ThemeData.light().textTheme),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.w800),
      ),
    ),
  );
}

String fmtAmount(double amount, String currencyCode, {bool showSign = false, bool compact = false}) {
  final cur = currencyByCode(currencyCode);
  final formatter = NumberFormat.currency(
    symbol: '',
    decimalDigits: cur.decimalDigits,
    locale: 'ar',
  );
  
  String formatted;
  if (compact) {
    if (amount.abs() >= 1000000000) {
      formatted = '${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount.abs() >= 1000000) {
      formatted = '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount.abs() >= 1000) {
      formatted = '${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      formatted = formatter.format(amount);
    }
  } else {
    formatted = formatter.format(amount);
  }
  
  final sign = showSign && amount > 0 ? '+' : '';
  return '$sign${cur.symbol} $formatted'.trim();
}

String fmtAmountWithCode(double amount, String currencyCode) {
  final cur = currencyByCode(currencyCode);
  final formatter = NumberFormat.decimalPattern('ar');
  if (cur.decimalDigits == 0) {
    return '${formatter.format(amount.round())} $currencyCode';
  }
  return '${formatter.format(amount)} $currencyCode';
}

String fmtNumber(double number, {int decimals = 2}) {
  final formatter = NumberFormat.decimalPattern('ar');
  return formatter.format(number);
}

String fmtDate(DateTime d, {bool showTime = false, bool relative = true}) {
  if (relative) {
    final now = DateTime.now();
    final diff = now.difference(d).inDays;
    final todayStart = DateTime(now.year, now.month, now.day);
    final dateStart = DateTime(d.year, d.month, d.day);
    
    if (dateStart == todayStart) {
      return showTime ? 'اليوم ${DateFormat.Hm('ar').format(d)}' : 'اليوم';
    }
    if (dateStart == todayStart.subtract(const Duration(days: 1))) {
      return showTime ? 'أمس ${DateFormat.Hm('ar').format(d)}' : 'أمس';
    }
    if (diff < 7 && diff > 0) {
      return DateFormat.EEEE('ar').format(d);
    }
  }
  
  const months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 
                  'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
  final dateStr = '${d.day} ${months[d.month - 1]}';
  if (d.year != DateTime.now().year) {
    return '$dateStr ${d.year}';
  }
  return showTime ? '$dateStr ${DateFormat.Hm('ar').format(d)}' : dateStr;
}

String fmtDateTime(DateTime d) {
  return fmtDate(d, showTime: true, relative: true);
}

String fmtFullDate(DateTime d) {
  const days = ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
  const months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
                  'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
  return '${days[d.weekday % 7]}، ${d.day} ${months[d.month - 1]} ${d.year}';
}

String fmtTimeAgo(DateTime d) {
  final diff = DateTime.now().difference(d);
  if (diff.inSeconds < 60) return 'الآن';
  if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
  if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
  if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
  if (diff.inDays < 30) return 'منذ ${diff.inDays ~/ 7} أسبوع';
  if (diff.inDays < 365) return 'منذ ${diff.inDays ~/ 30} شهر';
  return 'منذ ${diff.inDays ~/ 365} سنة';
}

void showSnack(BuildContext ctx, String msg, {String emoji = '✅', bool isError = false}) {
  ScaffoldMessenger.of(ctx).clearSnackBars();
  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
    content: Row(children: [
      Text(emoji, style: const TextStyle(fontSize: 18)),
      const SizedBox(width: 10),
      Expanded(child: Text(msg, style: const TextStyle(fontFamily: 'Tajawal'))),
    ]),
    backgroundColor: isError ? AppTheme.red.withOpacity(0.9) : const Color(0xFF1E1E2E),
    duration: const Duration(seconds: 3),
    margin: const EdgeInsets.all(16),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ));
}

class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final Color? color;
  final Border? border;
  
  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.blur = 10,
    this.color,
    this.border,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color ?? AppTheme.glassBg,
              borderRadius: BorderRadius.circular(borderRadius),
              border: border ?? Border.all(color: AppTheme.glassBorder, width: 1),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final List<Color> colors;
  
  const GradientText({
    super.key,
    required this.text,
    this.style,
    this.colors = const [AppTheme.gold, AppTheme.gold2],
  });
  
  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => LinearGradient(colors: colors).createShader(bounds),
      child: Text(text, style: style),
    );
  }
}