// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'كأس العالم 2026';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get register => 'إنشاء حساب';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get firstName => 'الاسم الأول';

  @override
  String get lastName => 'اسم العائلة';

  @override
  String get continueWith => 'أو تابع باستخدام';

  @override
  String get noAccount => 'ليس لديك حساب؟ ';

  @override
  String get alreadyAccount => 'لديك حساب بالفعل؟ ';

  @override
  String get welcomeBack => 'مرحباً بعودتك 👋';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get joinCompetition => 'انضم إلى مسابقة التوقعات';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get signInGoogle => 'جوجل';

  @override
  String get signInFacebook => 'فيسبوك';

  @override
  String get terms => 'شروط الاستخدام';

  @override
  String get privacy => 'سياسة الخصوصية';

  @override
  String termsText(Object terms, Object privacy) {
    return 'بإنشاء حساب، فإنك توافق على $terms و$privacy';
  }

  @override
  String get networkError => 'تحقق من اتصالك بالإنترنت';

  @override
  String get serverError => 'خطأ في الخادم، حاول مرة أخرى';

  @override
  String get unknownError => 'حدث خطأ ما';

  @override
  String get sessionExpired => 'انتهت الجلسة، سجل دخولك مجدداً';

  @override
  String get invalidEmail => 'بريد إلكتروني غير صالح';

  @override
  String get weakPassword => 'كلمة المرور ضعيفة جداً';

  @override
  String get emailInUse => 'البريد الإلكتروني مستخدم بالفعل';

  @override
  String get wrongPassword => 'كلمة المرور خاطئة';

  @override
  String get userNotFound => 'لا يوجد حساب لهذا البريد الإلكتروني';

  @override
  String get fieldRequired => 'هذا الحقل مطلوب';

  @override
  String get passwordMismatch => 'كلمات المرور غير متطابقة';

  @override
  String get home => 'الصفحة الرئيسية';

  @override
  String get matches => 'المباريات';

  @override
  String get pronostics => 'التوقعات';

  @override
  String get standings => 'الترتيب';

  @override
  String get news => 'الأخبار';
}
