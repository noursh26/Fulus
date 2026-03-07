// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';

class AppTheme {
  static const gold    = Color(0xFFF0C060);
  static const gold2   = Color(0xFFE8A830);
  static const green   = Color(0xFF34D399);
  static const red     = Color(0xFFF87171);
  static const darkBg  = Color(0xFF0A0A0F);
  static const darkBg2 = Color(0xFF111118);
  static const darkCard= Color(0xFF1A1A24);

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

String fmtAmount(double amount, String currency) {
  final sym = kCurrencies.firstWhere((c) => c.code == currency, orElse: () => kCurrencies.first).symbol;
  if (amount.abs() >= 1000000) return '$sym${(amount/1000000).toStringAsFixed(1)}M';
  if (amount.abs() >= 1000)    return '$sym${(amount/1000).toStringAsFixed(1)}K';
  return '$sym${amount.toStringAsFixed(2)}';
}

String fmtDate(DateTime d) {
  final diff = DateTime.now().difference(d).inDays;
  if (diff == 0) return 'اليوم';
  if (diff == 1) return 'أمس';
  const mo = ['يناير','فبراير','مارس','أبريل','مايو','يونيو','يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'];
  return '${d.day} ${mo[d.month - 1]}';
}

void showSnack(BuildContext ctx, String msg, {String emoji = '✅', bool isError = false}) {
  ScaffoldMessenger.of(ctx).clearSnackBars();
  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
    content: Row(children: [
      Text(emoji, style: const TextStyle(fontSize: 18)),
      const SizedBox(width: 10),
      Expanded(child: Text(msg)),
    ]),
    backgroundColor: isError ? AppTheme.red.withOpacity(0.15) : null,
    duration: const Duration(seconds: 3),
    margin: const EdgeInsets.all(16),
  ));
}