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

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Your family, safely connected'**
  String get splashTagline;

  /// No description provided for @onboardingBadge1.
  ///
  /// In en, this message translates to:
  /// **'Live Guardian Mesh'**
  String get onboardingBadge1;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Keep your family close'**
  String get onboardingTitle1;

  /// No description provided for @onboardingBody1.
  ///
  /// In en, this message translates to:
  /// **'Real-time updates, intelligent geofences, and peace of mind at your fingertips — wherever your loved ones are.'**
  String get onboardingBody1;

  /// No description provided for @onboardingTrust1.
  ///
  /// In en, this message translates to:
  /// **'End-to-end encrypted family circles'**
  String get onboardingTrust1;

  /// No description provided for @onboardingBadge2.
  ///
  /// In en, this message translates to:
  /// **'Private Family Mesh'**
  String get onboardingBadge2;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Know where everyone is, safely'**
  String get onboardingTitle2;

  /// No description provided for @onboardingBody2.
  ///
  /// In en, this message translates to:
  /// **'Bank-grade privacy, instant crash detection, and smart geofence alerts that notify you only when it matters.'**
  String get onboardingBody2;

  /// No description provided for @onboardingTrust2.
  ///
  /// In en, this message translates to:
  /// **'24/7 Guardian protection & zero data selling'**
  String get onboardingTrust2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Build your family tree together'**
  String get onboardingTitle3;

  /// No description provided for @onboardingBody3.
  ///
  /// In en, this message translates to:
  /// **'Preserve oral histories, celebrate milestones, and map your shared heritage across every generation.'**
  String get onboardingBody3;

  /// No description provided for @onboardingHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get onboardingHaveAccount;

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
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @illMomInTransit.
  ///
  /// In en, this message translates to:
  /// **'Mom • In Transit'**
  String get illMomInTransit;

  /// No description provided for @illLeoAtSchool.
  ///
  /// In en, this message translates to:
  /// **'Leo • At School'**
  String get illLeoAtSchool;

  /// No description provided for @illHomeZoneSafe.
  ///
  /// In en, this message translates to:
  /// **'Home Zone Safe'**
  String get illHomeZoneSafe;

  /// No description provided for @illLiveGuardian.
  ///
  /// In en, this message translates to:
  /// **'Live Guardian'**
  String get illLiveGuardian;

  /// No description provided for @illHomeZone.
  ///
  /// In en, this message translates to:
  /// **'Home Zone'**
  String get illHomeZone;

  /// No description provided for @illSafeActive.
  ///
  /// In en, this message translates to:
  /// **'Safe & Active'**
  String get illSafeActive;

  /// No description provided for @illSchoolZone.
  ///
  /// In en, this message translates to:
  /// **'School Zone'**
  String get illSchoolZone;

  /// No description provided for @illArrived.
  ///
  /// In en, this message translates to:
  /// **'Arrived 8:30 AM'**
  String get illArrived;

  /// No description provided for @illCrashReady.
  ///
  /// In en, this message translates to:
  /// **'Crash Ready'**
  String get illCrashReady;

  /// No description provided for @illBankLevelSafe.
  ///
  /// In en, this message translates to:
  /// **'Bank-Level Safe'**
  String get illBankLevelSafe;

  /// No description provided for @illNanaRose.
  ///
  /// In en, this message translates to:
  /// **'Nana Rose'**
  String get illNanaRose;

  /// No description provided for @illElenaMom.
  ///
  /// In en, this message translates to:
  /// **'Elena (Mom)'**
  String get illElenaMom;

  /// No description provided for @illMarcus.
  ///
  /// In en, this message translates to:
  /// **'Marcus'**
  String get illMarcus;

  /// No description provided for @illMayaAge.
  ///
  /// In en, this message translates to:
  /// **'Maya, 7'**
  String get illMayaAge;

  /// No description provided for @illAnniversary.
  ///
  /// In en, this message translates to:
  /// **'50th Anniv.'**
  String get illAnniversary;

  /// No description provided for @illTales.
  ///
  /// In en, this message translates to:
  /// **'4 tales'**
  String get illTales;

  /// No description provided for @illLiveMemory.
  ///
  /// In en, this message translates to:
  /// **'Live Memory Added'**
  String get illLiveMemory;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to sign in or create your family circle account.'**
  String get loginSubtitle;

  /// No description provided for @encryptedCircle.
  ///
  /// In en, this message translates to:
  /// **'End-to-end encrypted circle'**
  String get encryptedCircle;

  /// No description provided for @bankGradePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Bank-Grade Privacy'**
  String get bankGradePrivacy;

  /// No description provided for @bankGradePrivacyBody.
  ///
  /// In en, this message translates to:
  /// **'Your family\'s live GPS, chat archives, and photos are encrypted strictly between invited circle members.'**
  String get bankGradePrivacyBody;

  /// No description provided for @familiesConnected.
  ///
  /// In en, this message translates to:
  /// **'Over 240,000 families safely connected'**
  String get familiesConnected;

  /// No description provided for @termsIntro.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to {appName}\'s Terms of Service and Privacy Policy. We protect your family data with bank-level encryption.'**
  String termsIntro(String appName);

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

  /// No description provided for @myCircles.
  ///
  /// In en, this message translates to:
  /// **'Your circles'**
  String get myCircles;

  /// No description provided for @joinAnotherCircle.
  ///
  /// In en, this message translates to:
  /// **'Join or create another circle'**
  String get joinAnotherCircle;

  /// No description provided for @circleAddSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can be part of more than one family circle. Create a new one or join with an invite code.'**
  String get circleAddSubtitle;

  /// No description provided for @activeCircle.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeCircle;

  /// No description provided for @switchedCircle.
  ///
  /// In en, this message translates to:
  /// **'Switched to {name}'**
  String switchedCircle(String name);

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

  /// No description provided for @aboutHint.
  ///
  /// In en, this message translates to:
  /// **'A few words about this person'**
  String get aboutHint;

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

  /// No description provided for @relationSelf.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get relationSelf;

  /// No description provided for @relationChild.
  ///
  /// In en, this message translates to:
  /// **'Child'**
  String get relationChild;

  /// No description provided for @relationParent.
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get relationParent;

  /// No description provided for @relationSibling.
  ///
  /// In en, this message translates to:
  /// **'Sibling'**
  String get relationSibling;

  /// No description provided for @relationNephew.
  ///
  /// In en, this message translates to:
  /// **'Nephew'**
  String get relationNephew;

  /// No description provided for @relationNiece.
  ///
  /// In en, this message translates to:
  /// **'Niece'**
  String get relationNiece;

  /// No description provided for @relationGrandson.
  ///
  /// In en, this message translates to:
  /// **'Grandson'**
  String get relationGrandson;

  /// No description provided for @relationGranddaughter.
  ///
  /// In en, this message translates to:
  /// **'Granddaughter'**
  String get relationGranddaughter;

  /// No description provided for @relationRelative.
  ///
  /// In en, this message translates to:
  /// **'Relative'**
  String get relationRelative;

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

  /// No description provided for @treeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your family tree is waiting'**
  String get treeEmpty;

  /// No description provided for @treeEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add your first relative to start building the tree.'**
  String get treeEmptyBody;

  /// No description provided for @addFirstRelative.
  ///
  /// In en, this message translates to:
  /// **'Add first relative'**
  String get addFirstRelative;

  /// No description provided for @addRelativeOf.
  ///
  /// In en, this message translates to:
  /// **'Add relative of {name}'**
  String addRelativeOf(String name);

  /// No description provided for @editPerson.
  ///
  /// In en, this message translates to:
  /// **'Edit person'**
  String get editPerson;

  /// No description provided for @deletePerson.
  ///
  /// In en, this message translates to:
  /// **'Delete person'**
  String get deletePerson;

  /// No description provided for @deletePersonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from the family tree?'**
  String deletePersonConfirm(String name);

  /// No description provided for @deletePersonBody.
  ///
  /// In en, this message translates to:
  /// **'This only removes the tree entry, not the circle member.'**
  String get deletePersonBody;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @birthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get birthday;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @genderOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get genderOther;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @photoUrl.
  ///
  /// In en, this message translates to:
  /// **'Photo URL'**
  String get photoUrl;

  /// No description provided for @photoUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://example.com/photo.jpg'**
  String get photoUrlHint;

  /// No description provided for @noPhotos.
  ///
  /// In en, this message translates to:
  /// **'No photo yet'**
  String get noPhotos;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get addPhoto;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhoto;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhoto;

  /// No description provided for @linkedMember.
  ///
  /// In en, this message translates to:
  /// **'In your circle'**
  String get linkedMember;

  /// No description provided for @linkMember.
  ///
  /// In en, this message translates to:
  /// **'Link to a circle member'**
  String get linkMember;

  /// No description provided for @linkMemberHint.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get linkMemberHint;

  /// No description provided for @notLinked.
  ///
  /// In en, this message translates to:
  /// **'Not in your circle'**
  String get notLinked;

  /// No description provided for @noRelativesYet.
  ///
  /// In en, this message translates to:
  /// **'No relatives added yet'**
  String get noRelativesYet;

  /// No description provided for @parents.
  ///
  /// In en, this message translates to:
  /// **'Parents'**
  String get parents;

  /// No description provided for @grandparents.
  ///
  /// In en, this message translates to:
  /// **'Grandparents'**
  String get grandparents;

  /// No description provided for @children.
  ///
  /// In en, this message translates to:
  /// **'Children'**
  String get children;

  /// No description provided for @siblings.
  ///
  /// In en, this message translates to:
  /// **'Siblings'**
  String get siblings;

  /// No description provided for @spouse.
  ///
  /// In en, this message translates to:
  /// **'Spouse'**
  String get spouse;

  /// No description provided for @otherRelatives.
  ///
  /// In en, this message translates to:
  /// **'Other relatives'**
  String get otherRelatives;

  /// No description provided for @bornYear.
  ///
  /// In en, this message translates to:
  /// **'Born {year}'**
  String bornYear(String year);

  /// No description provided for @ageYears.
  ///
  /// In en, this message translates to:
  /// **'{age} years'**
  String ageYears(String age);

  /// No description provided for @personAdded.
  ///
  /// In en, this message translates to:
  /// **'{name} added to your family tree'**
  String personAdded(String name);

  /// No description provided for @personUpdated.
  ///
  /// In en, this message translates to:
  /// **'Family tree updated'**
  String get personUpdated;

  /// No description provided for @personRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed from family tree'**
  String get personRemoved;

  /// No description provided for @treeSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Please try again.'**
  String get treeSaveError;

  /// No description provided for @treeDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete. Please try again.'**
  String get treeDeleteError;

  /// No description provided for @relationRequired.
  ///
  /// In en, this message translates to:
  /// **'Select a relation'**
  String get relationRequired;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get nameRequired;

  /// No description provided for @memberAlreadyLinked.
  ///
  /// In en, this message translates to:
  /// **'That circle member is already in the tree'**
  String get memberAlreadyLinked;

  /// No description provided for @inviteCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Invite code copied'**
  String get inviteCodeCopied;

  /// No description provided for @treeHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a person to open their profile'**
  String get treeHint;

  /// No description provided for @treeHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Our family story'**
  String get treeHeroTitle;

  /// No description provided for @treeHeroBody.
  ///
  /// In en, this message translates to:
  /// **'Every name has a story. Keep your family legacy alive.'**
  String get treeHeroBody;

  /// No description provided for @treePeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get treePeople;

  /// No description provided for @treeGenerations.
  ///
  /// In en, this message translates to:
  /// **'Generations'**
  String get treeGenerations;

  /// No description provided for @treeInCircle.
  ///
  /// In en, this message translates to:
  /// **'In circle'**
  String get treeInCircle;

  /// No description provided for @generationLabel.
  ///
  /// In en, this message translates to:
  /// **'Generation {n}'**
  String generationLabel(String n);

  /// No description provided for @treeSearchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No family member found'**
  String get treeSearchEmpty;

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

  /// No description provided for @walking.
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get walking;

  /// No description provided for @cycling.
  ///
  /// In en, this message translates to:
  /// **'Cycling'**
  String get cycling;

  /// No description provided for @atRest.
  ///
  /// In en, this message translates to:
  /// **'At rest'**
  String get atRest;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @etaLabel.
  ///
  /// In en, this message translates to:
  /// **'ETA'**
  String get etaLabel;

  /// No description provided for @noLocationYet.
  ///
  /// In en, this message translates to:
  /// **'No location yet'**
  String get noLocationYet;

  /// No description provided for @kmValue.
  ///
  /// In en, this message translates to:
  /// **'{value} km'**
  String kmValue(String value);

  /// No description provided for @mValue.
  ///
  /// In en, this message translates to:
  /// **'{value} m'**
  String mValue(String value);

  /// No description provided for @minValue.
  ///
  /// In en, this message translates to:
  /// **'{value} min'**
  String minValue(String value);

  /// No description provided for @hrMinValue.
  ///
  /// In en, this message translates to:
  /// **'{hours} hr {minutes} min'**
  String hrMinValue(String hours, String minutes);

  /// No description provided for @awayFromYou.
  ///
  /// In en, this message translates to:
  /// **'{distance} from you'**
  String awayFromYou(String distance);

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

  /// No description provided for @locationPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Share your location with your family'**
  String get locationPromptTitle;

  /// No description provided for @locationPromptBody.
  ///
  /// In en, this message translates to:
  /// **'Your circle sees your live location on the map plus your battery level. Only members of your circle can see it.'**
  String get locationPromptBody;

  /// No description provided for @locationPromptPrivacy.
  ///
  /// In en, this message translates to:
  /// **'You can pause sharing anytime with Ghost mode.'**
  String get locationPromptPrivacy;

  /// No description provided for @shareWhileUsing.
  ///
  /// In en, this message translates to:
  /// **'Allow while using the app'**
  String get shareWhileUsing;

  /// No description provided for @shareAlways.
  ///
  /// In en, this message translates to:
  /// **'Allow all the time'**
  String get shareAlways;

  /// No description provided for @allowBackgroundTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep sharing in the background'**
  String get allowBackgroundTitle;

  /// No description provided for @allowBackgroundBody.
  ///
  /// In en, this message translates to:
  /// **'So the map stays live when the app is closed, allow location access all the time. On Android you may need to choose it in settings.'**
  String get allowBackgroundBody;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @locationDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Location permission needed'**
  String get locationDeniedTitle;

  /// No description provided for @locationDeniedBody.
  ///
  /// In en, this message translates to:
  /// **'Location access is off. Enable it in system settings so your family can see where you are.'**
  String get locationDeniedBody;

  /// No description provided for @backgroundTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Improve background reliability'**
  String get backgroundTipsTitle;

  /// No description provided for @backgroundTipsBody.
  ///
  /// In en, this message translates to:
  /// **'Some phones (Xiaomi, Oppo, Vivo, Samsung) stop apps in the background. Allow WeFamily to run without battery restrictions.'**
  String get backgroundTipsBody;

  /// No description provided for @disableOptimization.
  ///
  /// In en, this message translates to:
  /// **'Disable battery optimization'**
  String get disableOptimization;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @myCircle.
  ///
  /// In en, this message translates to:
  /// **'My circle'**
  String get myCircle;

  /// No description provided for @sharingNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'WeFamily is sharing your location'**
  String get sharingNotificationTitle;

  /// No description provided for @sharingNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Your family can see your live location.'**
  String get sharingNotificationBody;

  /// No description provided for @enterCircleName.
  ///
  /// In en, this message translates to:
  /// **'Enter a circle name'**
  String get enterCircleName;

  /// No description provided for @invalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid invite code. Check the code and try again.'**
  String get invalidCode;

  /// No description provided for @alreadyMember.
  ///
  /// In en, this message translates to:
  /// **'You\'re already a member of this circle.'**
  String get alreadyMember;

  /// No description provided for @circleFull.
  ///
  /// In en, this message translates to:
  /// **'This circle is full (10 members max).'**
  String get circleFull;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Try again.'**
  String get noInternet;

  /// No description provided for @joinFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not join the circle. Try again.'**
  String get joinFailed;

  /// No description provided for @manageCircle.
  ///
  /// In en, this message translates to:
  /// **'Manage circle'**
  String get manageCircle;

  /// No description provided for @inviteCode.
  ///
  /// In en, this message translates to:
  /// **'Invite code'**
  String get inviteCode;

  /// No description provided for @copyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get copyCode;

  /// No description provided for @codeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied'**
  String get codeCopied;

  /// No description provided for @regenerateCode.
  ///
  /// In en, this message translates to:
  /// **'Regenerate code'**
  String get regenerateCode;

  /// No description provided for @regenerateConfirm.
  ///
  /// In en, this message translates to:
  /// **'The old code stops working immediately. Continue?'**
  String get regenerateConfirm;

  /// No description provided for @regenerateSuccess.
  ///
  /// In en, this message translates to:
  /// **'New invite code generated'**
  String get regenerateSuccess;

  /// No description provided for @removeMember.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeMember;

  /// No description provided for @removeMemberConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from the circle?'**
  String removeMemberConfirm(String name);

  /// No description provided for @leaveCircle.
  ///
  /// In en, this message translates to:
  /// **'Leave circle'**
  String get leaveCircle;

  /// No description provided for @leaveCircleConfirm.
  ///
  /// In en, this message translates to:
  /// **'You\'ll stop sharing your location with this circle.'**
  String get leaveCircleConfirm;

  /// No description provided for @deleteCircle.
  ///
  /// In en, this message translates to:
  /// **'Delete circle'**
  String get deleteCircle;

  /// No description provided for @deleteCircleConfirm.
  ///
  /// In en, this message translates to:
  /// **'This deletes the circle for everyone. This cannot be undone.'**
  String get deleteCircleConfirm;

  /// No description provided for @circleDeleted.
  ///
  /// In en, this message translates to:
  /// **'Circle deleted'**
  String get circleDeleted;

  /// No description provided for @leftCircle.
  ///
  /// In en, this message translates to:
  /// **'You left the circle'**
  String get leftCircle;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsapp;

  /// No description provided for @circleMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get circleMembers;

  /// No description provided for @owner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get owner;

  /// No description provided for @shareInviteMessage.
  ///
  /// In en, this message translates to:
  /// **'Join my family on WeFamily! Code: {code} | {link}'**
  String shareInviteMessage(String code, String link);

  /// No description provided for @chatEmpty.
  ///
  /// In en, this message translates to:
  /// **'No messages yet. Say hello!'**
  String get chatEmpty;

  /// No description provided for @attach.
  ///
  /// In en, this message translates to:
  /// **'Attach'**
  String get attach;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photo;

  /// No description provided for @voiceNote.
  ///
  /// In en, this message translates to:
  /// **'Voice message'**
  String get voiceNote;

  /// No description provided for @holdToRecord.
  ///
  /// In en, this message translates to:
  /// **'Hold to record, slide to cancel'**
  String get holdToRecord;

  /// No description provided for @slideToCancel.
  ///
  /// In en, this message translates to:
  /// **'Slide to cancel'**
  String get slideToCancel;

  /// No description provided for @releaseToSend.
  ///
  /// In en, this message translates to:
  /// **'Release to send'**
  String get releaseToSend;

  /// No description provided for @releaseToCancel.
  ///
  /// In en, this message translates to:
  /// **'Release to cancel'**
  String get releaseToCancel;

  /// No description provided for @tapToStop.
  ///
  /// In en, this message translates to:
  /// **'Tap the mic to stop'**
  String get tapToStop;

  /// No description provided for @micDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Microphone access needed'**
  String get micDeniedTitle;

  /// No description provided for @micDeniedBody.
  ///
  /// In en, this message translates to:
  /// **'Allow microphone access so you can send voice notes to your family.'**
  String get micDeniedBody;

  /// No description provided for @quickOnMyWay.
  ///
  /// In en, this message translates to:
  /// **'I\'m on my way'**
  String get quickOnMyWay;

  /// No description provided for @quickReached.
  ///
  /// In en, this message translates to:
  /// **'I\'ve reached'**
  String get quickReached;

  /// No description provided for @quickCallMe.
  ///
  /// In en, this message translates to:
  /// **'Call me'**
  String get quickCallMe;

  /// No description provided for @openOnMap.
  ///
  /// In en, this message translates to:
  /// **'Open on map'**
  String get openOnMap;

  /// No description provided for @recording.
  ///
  /// In en, this message translates to:
  /// **'Recording'**
  String get recording;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @presenceMode.
  ///
  /// In en, this message translates to:
  /// **'Your mode'**
  String get presenceMode;

  /// No description provided for @setMode.
  ///
  /// In en, this message translates to:
  /// **'Set your mode'**
  String get setMode;

  /// No description provided for @modeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This shows next to your avatar on the family map.'**
  String get modeSubtitle;

  /// No description provided for @modeAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get modeAuto;

  /// No description provided for @modeDriving.
  ///
  /// In en, this message translates to:
  /// **'Driving'**
  String get modeDriving;

  /// No description provided for @modeHome.
  ///
  /// In en, this message translates to:
  /// **'At home'**
  String get modeHome;

  /// No description provided for @modeWork.
  ///
  /// In en, this message translates to:
  /// **'At work'**
  String get modeWork;

  /// No description provided for @modeOutside.
  ///
  /// In en, this message translates to:
  /// **'Outside'**
  String get modeOutside;

  /// No description provided for @modeEvent.
  ///
  /// In en, this message translates to:
  /// **'At an event'**
  String get modeEvent;

  /// No description provided for @modeUpdated.
  ///
  /// In en, this message translates to:
  /// **'Mode updated'**
  String get modeUpdated;

  /// No description provided for @modeCleared.
  ///
  /// In en, this message translates to:
  /// **'Mode set to automatic'**
  String get modeCleared;

  /// No description provided for @modeSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not update mode'**
  String get modeSaveError;

  /// No description provided for @membersOnline.
  ///
  /// In en, this message translates to:
  /// **'{members} members · {online} online'**
  String membersOnline(int members, int online);

  /// No description provided for @membersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} members'**
  String membersCount(int count);

  /// No description provided for @mapRealistic.
  ///
  /// In en, this message translates to:
  /// **'Realistic'**
  String get mapRealistic;

  /// No description provided for @onlineNow.
  ///
  /// In en, this message translates to:
  /// **'online'**
  String get onlineNow;

  /// No description provided for @sosAlertTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} needs help'**
  String sosAlertTitle(String name);

  /// No description provided for @sosAlertBody.
  ///
  /// In en, this message translates to:
  /// **'SOS was pressed. Their live location is marked in red on the map.'**
  String get sosAlertBody;

  /// No description provided for @sosActiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Your SOS is active'**
  String get sosActiveTitle;

  /// No description provided for @sosActiveBody.
  ///
  /// In en, this message translates to:
  /// **'Your circle has been notified with your exact location.'**
  String get sosActiveBody;

  /// No description provided for @sosSent.
  ///
  /// In en, this message translates to:
  /// **'SOS sent to your circle'**
  String get sosSent;

  /// No description provided for @sosCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel SOS'**
  String get sosCancel;

  /// No description provided for @sosCancelled.
  ///
  /// In en, this message translates to:
  /// **'SOS cancelled'**
  String get sosCancelled;

  /// No description provided for @sosUnable.
  ///
  /// In en, this message translates to:
  /// **'Could not send SOS. Check your connection.'**
  String get sosUnable;

  /// No description provided for @sosNoLocation.
  ///
  /// In en, this message translates to:
  /// **'Location unavailable. Turn on GPS and try again.'**
  String get sosNoLocation;

  /// No description provided for @sosShowOnMap.
  ///
  /// In en, this message translates to:
  /// **'Show on map'**
  String get sosShowOnMap;

  /// No description provided for @sosNotified.
  ///
  /// In en, this message translates to:
  /// **'Your circle will be notified instantly'**
  String get sosNotified;

  /// No description provided for @sosSentAt.
  ///
  /// In en, this message translates to:
  /// **'Sent {time}'**
  String sosSentAt(String time);

  /// No description provided for @sosResolveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Cancel the SOS alert for everyone?'**
  String get sosResolveConfirm;

  /// No description provided for @sosRecent.
  ///
  /// In en, this message translates to:
  /// **'Emergency alerts'**
  String get sosRecent;

  /// No description provided for @noAlerts.
  ///
  /// In en, this message translates to:
  /// **'No emergency alerts right now'**
  String get noAlerts;

  /// No description provided for @sosWaiting.
  ///
  /// In en, this message translates to:
  /// **'Getting your exact location…'**
  String get sosWaiting;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @chatWithCircle.
  ///
  /// In en, this message translates to:
  /// **'Chat with your circle'**
  String get chatWithCircle;

  /// No description provided for @startConversation.
  ///
  /// In en, this message translates to:
  /// **'Start the conversation — your family will see it instantly.'**
  String get startConversation;

  /// No description provided for @sayHello.
  ///
  /// In en, this message translates to:
  /// **'Say hello'**
  String get sayHello;

  /// No description provided for @familyOrbitTitle.
  ///
  /// In en, this message translates to:
  /// **'Family Orbit'**
  String get familyOrbitTitle;

  /// No description provided for @familyMapTitle.
  ///
  /// In en, this message translates to:
  /// **'Family Map'**
  String get familyMapTitle;

  /// No description provided for @familyMapMembersHint.
  ///
  /// In en, this message translates to:
  /// **'{count} members · tap a pin to change origin'**
  String familyMapMembersHint(int count);

  /// No description provided for @familyMapLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get familyMapLive;

  /// No description provided for @familyMapLegend.
  ///
  /// In en, this message translates to:
  /// **'Shortest road route'**
  String get familyMapLegend;

  /// No description provided for @familyMapFrom.
  ///
  /// In en, this message translates to:
  /// **'Distances from'**
  String get familyMapFrom;

  /// No description provided for @familyMapNearest.
  ///
  /// In en, this message translates to:
  /// **'NEAREST'**
  String get familyMapNearest;

  /// No description provided for @familyMapFarthest.
  ///
  /// In en, this message translates to:
  /// **'FARTHEST'**
  String get familyMapFarthest;

  /// No description provided for @familyMapMinDrive.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min drive'**
  String familyMapMinDrive(int minutes);

  /// No description provided for @familyMapNow.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get familyMapNow;

  /// No description provided for @familyMapMinAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min ago'**
  String familyMapMinAgo(int minutes);

  /// No description provided for @familyMapHourAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours} hr ago'**
  String familyMapHourAgo(int hours);

  /// No description provided for @familyMapDayAgo.
  ///
  /// In en, this message translates to:
  /// **'{days} d ago'**
  String familyMapDayAgo(int days);

  /// No description provided for @membersRecenter.
  ///
  /// In en, this message translates to:
  /// **'{count} members · tap anyone to re-center'**
  String membersRecenter(int count);

  /// No description provided for @backToMe.
  ///
  /// In en, this message translates to:
  /// **'Back to me'**
  String get backToMe;

  /// No description provided for @relationPartner.
  ///
  /// In en, this message translates to:
  /// **'Partner'**
  String get relationPartner;

  /// No description provided for @relationGrandparent.
  ///
  /// In en, this message translates to:
  /// **'Grandparent'**
  String get relationGrandparent;

  /// No description provided for @relationGrandchild.
  ///
  /// In en, this message translates to:
  /// **'Grandchild'**
  String get relationGrandchild;

  /// No description provided for @yourRelation.
  ///
  /// In en, this message translates to:
  /// **'Your {relation}'**
  String yourRelation(String relation);

  /// No description provided for @addParent.
  ///
  /// In en, this message translates to:
  /// **'+ Parent'**
  String get addParent;

  /// No description provided for @addSibling.
  ///
  /// In en, this message translates to:
  /// **'+ Sibling'**
  String get addSibling;

  /// No description provided for @addPartner.
  ///
  /// In en, this message translates to:
  /// **'+ Partner'**
  String get addPartner;

  /// No description provided for @addChild.
  ///
  /// In en, this message translates to:
  /// **'+ Child'**
  String get addChild;

  /// No description provided for @memberAdded.
  ///
  /// In en, this message translates to:
  /// **'Member added'**
  String get memberAdded;

  /// No description provided for @alreadyTwoParents.
  ///
  /// In en, this message translates to:
  /// **'Already has two parents'**
  String get alreadyTwoParents;

  /// No description provided for @partnerAlready.
  ///
  /// In en, this message translates to:
  /// **'Partner already added'**
  String get partnerAlready;

  /// No description provided for @treeSiblingNeedsParent.
  ///
  /// In en, this message translates to:
  /// **'Add a parent first so this sibling can be linked'**
  String get treeSiblingNeedsParent;
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
