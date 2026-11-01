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
  String get splashTagline => 'Your family, safely connected';

  @override
  String get onboardingBadge1 => 'Live Guardian Mesh';

  @override
  String get onboardingTitle1 => 'Keep your family close';

  @override
  String get onboardingBody1 =>
      'Real-time updates, intelligent geofences, and peace of mind at your fingertips — wherever your loved ones are.';

  @override
  String get onboardingTrust1 => 'End-to-end encrypted family circles';

  @override
  String get onboardingBadge2 => 'Private Family Mesh';

  @override
  String get onboardingTitle2 => 'Know where everyone is, safely';

  @override
  String get onboardingBody2 =>
      'Bank-grade privacy, instant crash detection, and smart geofence alerts that notify you only when it matters.';

  @override
  String get onboardingTrust2 => '24/7 Guardian protection & zero data selling';

  @override
  String get onboardingTitle3 => 'Build your family tree together';

  @override
  String get onboardingBody3 =>
      'Preserve oral histories, celebrate milestones, and map your shared heritage across every generation.';

  @override
  String get onboardingHaveAccount => 'Already have an account?';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get Started';

  @override
  String get illMomInTransit => 'Mom • In Transit';

  @override
  String get illLeoAtSchool => 'Leo • At School';

  @override
  String get illHomeZoneSafe => 'Home Zone Safe';

  @override
  String get illLiveGuardian => 'Live Guardian';

  @override
  String get illHomeZone => 'Home Zone';

  @override
  String get illSafeActive => 'Safe & Active';

  @override
  String get illSchoolZone => 'School Zone';

  @override
  String get illArrived => 'Arrived 8:30 AM';

  @override
  String get illCrashReady => 'Crash Ready';

  @override
  String get illBankLevelSafe => 'Bank-Level Safe';

  @override
  String get illNanaRose => 'Nana Rose';

  @override
  String get illElenaMom => 'Elena (Mom)';

  @override
  String get illMarcus => 'Marcus';

  @override
  String get illMayaAge => 'Maya, 7';

  @override
  String get illAnniversary => '50th Anniv.';

  @override
  String get illTales => '4 tales';

  @override
  String get illLiveMemory => 'Live Memory Added';

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginSubtitle =>
      'Enter your email to sign in or create your family circle account.';

  @override
  String get encryptedCircle => 'End-to-end encrypted circle';

  @override
  String get bankGradePrivacy => 'Bank-Grade Privacy';

  @override
  String get bankGradePrivacyBody =>
      'Your family\'s live GPS, chat archives, and photos are encrypted strictly between invited circle members.';

  @override
  String get familiesConnected => 'Over 240,000 families safely connected';

  @override
  String termsIntro(String appName) {
    return 'By continuing, you agree to $appName\'s Terms of Service and Privacy Policy. We protect your family data with bank-level encryption.';
  }

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
  String get myCircles => 'Your circles';

  @override
  String get joinAnotherCircle => 'Join or create another circle';

  @override
  String get circleAddSubtitle =>
      'You can be part of more than one family circle. Create a new one or join with an invite code.';

  @override
  String get activeCircle => 'Active';

  @override
  String switchedCircle(String name) {
    return 'Switched to $name';
  }

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
  String get aboutHint => 'A few words about this person';

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
  String get relationSelf => 'You';

  @override
  String get relationChild => 'Child';

  @override
  String get relationParent => 'Parent';

  @override
  String get relationSibling => 'Sibling';

  @override
  String get relationNephew => 'Nephew';

  @override
  String get relationNiece => 'Niece';

  @override
  String get relationGrandson => 'Grandson';

  @override
  String get relationGranddaughter => 'Granddaughter';

  @override
  String get relationRelative => 'Relative';

  @override
  String get selectRelation => 'Select relation';

  @override
  String get inviteToCircle => 'Invite to circle';

  @override
  String get inviteToCircleSub => 'Send a circle invite with this relative';

  @override
  String get treeEmpty => 'Your family tree is waiting';

  @override
  String get treeEmptyBody =>
      'Add your first relative to start building the tree.';

  @override
  String get addFirstRelative => 'Add first relative';

  @override
  String addRelativeOf(String name) {
    return 'Add relative of $name';
  }

  @override
  String get editPerson => 'Edit person';

  @override
  String get deletePerson => 'Delete person';

  @override
  String deletePersonConfirm(String name) {
    return 'Remove $name from the family tree?';
  }

  @override
  String get deletePersonBody =>
      'This only removes the tree entry, not the circle member.';

  @override
  String get delete => 'Delete';

  @override
  String get birthday => 'Birthday';

  @override
  String get selectDate => 'Select date';

  @override
  String get gender => 'Gender';

  @override
  String get genderOther => 'Other';

  @override
  String get optional => 'Optional';

  @override
  String get photoUrl => 'Photo URL';

  @override
  String get photoUrlHint => 'https://example.com/photo.jpg';

  @override
  String get noPhotos => 'No photo yet';

  @override
  String get addPhoto => 'Add photo';

  @override
  String get changePhoto => 'Change photo';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get linkedMember => 'In your circle';

  @override
  String get linkMember => 'Link to a circle member';

  @override
  String get linkMemberHint => 'Optional';

  @override
  String get notLinked => 'Not in your circle';

  @override
  String get noRelativesYet => 'No relatives added yet';

  @override
  String get parents => 'Parents';

  @override
  String get grandparents => 'Grandparents';

  @override
  String get children => 'Children';

  @override
  String get siblings => 'Siblings';

  @override
  String get spouse => 'Spouse';

  @override
  String get otherRelatives => 'Other relatives';

  @override
  String bornYear(String year) {
    return 'Born $year';
  }

  @override
  String ageYears(String age) {
    return '$age years';
  }

  @override
  String personAdded(String name) {
    return '$name added to your family tree';
  }

  @override
  String get personUpdated => 'Family tree updated';

  @override
  String get personRemoved => 'Removed from family tree';

  @override
  String get treeSaveError => 'Could not save. Please try again.';

  @override
  String get treeDeleteError => 'Could not delete. Please try again.';

  @override
  String get relationRequired => 'Select a relation';

  @override
  String get nameRequired => 'Enter a name';

  @override
  String get memberAlreadyLinked => 'That circle member is already in the tree';

  @override
  String get inviteCodeCopied => 'Invite code copied';

  @override
  String get treeHint => 'Tap a person to open their profile';

  @override
  String get treeHeroTitle => 'Our family story';

  @override
  String get treeHeroBody =>
      'Every name has a story. Keep your family legacy alive.';

  @override
  String get treePeople => 'People';

  @override
  String get treeGenerations => 'Generations';

  @override
  String get treeInCircle => 'In circle';

  @override
  String generationLabel(String n) {
    return 'Generation $n';
  }

  @override
  String get treeSearchEmpty => 'No family member found';

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

  @override
  String get premiumTitle => 'Unlock premium features for free';

  @override
  String get startFreeTrial => 'Start free trial';

  @override
  String get checkIn => 'Check in';

  @override
  String get checkInSent => 'Check-in sent to your family';

  @override
  String get addPlace => 'Add place';

  @override
  String get placeNameHint => 'Place name';

  @override
  String get save => 'Save';

  @override
  String get hereFor => 'Here for';

  @override
  String get driving => 'Driving';

  @override
  String get moving => 'Moving';

  @override
  String get walking => 'Walking';

  @override
  String get cycling => 'Cycling';

  @override
  String get atRest => 'At rest';

  @override
  String get you => 'You';

  @override
  String get activity => 'Activity';

  @override
  String get distance => 'Distance';

  @override
  String get etaLabel => 'ETA';

  @override
  String get noLocationYet => 'No location yet';

  @override
  String kmValue(String value) {
    return '$value km';
  }

  @override
  String mValue(String value) {
    return '$value m';
  }

  @override
  String minValue(String value) {
    return '$value min';
  }

  @override
  String hrMinValue(String hours, String minutes) {
    return '$hours hr $minutes min';
  }

  @override
  String awayFromYou(String distance) {
    return '$distance from you';
  }

  @override
  String get locationNotUpdating => 'Location not updating';

  @override
  String get mapLayers => 'Map layers';

  @override
  String get lightMap => 'Light';

  @override
  String get standardMap => 'Standard';

  @override
  String get satelliteMap => 'Satellite';

  @override
  String get fitAllMembers => 'Fit all family members';

  @override
  String get shareInviteTipTitle => 'Keep everyone in the loop';

  @override
  String get shareInviteTipBody =>
      'Share your invite code so family can join your circle.';

  @override
  String speedKmh(int speed) {
    return '$speed km/h';
  }

  @override
  String durationDaysHours(int days, int hours) {
    return '$days d, $hours hrs';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours hrs $minutes min';
  }

  @override
  String updatedAgo(int minutes) {
    return 'Updated $minutes min ago';
  }

  @override
  String get justNow => 'Just now';

  @override
  String durationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get locationPromptTitle => 'Share your location with your family';

  @override
  String get locationPromptBody =>
      'Your circle sees your live location on the map plus your battery level. Only members of your circle can see it.';

  @override
  String get locationPromptPrivacy =>
      'You can pause sharing anytime with Ghost mode.';

  @override
  String get shareWhileUsing => 'Allow while using the app';

  @override
  String get shareAlways => 'Allow all the time';

  @override
  String get allowBackgroundTitle => 'Keep sharing in the background';

  @override
  String get allowBackgroundBody =>
      'So the map stays live when the app is closed, allow location access all the time. On Android you may need to choose it in settings.';

  @override
  String get notNow => 'Not now';

  @override
  String get openSettings => 'Open settings';

  @override
  String get locationDeniedTitle => 'Location permission needed';

  @override
  String get locationDeniedBody =>
      'Location access is off. Enable it in system settings so your family can see where you are.';

  @override
  String get backgroundTipsTitle => 'Improve background reliability';

  @override
  String get backgroundTipsBody =>
      'Some phones (Xiaomi, Oppo, Vivo, Samsung) stop apps in the background. Allow WeFamily to run without battery restrictions.';

  @override
  String get disableOptimization => 'Disable battery optimization';

  @override
  String get offline => 'Offline';

  @override
  String get myCircle => 'My circle';

  @override
  String get sharingNotificationTitle => 'WeFamily is sharing your location';

  @override
  String get sharingNotificationBody =>
      'Your family can see your live location.';

  @override
  String get enterCircleName => 'Enter a circle name';

  @override
  String get invalidCode =>
      'Invalid invite code. Check the code and try again.';

  @override
  String get alreadyMember => 'You\'re already a member of this circle.';

  @override
  String get circleFull => 'This circle is full (10 members max).';

  @override
  String get noInternet => 'No internet connection. Try again.';

  @override
  String get joinFailed => 'Could not join the circle. Try again.';

  @override
  String get manageCircle => 'Manage circle';

  @override
  String get inviteCode => 'Invite code';

  @override
  String get copyCode => 'Copy code';

  @override
  String get codeCopied => 'Code copied';

  @override
  String get regenerateCode => 'Regenerate code';

  @override
  String get regenerateConfirm =>
      'The old code stops working immediately. Continue?';

  @override
  String get regenerateSuccess => 'New invite code generated';

  @override
  String get removeMember => 'Remove';

  @override
  String removeMemberConfirm(String name) {
    return 'Remove $name from the circle?';
  }

  @override
  String get leaveCircle => 'Leave circle';

  @override
  String get leaveCircleConfirm =>
      'You\'ll stop sharing your location with this circle.';

  @override
  String get deleteCircle => 'Delete circle';

  @override
  String get deleteCircleConfirm =>
      'This deletes the circle for everyone. This cannot be undone.';

  @override
  String get circleDeleted => 'Circle deleted';

  @override
  String get leftCircle => 'You left the circle';

  @override
  String get cancel => 'Cancel';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get circleMembers => 'Members';

  @override
  String get owner => 'Owner';

  @override
  String shareInviteMessage(String code, String link) {
    return 'Join my family on WeFamily! Code: $code | $link';
  }

  @override
  String get chatEmpty => 'No messages yet. Say hello!';

  @override
  String get attach => 'Attach';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get photo => 'Photo';

  @override
  String get voiceNote => 'Voice message';

  @override
  String get holdToRecord => 'Hold to record, slide to cancel';

  @override
  String get slideToCancel => 'Slide to cancel';

  @override
  String get releaseToSend => 'Release to send';

  @override
  String get releaseToCancel => 'Release to cancel';

  @override
  String get tapToStop => 'Tap the mic to stop';

  @override
  String get micDeniedTitle => 'Microphone access needed';

  @override
  String get micDeniedBody =>
      'Allow microphone access so you can send voice notes to your family.';

  @override
  String get quickOnMyWay => 'I\'m on my way';

  @override
  String get quickReached => 'I\'ve reached';

  @override
  String get quickCallMe => 'Call me';

  @override
  String get openOnMap => 'Open on map';

  @override
  String get recording => 'Recording';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get presenceMode => 'Your mode';

  @override
  String get setMode => 'Set your mode';

  @override
  String get modeSubtitle =>
      'This shows next to your avatar on the family map.';

  @override
  String get modeAuto => 'Auto';

  @override
  String get modeDriving => 'Driving';

  @override
  String get modeHome => 'At home';

  @override
  String get modeWork => 'At work';

  @override
  String get modeOutside => 'Outside';

  @override
  String get modeEvent => 'At an event';

  @override
  String get modeUpdated => 'Mode updated';

  @override
  String get modeCleared => 'Mode set to automatic';

  @override
  String get modeSaveError => 'Could not update mode';

  @override
  String membersOnline(int members, int online) {
    return '$members members · $online online';
  }

  @override
  String membersCount(int count) {
    return '$count members';
  }

  @override
  String get mapRealistic => 'Realistic';

  @override
  String get onlineNow => 'online';

  @override
  String sosAlertTitle(String name) {
    return '$name needs help';
  }

  @override
  String get sosAlertBody =>
      'SOS was pressed. Their live location is marked in red on the map.';

  @override
  String get sosActiveTitle => 'Your SOS is active';

  @override
  String get sosActiveBody =>
      'Your circle has been notified with your exact location.';

  @override
  String get sosSent => 'SOS sent to your circle';

  @override
  String get sosCancel => 'Cancel SOS';

  @override
  String get sosCancelled => 'SOS cancelled';

  @override
  String get sosUnable => 'Could not send SOS. Check your connection.';

  @override
  String get sosNoLocation =>
      'Location unavailable. Turn on GPS and try again.';

  @override
  String get sosShowOnMap => 'Show on map';

  @override
  String get sosNotified => 'Your circle will be notified instantly';

  @override
  String sosSentAt(String time) {
    return 'Sent $time';
  }

  @override
  String get sosResolveConfirm => 'Cancel the SOS alert for everyone?';

  @override
  String get sosRecent => 'Emergency alerts';

  @override
  String get noAlerts => 'No emergency alerts right now';

  @override
  String get sosWaiting => 'Getting your exact location…';

  @override
  String get view => 'View';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get chatWithCircle => 'Chat with your circle';

  @override
  String get startConversation =>
      'Start the conversation — your family will see it instantly.';

  @override
  String get sayHello => 'Say hello';

  @override
  String get familyOrbitTitle => 'Family Orbit';

  @override
  String get familyMapTitle => 'Family Map';

  @override
  String familyMapMembersHint(int count) {
    return '$count members · tap a pin to change origin';
  }

  @override
  String get familyMapLive => 'Live';

  @override
  String get familyMapLegend => 'Shortest road route';

  @override
  String get familyMapFrom => 'Distances from';

  @override
  String get familyMapNearest => 'NEAREST';

  @override
  String get familyMapFarthest => 'FARTHEST';

  @override
  String familyMapMinDrive(int minutes) {
    return '$minutes min drive';
  }

  @override
  String get familyMapNow => 'now';

  @override
  String familyMapMinAgo(int minutes) {
    return '$minutes min ago';
  }

  @override
  String familyMapHourAgo(int hours) {
    return '$hours hr ago';
  }

  @override
  String familyMapDayAgo(int days) {
    return '$days d ago';
  }

  @override
  String membersRecenter(int count) {
    return '$count members · tap anyone to re-center';
  }

  @override
  String get backToMe => 'Back to me';

  @override
  String get relationPartner => 'Partner';

  @override
  String get relationGrandparent => 'Grandparent';

  @override
  String get relationGrandchild => 'Grandchild';

  @override
  String yourRelation(String relation) {
    return 'Your $relation';
  }

  @override
  String get addParent => '+ Parent';

  @override
  String get addSibling => '+ Sibling';

  @override
  String get addPartner => '+ Partner';

  @override
  String get addChild => '+ Child';

  @override
  String get memberAdded => 'Member added';

  @override
  String get alreadyTwoParents => 'Already has two parents';

  @override
  String get partnerAlready => 'Partner already added';

  @override
  String get treeSiblingNeedsParent =>
      'Add a parent first so this sibling can be linked';
}
