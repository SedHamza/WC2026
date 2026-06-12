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
  String get rooms => 'الغرف';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get news => 'الأخبار';

  @override
  String get todayMatches => 'مباريات اليوم';

  @override
  String get noMatchToday => 'لا توجد مباريات اليوم';

  @override
  String get tournamentStarts => 'تبدأ البطولة في 11 يونيو 2026';

  @override
  String get liveMatches => 'مباشر';

  @override
  String get upcomingMatches => 'قادمة';

  @override
  String get finishedMatches => 'منتهية';

  @override
  String get allGroups => 'الكل';

  @override
  String group(Object name) {
    return 'المجموعة $name';
  }

  @override
  String get knockoutStage => 'مرحلة الإقصاء';

  @override
  String get byDate => 'حسب التاريخ';

  @override
  String get searchTeam => 'ابحث عن فريق...';

  @override
  String get noMatchFound => 'لا توجد مباريات';

  @override
  String get matchInfo => 'معلومات المباراة';

  @override
  String get competition => 'المسابقة';

  @override
  String get stage => 'المرحلة';

  @override
  String matchday(Object number) {
    return 'الجولة $number';
  }

  @override
  String get date => 'التاريخ';

  @override
  String get time => 'الوقت';

  @override
  String get live => 'مباشر';

  @override
  String get finished => 'انتهت';

  @override
  String get vs => 'ضد';

  @override
  String get myPronostic => 'توقعي';

  @override
  String get exactScore => 'النتيجة الدقيقة';

  @override
  String get otherPronostics => 'توقعات أخرى';

  @override
  String get exactScorePts => '25 نقطة';

  @override
  String get otherPtsMax => 'حتى 29 نقطة';

  @override
  String get confirmPronostic => 'تأكيد التوقع';

  @override
  String get updatePronostic => 'تحديث';

  @override
  String get pronosticSaved => 'تم حفظ التوقع';

  @override
  String get clearPronostic => 'مسح';

  @override
  String get lockedMatch => 'بدأت المباراة — التوقع مغلق';

  @override
  String get whoWins => 'من سيفوز؟';

  @override
  String get maxGoals => 'الحد الأقصى للأهداف';

  @override
  String get minGoals => 'الحد الأدنى للأهداف';

  @override
  String get draw => 'تعادل';

  @override
  String potentialPts(Object pts) {
    return '$pts نقطة';
  }

  @override
  String totalEstimated(Object pts) {
    return 'الإجمالي المتوقع → $pts نقطة';
  }

  @override
  String get exactResult => 'نتيجة دقيقة → 29 نقطة';

  @override
  String get myRooms => 'غرفي';

  @override
  String get createRoom => 'إنشاء غرفة';

  @override
  String get joinRoom => 'الانضمام';

  @override
  String get joinWithCode => 'الانضمام برمز';

  @override
  String get noRooms => 'لا توجد غرف بعد';

  @override
  String get noRoomsSubtitle => 'أنشئ غرفة وادعُ أصدقاءك للعب معاً!';

  @override
  String get roomName => 'اسم الغرفة';

  @override
  String get roomNameHint => 'مثال: الأصدقاء، العائلة...';

  @override
  String get roomCode => 'رمز الغرفة';

  @override
  String get roomCodeHint => 'WC26-XXXX';

  @override
  String get roomCreated => 'تم إنشاء الغرفة! 🎉';

  @override
  String roomCreatedSuccess(Object name) {
    return 'تم إنشاء $name بنجاح.';
  }

  @override
  String get shareCode => 'شارك هذا الرمز مع أصدقائك:';

  @override
  String get great => 'رائع!';

  @override
  String get leaveRoom => 'مغادرة الغرفة';

  @override
  String leaveRoomConfirm(Object name) {
    return 'ستغادر \"$name\".';
  }

  @override
  String get leaveRoomTitle => 'مغادرة الغرفة؟';

  @override
  String get cancel => 'إلغاء';

  @override
  String get leave => 'مغادرة';

  @override
  String get members => 'الأعضاء';

  @override
  String get myRank => 'ترتيبي';

  @override
  String get myPoints => 'نقاطي';

  @override
  String get memberPronostics => 'توقعات الأعضاء';

  @override
  String get leaderboard => 'الترتيب';

  @override
  String get codeCopied => 'تم نسخ الرمز!';

  @override
  String get noPronosticsYet => 'لا توجد توقعات بعد';

  @override
  String get beFirstToPronostic => 'كن أول من يتوقع!';

  @override
  String get visibleAfterStart => 'مرئي بعد بداية المباراة';

  @override
  String get noPronostic => 'لا يوجد توقع';

  @override
  String get didNotPronostic => 'لم يتوقع';

  @override
  String get modify => 'تعديل →';

  @override
  String get invalidCode => 'رمز غير صالح — الغرفة غير موجودة';

  @override
  String get askCodeFromAdmin => 'اطلب الرمز من مسؤول الغرفة.';

  @override
  String get myProfile => 'الملف الشخصي';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get totalPoints => 'مجموع النقاط';

  @override
  String get totalPronostics => 'التوقعات';

  @override
  String get avgPtsPerMatch => 'متوسط النقاط';

  @override
  String get statistics => 'الإحصائيات';

  @override
  String get exactScores => 'نتائج دقيقة';

  @override
  String get successRate => 'نسبة النجاح';

  @override
  String get bestMatch => 'أفضل مباراة';

  @override
  String get correctWinners => 'فائزون صحيحون';

  @override
  String get pronosticHistory => 'سجل التوقعات';

  @override
  String get noPronosticsHistory => 'لا توجد توقعات بعد';

  @override
  String get makeFirstPronostic => 'ابدأ بتوقعاتك الأولى!';

  @override
  String maxPts(Object pts, Object status) {
    return 'الحد الأقصى: $pts نقطة · $status';
  }

  @override
  String get pending => 'في الانتظار';

  @override
  String get inProgress => 'مباشر';

  @override
  String get mode => 'الوضع';

  @override
  String get predictedScore => 'النتيجة المتوقعة';

  @override
  String get whoWon => 'من يفوز';

  @override
  String maxGoalsLabel(Object n) {
    return 'الحد الأقصى (≤$n)';
  }

  @override
  String minGoalsLabel(Object n) {
    return 'الحد الأدنى (≥$n)';
  }

  @override
  String get totalObtained => 'المجموع المحصّل';

  @override
  String get close => 'إغلاق';

  @override
  String get edit => 'تعديل';

  @override
  String get exactScoreMode => 'نتيجة دقيقة';

  @override
  String get otherMode => 'توقعات أخرى';

  @override
  String groupStandings(Object name) {
    return 'المجموعة $name';
  }

  @override
  String get bestThirds => 'أفضل ثالث';

  @override
  String get bestThirdsSubtitle => '8 مؤهلون من 12 مجموعة — قواعد الفيفا';

  @override
  String get qualifiedFor32 => 'مؤهل لدور الـ32';

  @override
  String get eliminated => 'مقصي';

  @override
  String get availableAfterGroups => 'متاح بعد دور المجموعات';

  @override
  String get qualified => 'مؤهل';

  @override
  String get possibleThird => 'ثالث محتمل';

  @override
  String get played => 'ل';

  @override
  String get won => 'ف';

  @override
  String get drawnShort => 'ت';

  @override
  String get lost => 'خ';

  @override
  String get points => 'ن';

  @override
  String get team => 'الفريق';

  @override
  String get groupShort => 'المجموعة';

  @override
  String get groupMatches => 'مباريات المجموعة';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get connectionError => 'خطأ في الاتصال';

  @override
  String get loadingError => 'خطأ في التحميل';

  @override
  String get me => 'أنا';

  @override
  String get chooseDate => 'اختر تاريخاً';

  @override
  String get clearDate => 'مسح';

  @override
  String get last32 => 'دور الـ32';

  @override
  String get last16 => 'دور الـ16';

  @override
  String get quarterFinals => 'ربع النهائي';

  @override
  String get semiFinals => 'نصف النهائي';

  @override
  String get thirdPlace => 'المركز الثالث';

  @override
  String get finalMatch => 'النهائي';

  @override
  String get all => 'الكل';

  @override
  String joinedRoom(Object name) {
    return 'انضممت إلى \"$name\"!';
  }

  @override
  String finalResult(Object home, Object away) {
    return 'النتيجة النهائية: $home - $away';
  }

  @override
  String get settings => 'الإعدادات';

  @override
  String get account => 'الحساب';

  @override
  String get appearance => 'المظهر';

  @override
  String get language => 'اللغة';

  @override
  String get memberSince => 'عضو منذ';

  @override
  String get pseudo => 'اسم المستخدم';

  @override
  String get darkMode => 'المظهر';

  @override
  String get testMode => 'وضع الاختبار';

  @override
  String get testModeSubtitle => 'محاكي المباريات';

  @override
  String get appVersion => 'الإصدار';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get deleteAccountConfirm => 'هذا الإجراء لا يمكن التراجع عنه.';

  @override
  String get delete => 'حذف';

  @override
  String get application => 'تطبيق';

  @override
  String get testModeUnlocked => '🧪 تم تفعيل وضع الاختبار!';

  @override
  String get editPseudo => 'تعديل الاسم';

  @override
  String get pseudoHint => 'اسمك...';

  @override
  String get save => 'حفظ';

  @override
  String get pseudoUpdated => 'تم تحديث الاسم!';

  @override
  String get tournament => 'البطولة';

  @override
  String get exactScoreLabel => 'النتيجة الدقيقة';

  @override
  String get winnerLabel => 'الفائز';

  @override
  String maxGoalsLabel2(Object n) {
    return 'الحد الأقصى ≤$n أهداف';
  }

  @override
  String minGoalsLabel2(Object n) {
    return 'الحد الأدنى ≥$n أهداف';
  }

  @override
  String currentScore(Object home, Object away) {
    return 'النتيجة الحالية: $home - $away';
  }

  @override
  String livePoints(Object pts) {
    return '🔴 $pts نقطة مباشر';
  }

  @override
  String get maxGoalsFormula => '(7 - القيمة) × 3 نقطة';

  @override
  String get minGoalsFormula => 'القيمة × 3 نقطة';

  @override
  String get hasPronostic => 'تم التوقع';

  @override
  String get bothTeamsScore => 'هل سيسجل كل الفريقين؟';

  @override
  String bothTeamsScoreLabel(Object choice) {
    return 'تسجيل الفريقين: $choice';
  }

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';
}
