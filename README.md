# 💰 Fulus - مدير المصاري الذكي

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.0+-blue?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green" alt="Platform">
  <img src="https://img.shields.io/badge/License-MIT-yellow" alt="License">
</p>

## 📱 نظرة عامة

**Fulus** هو تطبيق إدارة مالية شخصية احترافي مبني بـ Flutter. يساعدك على تتبع مصاريفك ودخلك، إدارة حساباتك المتعددة، وتحليل إنفاقك بطريقة سهلة وجميلة.

## ✨ المميزات

- 🏦 **إدارة حسابات متعددة** - أضف حسابات بعملات مختلفة
- 💸 **تتبع المعاملات** - سجّل دخلك ومصاريفك بسهولة
- 📊 **تقارير ورسوم بيانية** - تحليل شامل لإنفاقك
- 🎯 **ميزانية شهرية** - حدد ميزانيتك وتابع التزامك بها
- ↔️ **تحويل بين الحسابات** - مع دعم أسعار الصرف
- 📤 **تصدير إلى Excel** - صدّر بياناتك بسهولة
- 🌙 **الوضع الداكن** - واجهة أنيقة ومريحة للعين
- 🌍 **دعم عملات متعددة** - USD, EUR, SYP, SAR, AED, TRY, وأكثر

## 🚀 البدء السريع

### المتطلبات
- Flutter SDK 3.0+
- Dart SDK 3.0+
- Android Studio / Xcode

### التثبيت

```bash
# استنساخ المشروع
git clone https://github.com/your-username/fulus.git
cd fulus

# تثبيت التبعيات
flutter pub get

# تشغيل التطبيق
flutter run
```

## 🏗️ البناء

### Android
```bash
# APK للتصحيح
flutter build apk --debug

# APK للإنتاج
flutter build apk --release

# App Bundle للنشر على Play Store
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 📁 هيكل المشروع

```
lib/
├── main.dart              # نقطة البداية
├── models/
│   └── models.dart        # النماذج (Account, Transaction, etc.)
├── providers/
│   └── app_provider.dart  # إدارة الحالة
├── screens/
│   ├── home_screen.dart
│   ├── add_transaction_screen.dart
│   ├── reports_screen.dart
│   ├── settings_screen.dart
│   └── other_screens.dart
├── theme/
│   └── app_theme.dart     # الثيم والألوان
├── utils/
│   ├── database.dart      # قاعدة البيانات SQLite
│   └── excel_export.dart  # تصدير Excel
└── widgets/
    └── shared_widgets.dart # الودجات المشتركة
```

## 🔧 البناء على Codemagic

المشروع مُعد للبناء على [Codemagic](https://codemagic.io):

1. اربط مستودعك على Codemagic
2. سيتم الكشف تلقائياً عن `codemagic.yaml`
3. ابدأ البناء!

## 📦 التبعيات الرئيسية

| الحزمة | الاستخدام |
|--------|-----------|
| `provider` | إدارة الحالة |
| `sqflite` | قاعدة البيانات المحلية |
| `fl_chart` | الرسوم البيانية |
| `excel` | تصدير Excel |
| `share_plus` | مشاركة الملفات |
| `google_fonts` | خط Tajawal العربي |
| `flutter_animate` | الرسوم المتحركة |

## 🤝 المساهمة

نرحب بمساهماتكم! يرجى فتح Issue أو Pull Request.

## 📄 الرخصة

هذا المشروع مرخص تحت رخصة MIT

---

<p align="center">
  Made with ❤️ using Flutter
</p>
