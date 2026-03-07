# 💰 Fulus - مدير المصاري

تطبيق Flutter احترافي لإدارة المصاري الشخصية.

---

## 🚀 كيف تبني APK بدون Android Studio — خطوة بخطوة

### الخطوة 1: ارفع الكود على GitHub

1. اذهب إلى **github.com** وسجّل دخول
2. اضغط **New repository**
3. اسمه: `fulus` — اختر **Public** — اضغط **Create**
4. ارفع كل ملفات المشروع:
   - اضغط **Add file → Upload files**
   - اسحب كل الملفات وارفعها
   - اضغط **Commit changes**

---

### الخطوة 2: افتح Codemagic

1. اذهب إلى **codemagic.io**
2. سجّل دخول بحساب GitHub
3. اضغط **Add application**
4. اختر المستودع `fulus`
5. اختر **Flutter App**

---

### الخطوة 3: ابنِ APK

1. اضغط **Start your first build**
2. انتظر 10-15 دقيقة ☕
3. بعد الانتهاء اضغط **Download** على ملف `.apk`
4. انقله لموبايلك وثبّته ✅

> ⚠️ لازم تفعّل "تثبيت من مصادر غير معروفة" في إعدادات الأندرويد

---

## ✨ مميزات التطبيق

| الميزة | التفاصيل |
|--------|----------|
| 🏦 حسابات متعددة | مع دعم 9 عملات |
| 💸 معاملات | إيرادات ومصاريف مع 15 تصنيف |
| 📊 تقارير | Pie Chart + Bar Chart |
| 🎯 ميزانية | تتبع الإنفاق الشهري |
| 🔄 تحويل | بين الحسابات مع سعر صرف |
| 🌙 Dark Mode | واجهة داكنة/فاتحة |
| 💾 SQLite | بيانات محفوظة محلياً |

---

## 📁 هيكل المشروع

```
lib/
├── main.dart                 # Entry point + Navigation
├── models/models.dart        # Data models
├── providers/app_provider.dart # State management
├── utils/database.dart       # SQLite database
├── theme/app_theme.dart      # Colors + Typography
├── widgets/shared_widgets.dart # Reusable components
└── screens/
    ├── home_screen.dart
    ├── add_transaction_screen.dart
    ├── reports_screen.dart
    └── other_screens.dart    # Accounts, Budget, Transfer, Transactions
```
