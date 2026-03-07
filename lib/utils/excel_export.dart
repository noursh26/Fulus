// lib/utils/excel_export.dart
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';

class ExcelExportService {
  static Future<String> exportTransactions({
    required List<Transaction> transactions,
    required List<Account> accounts,
    String? fileName,
  }) async {
    final excel = Excel.createExcel();
    
    // إنشاء ورقة المعاملات
    final txSheet = excel['المعاملات'];
    excel.setDefaultSheet('المعاملات');
    
    // إزالة الورقة الافتراضية
    if (excel.sheets.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }
    
    // رأس الجدول
    final headers = ['التاريخ', 'النوع', 'التصنيف', 'المبلغ', 'العملة', 'الحساب', 'الوصف'];
    for (var i = 0; i < headers.length; i++) {
      txSheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
        ..value = TextCellValue(headers[i])
        ..cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.fromHexString('#F0C060'),
          fontColorHex: ExcelColor.fromHexString('#1A1A24'),
        );
    }
    
    // البيانات
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    for (var i = 0; i < transactions.length; i++) {
      final tx = transactions[i];
      final cat = categoryById(tx.categoryId);
      final acc = accounts.where((a) => a.id == tx.accountId).firstOrNull;
      final row = i + 1;
      
      txSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = TextCellValue(dateFormat.format(tx.date));
      txSheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
        .value = TextCellValue(tx.type == TransactionType.income ? 'دخل' : 'مصروف');
      txSheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
        .value = TextCellValue('${cat?.emoji ?? ''} ${cat?.nameAr ?? 'غير محدد'}');
      txSheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
        .value = DoubleCellValue(tx.amount);
      txSheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
        .value = TextCellValue(tx.currency);
      txSheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
        .value = TextCellValue(acc?.name ?? 'غير محدد');
      txSheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row))
        .value = TextCellValue(tx.description);
    }
    
    // إنشاء ورقة الحسابات
    final accSheet = excel['الحسابات'];
    final accHeaders = ['اسم الحساب', 'العملة', 'الرصيد', 'تاريخ الإنشاء'];
    for (var i = 0; i < accHeaders.length; i++) {
      accSheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
        ..value = TextCellValue(accHeaders[i])
        ..cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.fromHexString('#10B981'),
          fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
        );
    }
    
    for (var i = 0; i < accounts.length; i++) {
      final acc = accounts[i];
      final row = i + 1;
      
      accSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = TextCellValue(acc.name);
      accSheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
        .value = TextCellValue(acc.currency);
      accSheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
        .value = DoubleCellValue(acc.balance);
      accSheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
        .value = TextCellValue(dateFormat.format(acc.createdAt));
    }
    
    // إنشاء ورقة الملخص
    final summarySheet = excel['ملخص'];
    final totalIncome = transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalExpense = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalBalance = accounts.fold(0.0, (sum, a) => sum + a.balance);
    
    final summaryData = [
      ['إجمالي الدخل', totalIncome],
      ['إجمالي المصروفات', totalExpense],
      ['صافي الربح/الخسارة', totalIncome - totalExpense],
      ['إجمالي الرصيد', totalBalance],
      ['عدد المعاملات', transactions.length],
      ['عدد الحسابات', accounts.length],
      ['تاريخ التصدير', dateFormat.format(DateTime.now())],
    ];
    
    for (var i = 0; i < summaryData.length; i++) {
      summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i))
        ..value = TextCellValue(summaryData[i][0].toString())
        ..cellStyle = CellStyle(bold: true);
      final val = summaryData[i][1];
      if (val is num) {
        summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i))
          .value = DoubleCellValue(val.toDouble());
      } else {
        summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i))
          .value = TextCellValue(val.toString());
      }
    }
    
    // حفظ الملف
    final dir = await getApplicationDocumentsDirectory();
    final name = fileName ?? 'fulus_export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}';
    final filePath = '${dir.path}/$name.xlsx';
    final fileBytes = excel.save();
    
    if (fileBytes != null) {
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);
      return filePath;
    }
    
    throw Exception('فشل في إنشاء ملف Excel');
  }
  
  static Future<void> exportAndShare({
    required List<Transaction> transactions,
    required List<Account> accounts,
  }) async {
    final filePath = await exportTransactions(
      transactions: transactions,
      accounts: accounts,
    );
    
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: 'تصدير بيانات Fulus',
      text: 'تم تصدير بيانات المعاملات والحسابات من تطبيق Fulus',
    );
  }
  
  static Future<String> exportMonthlyReport({
    required List<Transaction> transactions,
    required List<Account> accounts,
    required int month,
    required int year,
  }) async {
    final monthlyTx = transactions.where((t) => 
      t.date.month == month && t.date.year == year
    ).toList();
    
    final months = ['يناير','فبراير','مارس','أبريل','مايو','يونيو',
                    'يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'];
    final fileName = 'fulus_${months[month-1]}_$year';
    
    return exportTransactions(
      transactions: monthlyTx,
      accounts: accounts,
      fileName: fileName,
    );
  }
}
