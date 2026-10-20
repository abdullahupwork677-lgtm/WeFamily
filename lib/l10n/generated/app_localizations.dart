import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'WeFamily'**
  String get appName;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Stay close to the ones you love'**
  String get onboardingTitle1;

  /// No description provided for @onboardingBody1.
  ///
  /// In en, this message translates to:
  /// **'See where your family is, share your location, and check in — all in one private circle.'**
  String get onboardingBody1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Your family tree, alive'**
  String get onboardingTitle2;

  /// No description provided for @onboardingBody2.
  ///
  /// In en, this message translates to:
  /// **'Build an interactive family tree and connect relatives across generations.'**
  String get onboardingBody2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Safety first, always'**
  String get onboardingTitle3;

  /// No description provided for @onboardingBody3.
  ///
  /// In en, this message translates to:
  /// **'One-tap SOS and live location sharing keep everyone safe without feeling watched.'**
  String get onboardingBody3;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to WeFamily'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number to continue'**
  String get loginSubtitle;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneHint;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your number'**
  String get otpTitle;

  /// No description provided for @otpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to {phone}'**
  String otpSubtitle(String phone);

  /// No description provided for @otpHint.
  ///
  /// In en, this message translates to:
  /// **'Enter code'**
  String get otpHint;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String resendIn(int seconds);

  /// No description provided for @profileSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about you'**
  String get profileSetupTitle;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get nameHint;

  /// No description provided for @birthDateHint.
  ///
  /// In en, this message translates to:
  /// **'Birth date'**
  String get birthDateHint;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @saveContinue.
  ///
  /// In en, this message translates to:
  /// **'Save & continue'**
  String get saveContinue;

  /// No description provided for @createCircleTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your family circle'**
  String get createCircleTitle;

  /// No description provided for @createCircleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A private space for your family to share and stay safe'**
  String get createCircleSubtitle;

  /// No description provided for @circleNameHint.
  ///
  /// In en, this message translates to:
  /// **'Circle name'**
  String get circleNameHint;

  /// No description provided for @createCircle.
  ///
  /// In en, this message translates to:
  /// **'Create circle'**
  String get createCircle;

  /// No description provided for @joinCircleTitle.
  ///
  /// In en, this message translates to:
  /// **'Join a circle'**
  String get joinCircleTitle;

  /// No description provided for @joinCircleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the invite code shared with you'**
  String get joinCircleSubtitle;

  /// No description provided for @inviteCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Invite code'**
  String get inviteCodeHint;

  /// No description provided for @joinCircle.
  ///
  /// In en, this message translates to:
  /// **'Join circle'**
  String get joinCircle;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @shareInvite.
  ///
  /// In en, this message translates to:
  /// **'Share invite link'**
  String get shareInvite;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @tree.
  ///
  /// In en, this message translates to:
  /// **'Tree'**
  String get tree;

  /// No description provided for @safety.
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get safety;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @people.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get people;

  /// No description provided for @places.
  ///
  /// In en, this message translates to:
  /// **'Places'**
  String get places;

  /// No description provided for @pets.
  ///
  /// In en, this message translates to:
  /// **'Pets'**
  String get pets;

  /// No description provided for @keys.
  ///
  /// In en, this message translates to:
  /// **'Keys'**
  String get keys;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @addPerson.
  ///
  /// In en, this message translates to:
  /// **'Add a person'**
  String get addPerson;

  /// No description provided for @premiumBanner.
  ///
  /// In en, this message translates to:
  /// **'Go Premium'**
  String get premiumBanner;

  /// No description provided for @premiumBannerSub.
  ///
  /// In en, this message translates to:
  /// **'Unlock unlimited members and history'**
  String get premiumBannerSub;

  /// No description provided for @memberDetail.
  ///
  /// In en, this message translates to:
  /// **'Member details'**
  String get memberDetail;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @directions.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get directions;

  /// No description provided for @battery.
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get battery;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated'**
  String get lastUpdated;

  /// No description provided for @addRelative.
  ///
  /// In en, this message translates to:
  /// **'Add relative'**
  String get addRelative;

  /// No description provided for @searchTree.
  ///
  /// In en, this message translates to:
  /// **'Search family'**
  String get searchTree;

  /// No description provided for @listView.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get listView;

  /// No description provided for @treeView.
  ///
  /// In en, this message translates to:
  /// **'Tree'**
  String get treeView;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @relatives.
  ///
  /// In en, this message translates to:
  /// **'Relatives'**
  String get relatives;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @stories.
  ///
  /// In en, this message translates to:
  /// **'Stories'**
  String get stories;

  /// No description provided for @sendLocation.
  ///
  /// In en, this message translates to:
  /// **'Send location'**
  String get sendLocation;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message'**
  String get typeMessage;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @locationSharing.
  ///
  /// In en, this message translates to:
  /// **'Location sharing'**
  String get locationSharing;

  /// No description provided for @locationSharingSub.
  ///
  /// In en, this message translates to:
  /// **'Share your live location with your circle'**
  String get locationSharingSub;

  /// No description provided for @ghostMode.
  ///
  /// In en, this message translates to:
  /// **'Ghost mode'**
  String get ghostMode;

  /// No description provided for @ghostModeSub.
  ///
  /// In en, this message translates to:
  /// **'Pause sharing without leaving the circle'**
  String get ghostModeSub;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @sos.
  ///
  /// In en, this message translates to:
  /// **'SOS'**
  String get sos;

  /// No description provided for @sosHold.
  ///
  /// In en, this message translates to:
  /// **'Hold for 3 seconds to alert'**
  String get sosHold;

  /// No description provided for @emergencyContacts.
  ///
  /// In en, this message translates to:
  /// **'Emergency contacts'**
  String get emergencyContacts;

  /// No description provided for @sharingActive.
  ///
  /// In en, this message translates to:
  /// **'Location sharing active'**
  String get sharingActive;

  /// No description provided for @sharingPaused.
  ///
  /// In en, this message translates to:
  /// **'Location sharing paused'**
  String get sharingPaused;

  /// No description provided for @relationFather.
  ///
  /// In en, this message translates to:
  /// **'Father'**
  String get relationFather;

  /// No description provided for @relationMother.
  ///
  /// In en, this message translates to:
  /// **'Mother'**
  String get relationMother;

  /// No description provided for @relationSon.
  ///
  /// In en, this message translates to:
  /// **'Son'**
  String get relationSon;

  /// No description provided for @relationDaughter.
  ///
  /// In en, this message translates to:
  /// **'Daughter'**
  String get relationDaughter;

  /// No description provided for @relationBrother.
  ///
  /// In en, this message translates to:
  /// **'Brother'**
  String get relationBrother;

  /// No description provided for @relationSister.
  ///
  /// In en, this message translates to:
  /// **'Sister'**
  String get relationSister;

  /// No description provided for @relationHusband.
  ///
  /// In en, this message translates to:
  /// **'Husband'**
  String get relationHusband;

  /// No description provided for @relationWife.
  ///
  /// In en, this message translates to:
  /// **'Wife'**
  String get relationWife;

  /// No description provided for @relationGrandfather.
  ///
  /// In en, this message translates to:
  /// **'Grandfather'**
  String get relationGrandfather;

  /// No description provided for @relationGrandmother.
  ///
  /// In en, this message translates to:
  /// **'Grandmother'**
  String get relationGrandmother;

  /// No description provided for @relationPaternalUncle.
  ///
  /// In en, this message translates to:
  /// **'Paternal uncle'**
  String get relationPaternalUncle;

  /// No description provided for @relationMaternalUncle.
  ///
  /// In en, this message translates to:
  /// **'Maternal uncle'**
  String get relationMaternalUncle;

  /// No description provided for @relationPaternalAunt.
  ///
  /// In en, this message translates to:
  /// **'Paternal aunt'**
  String get relationPaternalAunt;

  /// No description provided for @relationMaternalAunt.
  ///
  /// In en, this message translates to:
  /// **'Maternal aunt'**
  String get relationMaternalAunt;

  /// No description provided for @relationOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get relationOther;

  /// No description provided for @selectRelation.
  ///
  /// In en, this message translates to:
  /// **'Select relation'**
  String get selectRelation;

  /// No description provided for @inviteToCircle.
  ///
  /// In en, this message translates to:
  /// **'Invite to circle'**
  String get inviteToCircle;

  /// No description provided for @inviteToCircleSub.
  ///
  /// In en, this message translates to:
  /// **'Send a circle invite with this relative'**
  String get inviteToCircleSub;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @empty.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get empty;

  /// No description provided for @onboardingSkipConfirm.
  ///
  /// In en, this message translates to:
  /// **'You can set this up later in Settings'**
  String get onboardingSkipConfirm;

  /// No description provided for @skipDemo.
  ///
  /// In en, this message translates to:
  /// **'Skip for now (demo)'**
  String get skipDemo;

  /// No description provided for @locationOff.
  ///
  /// In en, this message translates to:
  /// **'Location off — tap to retry'**
  String get locationOff;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailHint;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordHint;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @authInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email and a password of at least 6 characters'**
  String get authInvalid;

  /// No description provided for @authFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not sign in. Check your connection.'**
  String get authFailed;

  /// No description provided for @switchToSignup.
  ///
  /// In en, this message translates to:
  /// **'New here? Create account'**
  String get switchToSignup;

  /// No description provided for @switchToLogin.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get switchToLogin;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @sosDemoNote.
  ///
  /// In en, this message translates to:
  /// **'Demo mode — no real alerts sent'**
  String get sosDemoNote;

  /// No description provided for @premiumTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock premium features for free'**
  String get premiumTitle;

  /// No description provided for @startFreeTrial.
  ///
  /// In en, this message translates to:
  /// **'Start free trial'**
  String get startFreeTrial;

  /// No description provided for @checkIn.
  ///
  /// In en, this message translates to:
  /// **'Check in'**
  String get checkIn;

  /// No description provided for @checkInSent.
  ///
  /// In en, this message translates to:
  /// **'Check-in sent to your family'**
  String get checkInSent;

  /// No description provided for @addPlace.
  ///
  /// In en, this message translates to:
  /// **'Add place'**
  String get addPlace;

  /// No description provided for @placeNameHint.
  ///
  /// In en, this message translates to:
  /// **'Place name'**
  String get placeNameHint;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @hereFor.
  ///
  /// In en, this message translates to:
  /// **'Here for'**
  String get hereFor;

  /// No description provided for @driving.
  ///
  /// In en, this message translates to:
  /// **'Driving'**
  String get driving;

  /// No description provided for @moving.
  ///
  /// In en, this message translates to:
  /// **'Moving'**
  String get moving;

  /// No description provided for @locationNotUpdating.
  ///
  /// In en, this message translates to:
  /// **'Location not updating'**
  String get locationNotUpdating;

  /// No description provided for @mapLayers.
  ///
  /// In en, this message translates to:
  /// **'Map layers'**
  String get mapLayers;

  /// No description provided for @lightMap.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightMap;

  /// No description provided for @standardMap.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get standardMap;

  /// No description provided for @satelliteMap.
  ///
  /// In en, this message translates to:
  /// **'Satellite'**
  String get satelliteMap;

  /// No description provided for @fitAllMembers.
  ///
  /// In en, this message translates to:
  /// **'Fit all family members'**
  String get fitAllMembers;

  /// No description provided for @shareInviteTipTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep everyone in the loop'**
  String get shareInviteTipTitle;

  /// No description provided for @shareInviteTipBody.
  ///
  /// In en, this message translates to:
  /// **'Share your invite code so family can join your circle.'**
  String get shareInviteTipBody;

  /// No description provided for @speedKmh.
  ///
  /// In en, this message translates to:
  /// **'{speed} km/h'**
  String speedKmh(int speed);

  /// No description provided for @durationDaysHours.
  ///
  /// In en, this message translates to:
  /// **'{days} d, {hours} hrs'**
  String durationDaysHours(int days, int hours);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours} hrs {minutes} min'**
  String durationHoursMinutes(int hours, int minutes);

  /// No description provided for @updatedAgo.
  ///
  /// In en, this message translates to:
  /// **'Updated {minutes} min ago'**
  String updatedAgo(int minutes);

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String durationMinutes(int minutes);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
