// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'وي فاميلي';

  @override
  String get onboardingTitle1 => 'ابق قريبًا من من تحب';

  @override
  String get onboardingBody1 =>
      'شاهد مكان عائلتك، شارك موقعك، وتواصل معهم — كل ذلك في دائرة خاصة واحدة.';

  @override
  String get onboardingTitle2 => 'شجرة عائلتك، حية وتفاعلية';

  @override
  String get onboardingBody2 =>
      'أنشئ شجرة عائلة تفاعلية واربط الأقارب عبر الأجيال.';

  @override
  String get onboardingTitle3 => 'السلامة أولًا، دائمًا';

  @override
  String get onboardingBody3 =>
      'زر استغاثة بلمسة واحدة ومشاركة موقع مباشر يحافظ على سلامة الجميع دون إحساس بالمراقبة.';

  @override
  String get skip => 'تخطي';

  @override
  String get next => 'التالي';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get loginTitle => 'مرحبًا بك في وي فاميلي';

  @override
  String get loginSubtitle => 'أدخل رقم هاتفك للمتابعة';

  @override
  String get phoneHint => 'رقم الهاتف';

  @override
  String get continueBtn => 'متابعة';

  @override
  String get otpTitle => 'تحقق من رقمك';

  @override
  String otpSubtitle(String phone) {
    return 'أرسلنا رمزًا من ٦ أرقام إلى $phone';
  }

  @override
  String get otpHint => 'أدخل الرمز';

  @override
  String get resendCode => 'إعادة إرسال الرمز';

  @override
  String resendIn(int seconds) {
    return 'إعادة الإرسال خلال $seconds ثانية';
  }

  @override
  String get profileSetupTitle => 'أخبرنا عنك';

  @override
  String get nameHint => 'الاسم الكامل';

  @override
  String get birthDateHint => 'تاريخ الميلاد';

  @override
  String get genderMale => 'ذكر';

  @override
  String get genderFemale => 'أنثى';

  @override
  String get saveContinue => 'حفظ ومتابعة';

  @override
  String get createCircleTitle => 'أنشئ دائرة عائلتك';

  @override
  String get createCircleSubtitle => 'مساحة خاصة لعائلتك للمشاركة والسلامة';

  @override
  String get circleNameHint => 'اسم الدائرة';

  @override
  String get createCircle => 'إنشاء الدائرة';

  @override
  String get joinCircleTitle => 'انضم إلى دائرة';

  @override
  String get joinCircleSubtitle => 'أدخل رمز الدعوة المشترك معك';

  @override
  String get inviteCodeHint => 'رمز الدعوة';

  @override
  String get joinCircle => 'انضمام';

  @override
  String get or => 'أو';

  @override
  String get shareInvite => 'مشاركة رابط الدعوة';

  @override
  String get home => 'الرئيسية';

  @override
  String get location => 'الموقع';

  @override
  String get tree => 'الشجرة';

  @override
  String get safety => 'السلامة';

  @override
  String get chat => 'الدردشة';

  @override
  String get profile => 'الملف';

  @override
  String get people => 'الأشخاص';

  @override
  String get places => 'الأماكن';

  @override
  String get pets => 'الحيوانات';

  @override
  String get keys => 'المفاتيح';

  @override
  String get comingSoon => 'قريبًا';

  @override
  String get addPerson => 'إضافة شخص';

  @override
  String get premiumBanner => 'اشترك المميز';

  @override
  String get premiumBannerSub => 'افتح عضوية غير محدودة وسجل كامل';

  @override
  String get memberDetail => 'تفاصيل العضو';

  @override
  String get call => 'اتصال';

  @override
  String get message => 'رسالة';

  @override
  String get directions => 'الاتجاهات';

  @override
  String get battery => 'البطارية';

  @override
  String get lastUpdated => 'آخر تحديث';

  @override
  String get addRelative => 'إضافة قريب';

  @override
  String get searchTree => 'ابحث في العائلة';

  @override
  String get listView => 'قائمة';

  @override
  String get treeView => 'شجرة';

  @override
  String get about => 'نبذة';

  @override
  String get relatives => 'الأقارب';

  @override
  String get photos => 'الصور';

  @override
  String get stories => 'القصص';

  @override
  String get sendLocation => 'إرسال الموقع';

  @override
  String get typeMessage => 'اكتب رسالة';

  @override
  String get send => 'إرسال';

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get locationSharing => 'مشاركة الموقع';

  @override
  String get locationSharingSub => 'شارك موقعك المباشر مع دائرتك';

  @override
  String get ghostMode => 'الوضع الشبح';

  @override
  String get ghostModeSub => 'أوقف المشاركة دون مغادرة الدائرة';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get sos => 'استغاثة';

  @override
  String get sosHold => 'اضغط مطولًا لمدة ٣ ثوانٍ للتنبيه';

  @override
  String get emergencyContacts => 'جهات الاتصال الطارئة';

  @override
  String get sharingActive => 'مشاركة الموقع نشطة';

  @override
  String get sharingPaused => 'مشاركة الموقع متوقفة';

  @override
  String get relationFather => 'أب';

  @override
  String get relationMother => 'أم';

  @override
  String get relationSon => 'ابن';

  @override
  String get relationDaughter => 'ابنة';

  @override
  String get relationBrother => 'أخ';

  @override
  String get relationSister => 'أخت';

  @override
  String get relationHusband => 'زوج';

  @override
  String get relationWife => 'زوجة';

  @override
  String get relationGrandfather => 'جد';

  @override
  String get relationGrandmother => 'جدة';

  @override
  String get relationPaternalUncle => 'عم';

  @override
  String get relationMaternalUncle => 'خال';

  @override
  String get relationPaternalAunt => 'عمة';

  @override
  String get relationMaternalAunt => 'خالة';

  @override
  String get relationOther => 'آخر';

  @override
  String get selectRelation => 'اختر صلة القرابة';

  @override
  String get inviteToCircle => 'دعوة إلى الدائرة';

  @override
  String get inviteToCircleSub => 'أرسل دعوة دائرة مع هذا القريب';

  @override
  String get loading => 'جارٍ التحميل...';

  @override
  String get error => 'حدث خطأ ما';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get empty => 'لا يوجد شيء هنا بعد';

  @override
  String get onboardingSkipConfirm => 'يمكنك إعداد هذا لاحقًا في الإعدادات';

  @override
  String get skipDemo => 'تخطَّ الآن (تجريبي)';

  @override
  String get locationOff => 'الموقع مغلق — أعد المحاولة';

  @override
  String get emailHint => 'البريد الإلكتروني';

  @override
  String get passwordHint => 'كلمة المرور';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get authInvalid => 'أدخل بريدًا صالحًا وكلمة مرور من 6 أحرف على الأقل';

  @override
  String get authFailed => 'تعذر تسجيل الدخول. تحقق من اتصالك.';

  @override
  String get switchToSignup => 'جديد هنا؟ أنشئ حسابًا';

  @override
  String get switchToLogin => 'لديك حساب؟ سجّل الدخول';

  @override
  String get reset => 'إعادة تعيين';

  @override
  String get sosDemoNote => 'وضع تجريبي — لا تُرسل تنبيهات حقيقية';

  @override
  String get premiumTitle => 'افتح الميزات المميزة مجانًا';

  @override
  String get startFreeTrial => 'ابدأ التجربة المجانية';

  @override
  String get checkIn => 'تسجيل وصول';

  @override
  String get checkInSent => 'تم إرسال تسجيل الوصول إلى عائلتك';

  @override
  String get addPlace => 'إضافة مكان';

  @override
  String get placeNameHint => 'اسم المكان';

  @override
  String get save => 'حفظ';

  @override
  String get hereFor => 'موجود منذ';

  @override
  String get driving => 'يقود';

  @override
  String get moving => 'يتحرك';

  @override
  String get locationNotUpdating => 'الموقع لا يتم تحديثه';

  @override
  String get mapLayers => 'طبقات الخريطة';

  @override
  String get lightMap => 'فاتح';

  @override
  String get standardMap => 'قياسي';

  @override
  String get satelliteMap => 'قمر صناعي';

  @override
  String get fitAllMembers => 'عرض جميع أفراد العائلة';

  @override
  String get shareInviteTipTitle => 'أبقِ الجميع على اطلاع';

  @override
  String get shareInviteTipBody =>
      'شارك رمز الدعوة ليتمكن أفراد عائلتك من الانضمام إلى دائرتك.';

  @override
  String speedKmh(int speed) {
    return '$speed كم/س';
  }

  @override
  String durationDaysHours(int days, int hours) {
    return '$days يوم، $hours ساعة';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours ساعة $minutes دقيقة';
  }

  @override
  String updatedAgo(int minutes) {
    return 'آخر تحديث قبل $minutes دقيقة';
  }

  @override
  String get justNow => 'الآن';

  @override
  String durationMinutes(int minutes) {
    return '$minutes دقيقة';
  }
}
