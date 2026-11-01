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
  String get splashTagline => 'عائلتك، بأمان وتواصل';

  @override
  String get onboardingBadge1 => 'شبكة الحماية الحية';

  @override
  String get onboardingTitle1 => 'اجعل عائلتك قريبة';

  @override
  String get onboardingBody1 =>
      'تحديثات فورية، ونطاقات ذكية، وراحة بال في متناول يدك — أينما كان أحباؤك.';

  @override
  String get onboardingTrust1 => 'دوائر عائلية مشفّرة من الطرف إلى الطرف';

  @override
  String get onboardingBadge2 => 'شبكة العائلة الخاصة';

  @override
  String get onboardingTitle2 => 'اعرف مكان الجميع بأمان';

  @override
  String get onboardingBody2 =>
      'خصوصية بمستوى البنوك، واكتشاف فوري للحوادث، وتنبيهات نطاقات ذكية تصلك فقط عند الحاجة.';

  @override
  String get onboardingTrust2 => 'حماية على مدار الساعة وبدون بيع أي بيانات';

  @override
  String get onboardingTitle3 => 'ابنوا شجرة عائلتكم معًا';

  @override
  String get onboardingBody3 =>
      'احفظوا القصص العائلية، واحتفلوا بالمناسبات، ووثّقوا إرثكم المشترك عبر الأجيال.';

  @override
  String get onboardingHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get skip => 'تخطي';

  @override
  String get next => 'التالي';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get illMomInTransit => 'أمي • في الطريق';

  @override
  String get illLeoAtSchool => 'ليو • في المدرسة';

  @override
  String get illHomeZoneSafe => 'منطقة المنزل آمنة';

  @override
  String get illLiveGuardian => 'حماية مباشرة';

  @override
  String get illHomeZone => 'منطقة المنزل';

  @override
  String get illSafeActive => 'آمنة ونشطة';

  @override
  String get illSchoolZone => 'منطقة المدرسة';

  @override
  String get illArrived => 'وصل 8:30 صباحًا';

  @override
  String get illCrashReady => 'جاهز للحوادث';

  @override
  String get illBankLevelSafe => 'آمن بمستوى البنوك';

  @override
  String get illNanaRose => 'الجدة روز';

  @override
  String get illElenaMom => 'إيلينا (أمي)';

  @override
  String get illMarcus => 'ماركوس';

  @override
  String get illMayaAge => 'مايا، 7';

  @override
  String get illAnniversary => 'الذكرى الخمسون';

  @override
  String get illTales => '4 حكايات';

  @override
  String get illLiveMemory => 'أُضيفت ذكرى مباشرة';

  @override
  String get loginTitle => 'مرحبًا بعودتك';

  @override
  String get loginSubtitle =>
      'أدخل بريدك الإلكتروني لتسجيل الدخول أو إنشاء حساب عائلتك.';

  @override
  String get encryptedCircle => 'دائرة مشفّرة من الطرف إلى الطرف';

  @override
  String get bankGradePrivacy => 'خصوصية بمستوى البنوك';

  @override
  String get bankGradePrivacyBody =>
      'موقع عائلتك المباشر وأرشيف المحادثات والصور مشفّرة حصريًا بين أعضاء الدائرة المدعوين.';

  @override
  String get familiesConnected => 'أكثر من 240,000 عائلة مترابطة بأمان';

  @override
  String termsIntro(String appName) {
    return 'بالمتابعة، أنت توافق على شروط الخدمة وسياسة الخصوصية الخاصة بـ $appName. نحن نحمي بيانات عائلتك بتشفير بمستوى البنوك.';
  }

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
  String get myCircles => 'دوائرك';

  @override
  String get joinAnotherCircle => 'انضم إلى دائرة أخرى أو أنشئها';

  @override
  String get circleAddSubtitle =>
      'يمكنك الانضمام إلى أكثر من دائرة عائلية. أنشئ دائرة جديدة أو انضم باستخدام رمز الدعوة.';

  @override
  String get activeCircle => 'النشطة';

  @override
  String switchedCircle(String name) {
    return 'تم التبديل إلى $name';
  }

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
  String get aboutHint => 'كلمات قليلة عن هذا الشخص';

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
  String get relationSelf => 'أنت';

  @override
  String get relationChild => 'ابن/ابنة';

  @override
  String get relationParent => 'أحد الوالدين';

  @override
  String get relationSibling => 'أخ/أخت';

  @override
  String get relationNephew => 'ابن الأخ';

  @override
  String get relationNiece => 'ابنة الأخ';

  @override
  String get relationGrandson => 'حفيد';

  @override
  String get relationGranddaughter => 'حفيدة';

  @override
  String get relationRelative => 'قريب';

  @override
  String get selectRelation => 'اختر صلة القرابة';

  @override
  String get inviteToCircle => 'دعوة إلى الدائرة';

  @override
  String get inviteToCircleSub => 'أرسل دعوة دائرة مع هذا القريب';

  @override
  String get treeEmpty => 'شجرة عائلتك في انتظارك';

  @override
  String get treeEmptyBody => 'أضف أول قريب لبدء بناء الشجرة.';

  @override
  String get addFirstRelative => 'أضف أول قريب';

  @override
  String addRelativeOf(String name) {
    return 'أضف قريبًا لـ $name';
  }

  @override
  String get editPerson => 'تعديل الشخص';

  @override
  String get deletePerson => 'حذف الشخص';

  @override
  String deletePersonConfirm(String name) {
    return 'هل تريد إزالة $name من شجرة العائلة؟';
  }

  @override
  String get deletePersonBody =>
      'سيؤدي هذا إلى إزالة قيد الشجرة فقط، وليس عضو الدائرة.';

  @override
  String get delete => 'حذف';

  @override
  String get birthday => 'تاريخ الميلاد';

  @override
  String get selectDate => 'اختر التاريخ';

  @override
  String get gender => 'الجنس';

  @override
  String get genderOther => 'آخر';

  @override
  String get optional => 'اختياري';

  @override
  String get photoUrl => 'رابط الصورة';

  @override
  String get photoUrlHint => 'https://example.com/photo.jpg';

  @override
  String get noPhotos => 'لا توجد صورة بعد';

  @override
  String get addPhoto => 'إضافة صورة';

  @override
  String get changePhoto => 'تغيير الصورة';

  @override
  String get removePhoto => 'إزالة الصورة';

  @override
  String get linkedMember => 'في دائرتك';

  @override
  String get linkMember => 'اربط بعضو في الدائرة';

  @override
  String get linkMemberHint => 'اختياري';

  @override
  String get notLinked => 'ليس في دائرتك';

  @override
  String get noRelativesYet => 'لم تتم إضافة أقارب بعد';

  @override
  String get parents => 'الوالدان';

  @override
  String get grandparents => 'الأجداد';

  @override
  String get children => 'الأبناء';

  @override
  String get siblings => 'الإخوة';

  @override
  String get spouse => 'الزوج/الزوجة';

  @override
  String get otherRelatives => 'أقارب آخرون';

  @override
  String bornYear(String year) {
    return 'ولد عام $year';
  }

  @override
  String ageYears(String age) {
    return '$age سنة';
  }

  @override
  String personAdded(String name) {
    return 'تمت إضافة $name إلى شجرة العائلة';
  }

  @override
  String get personUpdated => 'تم تحديث شجرة العائلة';

  @override
  String get personRemoved => 'تمت الإزالة من شجرة العائلة';

  @override
  String get treeSaveError => 'تعذّر الحفظ. حاول مرة أخرى.';

  @override
  String get treeDeleteError => 'تعذّر الحذف. حاول مرة أخرى.';

  @override
  String get relationRequired => 'اختر صلة القرابة';

  @override
  String get nameRequired => 'أدخل الاسم';

  @override
  String get memberAlreadyLinked => 'هذا العضو موجود بالفعل في الشجرة';

  @override
  String get inviteCodeCopied => 'تم نسخ رمز الدعوة';

  @override
  String get treeHint => 'اضغط على أي شخص لفتح ملفه';

  @override
  String get treeHeroTitle => 'حكاية عائلتنا';

  @override
  String get treeHeroBody => 'كل اسم يحمل حكاية. حافظ على إرث عائلتك.';

  @override
  String get treePeople => 'الأفراد';

  @override
  String get treeGenerations => 'الأجيال';

  @override
  String get treeInCircle => 'في الدائرة';

  @override
  String generationLabel(String n) {
    return 'الجيل $n';
  }

  @override
  String get treeSearchEmpty => 'لم يتم العثور على أي فرد من العائلة';

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
  String get walking => 'يمشي';

  @override
  String get cycling => 'بالدراجة';

  @override
  String get atRest => 'متوقف';

  @override
  String get you => 'أنت';

  @override
  String get activity => 'النشاط';

  @override
  String get distance => 'المسافة';

  @override
  String get etaLabel => 'الوصول';

  @override
  String get noLocationYet => 'لا يوجد موقع بعد';

  @override
  String kmValue(String value) {
    return '$value كم';
  }

  @override
  String mValue(String value) {
    return '$value م';
  }

  @override
  String minValue(String value) {
    return '$value دقيقة';
  }

  @override
  String hrMinValue(String hours, String minutes) {
    return '$hours س $minutes د';
  }

  @override
  String awayFromYou(String distance) {
    return 'يبعد عنك $distance';
  }

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

  @override
  String get locationPromptTitle => 'شارك موقعك مع عائلتك';

  @override
  String get locationPromptBody =>
      'ترى دائرتك موقعك المباشر على الخريطة مع مستوى بطارية جهازك. لا يراه إلا أعضاء دائرتك.';

  @override
  String get locationPromptPrivacy =>
      'يمكنك إيقاف المشاركة في أي وقت عبر وضع التخفي.';

  @override
  String get shareWhileUsing => 'السماح أثناء استخدام التطبيق';

  @override
  String get shareAlways => 'السماح دائمًا';

  @override
  String get allowBackgroundTitle => 'استمر في المشاركة في الخلفية';

  @override
  String get allowBackgroundBody =>
      'لتبقى الخريطة محدثة عند إغلاق التطبيق، اسمح بالوصول إلى الموقع دائمًا. قد تحتاج إلى اختيار ذلك من الإعدادات على أندرويد.';

  @override
  String get notNow => 'ليس الآن';

  @override
  String get openSettings => 'فتح الإعدادات';

  @override
  String get locationDeniedTitle => 'إذن الموقع مطلوب';

  @override
  String get locationDeniedBody =>
      'الوصول إلى الموقع متوقف. فعّله من إعدادات النظام ليتمكن أفراد عائلتك من معرفة مكانك.';

  @override
  String get backgroundTipsTitle => 'حسّن الاستمرارية في الخلفية';

  @override
  String get backgroundTipsBody =>
      'بعض الهواتف (شاومي، أوبو، فيفو، سامسونج) توقف التطبيقات في الخلفية. اسمح لـ WeFamily بالعمل دون قيود البطارية.';

  @override
  String get disableOptimization => 'إيقاف تحسين البطارية';

  @override
  String get offline => 'غير متصل';

  @override
  String get myCircle => 'دائرتي';

  @override
  String get sharingNotificationTitle => 'WeFamily يشارك موقعك';

  @override
  String get sharingNotificationBody => 'يمكن لعائلتك رؤية موقعك المباشر.';

  @override
  String get enterCircleName => 'أدخل اسم الدائرة';

  @override
  String get invalidCode =>
      'رمز الدعوة غير صالح. تحقق من الرمز وحاول مرة أخرى.';

  @override
  String get alreadyMember => 'أنت بالفعل عضو في هذه الدائرة.';

  @override
  String get circleFull => 'هذه الدائرة ممتلئة (10 أعضاء كحد أقصى).';

  @override
  String get noInternet => 'لا يوجد اتصال بالإنترنت. حاول مرة أخرى.';

  @override
  String get joinFailed => 'تعذر الانضمام إلى الدائرة. حاول مرة أخرى.';

  @override
  String get manageCircle => 'إدارة الدائرة';

  @override
  String get inviteCode => 'رمز الدعوة';

  @override
  String get copyCode => 'نسخ الرمز';

  @override
  String get codeCopied => 'تم نسخ الرمز';

  @override
  String get regenerateCode => 'تجديد الرمز';

  @override
  String get regenerateConfirm =>
      'سيتوقف الرمز القديم عن العمل فورًا. هل تريد المتابعة؟';

  @override
  String get regenerateSuccess => 'تم إنشاء رمز دعوة جديد';

  @override
  String get removeMember => 'إزالة';

  @override
  String removeMemberConfirm(String name) {
    return 'إزالة $name من الدائرة؟';
  }

  @override
  String get leaveCircle => 'مغادرة الدائرة';

  @override
  String get leaveCircleConfirm => 'ستتوقف عن مشاركة موقعك مع هذه الدائرة.';

  @override
  String get deleteCircle => 'حذف الدائرة';

  @override
  String get deleteCircleConfirm =>
      'سيتم حذف الدائرة للجميع. لا يمكن التراجع عن هذا.';

  @override
  String get circleDeleted => 'تم حذف الدائرة';

  @override
  String get leftCircle => 'لقد غادرت الدائرة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get whatsapp => 'واتساب';

  @override
  String get circleMembers => 'الأعضاء';

  @override
  String get owner => 'المالك';

  @override
  String shareInviteMessage(String code, String link) {
    return 'انضم إلى عائلتي على WeFamily! الرمز: $code | $link';
  }

  @override
  String get chatEmpty => 'لا توجد رسائل بعد. قل مرحبًا!';

  @override
  String get attach => 'إرفاق';

  @override
  String get camera => 'الكاميرا';

  @override
  String get gallery => 'المعرض';

  @override
  String get photo => 'صورة';

  @override
  String get voiceNote => 'رسالة صوتية';

  @override
  String get holdToRecord => 'اضغط للتسجيل، اسحب للإلغاء';

  @override
  String get slideToCancel => 'اسحب للإلغاء';

  @override
  String get releaseToSend => 'أفلت للإرسال';

  @override
  String get releaseToCancel => 'أفلت للإلغاء';

  @override
  String get tapToStop => 'اضغط على الميكروفون للإيقاف';

  @override
  String get micDeniedTitle => 'مطلوب الوصول إلى الميكروفون';

  @override
  String get micDeniedBody =>
      'اسمح بالوصول إلى الميكروفون لإرسال رسائل صوتية إلى عائلتك.';

  @override
  String get quickOnMyWay => 'أنا في الطريق';

  @override
  String get quickReached => 'لقد وصلت';

  @override
  String get quickCallMe => 'اتصل بي';

  @override
  String get openOnMap => 'افتح على الخريطة';

  @override
  String get recording => 'جارٍ التسجيل';

  @override
  String get today => 'اليوم';

  @override
  String get yesterday => 'أمس';

  @override
  String get presenceMode => 'حالتك';

  @override
  String get setMode => 'حدد حالتك';

  @override
  String get modeSubtitle => 'تظهر بجانب صورتك على خريطة العائلة.';

  @override
  String get modeAuto => 'تلقائي';

  @override
  String get modeDriving => 'قيادة';

  @override
  String get modeHome => 'في المنزل';

  @override
  String get modeWork => 'في العمل';

  @override
  String get modeOutside => 'بالخارج';

  @override
  String get modeEvent => 'في مناسبة';

  @override
  String get modeUpdated => 'تم تحديث الحالة';

  @override
  String get modeCleared => 'تم ضبط الحالة على تلقائي';

  @override
  String get modeSaveError => 'تعذر تحديث الحالة';

  @override
  String membersOnline(int members, int online) {
    return '$members أعضاء · $online متصل';
  }

  @override
  String membersCount(int count) {
    return '$count أعضاء';
  }

  @override
  String get mapRealistic => 'واقعية';

  @override
  String get onlineNow => 'متصل';

  @override
  String sosAlertTitle(String name) {
    return '$name بحاجة إلى مساعدة';
  }

  @override
  String get sosAlertBody =>
      'تم الضغط على SOS. موقعه المباشر يظهر باللون الأحمر على الخريطة.';

  @override
  String get sosActiveTitle => 'تنبيه SOS الخاص بك مفعّل';

  @override
  String get sosActiveBody => 'تم إشعار دائرتك بموقعك الدقيق.';

  @override
  String get sosSent => 'تم إرسال SOS إلى دائرتك';

  @override
  String get sosCancel => 'إلغاء SOS';

  @override
  String get sosCancelled => 'تم إلغاء SOS';

  @override
  String get sosUnable => 'تعذر إرسال SOS. تحقق من اتصالك.';

  @override
  String get sosNoLocation => 'الموقع غير متاح. شغّل GPS وحاول مجددًا.';

  @override
  String get sosShowOnMap => 'عرض على الخريطة';

  @override
  String get sosNotified => 'سيتم إشعار دائرتك فورًا';

  @override
  String sosSentAt(String time) {
    return 'أُرسل $time';
  }

  @override
  String get sosResolveConfirm => 'هل تريد إلغاء تنبيه SOS للجميع؟';

  @override
  String get sosRecent => 'تنبيهات الطوارئ';

  @override
  String get noAlerts => 'لا توجد تنبيهات طوارئ الآن';

  @override
  String get sosWaiting => 'جارٍ تحديد موقعك الدقيق…';

  @override
  String get view => 'عرض';

  @override
  String get dismiss => 'إغلاق';

  @override
  String get chatWithCircle => 'الدردشة مع دائرتك';

  @override
  String get startConversation => 'ابدأ المحادثة — ستصل إلى عائلتك فورًا.';

  @override
  String get sayHello => 'قل مرحبًا';

  @override
  String get familyOrbitTitle => 'مدار العائلة';

  @override
  String get familyMapTitle => 'خريطة العائلة';

  @override
  String familyMapMembersHint(int count) {
    return '$count أعضاء · اضغط على أي دبوس لتغيير نقطة البداية';
  }

  @override
  String get familyMapLive => 'مباشر';

  @override
  String get familyMapLegend => 'أقصر مسار طريق';

  @override
  String get familyMapFrom => 'المسافات من';

  @override
  String get familyMapNearest => 'الأقرب';

  @override
  String get familyMapFarthest => 'الأبعد';

  @override
  String familyMapMinDrive(int minutes) {
    return '$minutes دقيقة بالسيارة';
  }

  @override
  String get familyMapNow => 'الآن';

  @override
  String familyMapMinAgo(int minutes) {
    return 'منذ $minutes دقيقة';
  }

  @override
  String familyMapHourAgo(int hours) {
    return 'منذ $hours ساعة';
  }

  @override
  String familyMapDayAgo(int days) {
    return 'منذ $days يوم';
  }

  @override
  String membersRecenter(int count) {
    return '$count أفراد · اضغط على أي شخص لإعادة التركيز';
  }

  @override
  String get backToMe => 'العودة إليك';

  @override
  String get relationPartner => 'الشريك';

  @override
  String get relationGrandparent => 'جد/جدة';

  @override
  String get relationGrandchild => 'حفيد/حفيدة';

  @override
  String yourRelation(String relation) {
    return 'خاصتك: $relation';
  }

  @override
  String get addParent => '+ والد';

  @override
  String get addSibling => '+ أخ/أخت';

  @override
  String get addPartner => '+ شريك';

  @override
  String get addChild => '+ طفل';

  @override
  String get memberAdded => 'تمت إضافة فرد';

  @override
  String get alreadyTwoParents => 'لديه بالفعل والدان';

  @override
  String get partnerAlready => 'تمت إضافة الشريك مسبقاً';

  @override
  String get treeSiblingNeedsParent =>
      'أضف أحد الوالدين أولاً حتى يمكن ربط الأخ أو الأخت';
}
