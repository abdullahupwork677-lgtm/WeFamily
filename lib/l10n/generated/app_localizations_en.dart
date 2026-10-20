// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'WeFamily';

  @override
  String get onboardingTitle1 => 'Stay close to the ones you love';

  @override
  String get onboardingBody1 =>
      'See where your family is, share your location, and check in — all in one private circle.';

  @override
  String get onboardingTitle2 => 'Your family tree, alive';

  @override
  String get onboardingBody2 =>
      'Build an interactive family tree and connect relatives across generations.';

  @override
  String get onboardingTitle3 => 'Safety first, always';

  @override
  String get onboardingBody3 =>
      'One-tap SOS and live location sharing keep everyone safe without feeling watched.';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get started';

  @override
  String get loginTitle => 'Welcome to WeFamily';

  @override
  String get loginSubtitle => 'Enter your phone number to continue';

  @override
  String get phoneHint => 'Phone number';

  @override
  String get continueBtn => 'Continue';

  @override
  String get otpTitle => 'Verify your number';

  @override
  String otpSubtitle(String phone) {
    return 'We sent a 6-digit code to $phone';
  }

  @override
  String get otpHint => 'Enter code';

  @override
  String get resendCode => 'Resend code';

  @override
  String resendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get profileSetupTitle => 'Tell us about you';

  @override
  String get nameHint => 'Full name';

  @override
  String get birthDateHint => 'Birth date';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get saveContinue => 'Save & continue';

  @override
  String get createCircleTitle => 'Create your family circle';

  @override
  String get createCircleSubtitle =>
      'A private space for your family to share and stay safe';

  @override
  String get circleNameHint => 'Circle name';

  @override
  String get createCircle => 'Create circle';

  @override
  String get joinCircleTitle => 'Join a circle';

  @override
  String get joinCircleSubtitle => 'Enter the invite code shared with you';

  @override
  String get inviteCodeHint => 'Invite code';

  @override
  String get joinCircle => 'Join circle';

  @override
  String get or => 'or';

  @override
  String get shareInvite => 'Share invite link';

  @override
  String get home => 'Home';

  @override
  String get location => 'Location';

  @override
  String get tree => 'Tree';

  @override
  String get safety => 'Safety';

  @override
  String get chat => 'Chat';

  @override
  String get profile => 'Profile';

  @override
  String get people => 'People';

  @override
  String get places => 'Places';

  @override
  String get pets => 'Pets';

  @override
  String get keys => 'Keys';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get addPerson => 'Add a person';

  @override
  String get premiumBanner => 'Go Premium';

  @override
  String get premiumBannerSub => 'Unlock unlimited members and history';

  @override
  String get memberDetail => 'Member details';

  @override
  String get call => 'Call';

  @override
  String get message => 'Message';

  @override
  String get directions => 'Directions';

  @override
  String get battery => 'Battery';

  @override
  String get lastUpdated => 'Last updated';

  @override
  String get addRelative => 'Add relative';

  @override
  String get searchTree => 'Search family';

  @override
  String get listView => 'List';

  @override
  String get treeView => 'Tree';

  @override
  String get about => 'About';

  @override
  String get relatives => 'Relatives';

  @override
  String get photos => 'Photos';

  @override
  String get stories => 'Stories';

  @override
  String get sendLocation => 'Send location';

  @override
  String get typeMessage => 'Type a message';

  @override
  String get send => 'Send';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get locationSharing => 'Location sharing';

  @override
  String get locationSharingSub => 'Share your live location with your circle';

  @override
  String get ghostMode => 'Ghost mode';

  @override
  String get ghostModeSub => 'Pause sharing without leaving the circle';

  @override
  String get logout => 'Log out';

  @override
  String get notifications => 'Notifications';

  @override
  String get sos => 'SOS';

  @override
  String get sosHold => 'Hold for 3 seconds to alert';

  @override
  String get emergencyContacts => 'Emergency contacts';

  @override
  String get sharingActive => 'Location sharing active';

  @override
  String get sharingPaused => 'Location sharing paused';

  @override
  String get relationFather => 'Father';

  @override
  String get relationMother => 'Mother';

  @override
  String get relationSon => 'Son';

  @override
  String get relationDaughter => 'Daughter';

  @override
  String get relationBrother => 'Brother';

  @override
  String get relationSister => 'Sister';

  @override
  String get relationHusband => 'Husband';

  @override
  String get relationWife => 'Wife';

  @override
  String get relationGrandfather => 'Grandfather';

  @override
  String get relationGrandmother => 'Grandmother';

  @override
  String get relationPaternalUncle => 'Paternal uncle';

  @override
  String get relationMaternalUncle => 'Maternal uncle';

  @override
  String get relationPaternalAunt => 'Paternal aunt';

  @override
  String get relationMaternalAunt => 'Maternal aunt';

  @override
  String get relationOther => 'Other';

  @override
  String get selectRelation => 'Select relation';

  @override
  String get inviteToCircle => 'Invite to circle';

  @override
  String get inviteToCircleSub => 'Send a circle invite with this relative';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Something went wrong';

  @override
  String get retry => 'Retry';

  @override
  String get empty => 'Nothing here yet';

  @override
  String get onboardingSkipConfirm => 'You can set this up later in Settings';

  @override
  String get skipDemo => 'Skip for now (demo)';

  @override
  String get locationOff => 'Location off — tap to retry';

  @override
  String get emailHint => 'Email';

  @override
  String get passwordHint => 'Password';

  @override
  String get signIn => 'Sign in';

  @override
  String get createAccount => 'Create account';

  @override
  String get authInvalid =>
      'Enter a valid email and a password of at least 6 characters';

  @override
  String get authFailed => 'Could not sign in. Check your connection.';

  @override
  String get switchToSignup => 'New here? Create account';

  @override
  String get switchToLogin => 'Already have an account? Sign in';

  @override
  String get reset => 'Reset';

  @override
  String get sosDemoNote => 'Demo mode — no real alerts sent';
}
