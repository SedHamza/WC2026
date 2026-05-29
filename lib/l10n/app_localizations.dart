import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('fr')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'WC 2026'**
  String get appName;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// No description provided for @continueWith.
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get continueWith;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get noAccount;

  /// No description provided for @alreadyAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyAccount;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back 👋'**
  String get welcomeBack;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @joinCompetition.
  ///
  /// In en, this message translates to:
  /// **'Join the predictions competition'**
  String get joinCompetition;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signInGoogle.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get signInGoogle;

  /// No description provided for @signInFacebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get signInFacebook;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get terms;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacy;

  /// No description provided for @termsText.
  ///
  /// In en, this message translates to:
  /// **'By creating an account, you agree to our {terms} and {privacy}'**
  String termsText(Object terms, Object privacy);

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection'**
  String get networkError;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error, please try again'**
  String get serverError;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get unknownError;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired, please sign in again'**
  String get sessionExpired;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get invalidEmail;

  /// No description provided for @weakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak'**
  String get weakPassword;

  /// No description provided for @emailInUse.
  ///
  /// In en, this message translates to:
  /// **'Email already in use'**
  String get emailInUse;

  /// No description provided for @wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong password'**
  String get wrongPassword;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'No account found for this email'**
  String get userNotFound;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @matches.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get matches;

  /// No description provided for @pronostics.
  ///
  /// In en, this message translates to:
  /// **'Predictions'**
  String get pronostics;

  /// No description provided for @standings.
  ///
  /// In en, this message translates to:
  /// **'Standings'**
  String get standings;

  /// No description provided for @rooms.
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get rooms;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @news.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get news;

  /// No description provided for @todayMatches.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Matches'**
  String get todayMatches;

  /// No description provided for @noMatchToday.
  ///
  /// In en, this message translates to:
  /// **'No matches today'**
  String get noMatchToday;

  /// No description provided for @tournamentStarts.
  ///
  /// In en, this message translates to:
  /// **'Tournament starts June 11, 2026'**
  String get tournamentStarts;

  /// No description provided for @liveMatches.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get liveMatches;

  /// No description provided for @upcomingMatches.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcomingMatches;

  /// No description provided for @finishedMatches.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get finishedMatches;

  /// No description provided for @allGroups.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allGroups;

  /// No description provided for @group.
  ///
  /// In en, this message translates to:
  /// **'Group {name}'**
  String group(Object name);

  /// No description provided for @knockoutStage.
  ///
  /// In en, this message translates to:
  /// **'Knockout stage'**
  String get knockoutStage;

  /// No description provided for @byDate.
  ///
  /// In en, this message translates to:
  /// **'By date'**
  String get byDate;

  /// No description provided for @searchTeam.
  ///
  /// In en, this message translates to:
  /// **'Search a team...'**
  String get searchTeam;

  /// No description provided for @noMatchFound.
  ///
  /// In en, this message translates to:
  /// **'No match found'**
  String get noMatchFound;

  /// No description provided for @matchInfo.
  ///
  /// In en, this message translates to:
  /// **'Match info'**
  String get matchInfo;

  /// No description provided for @competition.
  ///
  /// In en, this message translates to:
  /// **'Competition'**
  String get competition;

  /// No description provided for @stage.
  ///
  /// In en, this message translates to:
  /// **'Stage'**
  String get stage;

  /// No description provided for @matchday.
  ///
  /// In en, this message translates to:
  /// **'Matchday {number}'**
  String matchday(Object number);

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @live.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get live;

  /// No description provided for @finished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get finished;

  /// No description provided for @vs.
  ///
  /// In en, this message translates to:
  /// **'VS'**
  String get vs;

  /// No description provided for @myPronostic.
  ///
  /// In en, this message translates to:
  /// **'My Prediction'**
  String get myPronostic;

  /// No description provided for @exactScore.
  ///
  /// In en, this message translates to:
  /// **'Exact score'**
  String get exactScore;

  /// No description provided for @otherPronostics.
  ///
  /// In en, this message translates to:
  /// **'Other predictions'**
  String get otherPronostics;

  /// No description provided for @exactScorePts.
  ///
  /// In en, this message translates to:
  /// **'25 pts'**
  String get exactScorePts;

  /// No description provided for @otherPtsMax.
  ///
  /// In en, this message translates to:
  /// **'up to 23 pts'**
  String get otherPtsMax;

  /// No description provided for @confirmPronostic.
  ///
  /// In en, this message translates to:
  /// **'Confirm prediction'**
  String get confirmPronostic;

  /// No description provided for @updatePronostic.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updatePronostic;

  /// No description provided for @pronosticSaved.
  ///
  /// In en, this message translates to:
  /// **'Prediction saved'**
  String get pronosticSaved;

  /// No description provided for @clearPronostic.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearPronostic;

  /// No description provided for @lockedMatch.
  ///
  /// In en, this message translates to:
  /// **'Match started — prediction locked'**
  String get lockedMatch;

  /// No description provided for @whoWins.
  ///
  /// In en, this message translates to:
  /// **'Who will win?'**
  String get whoWins;

  /// No description provided for @maxGoals.
  ///
  /// In en, this message translates to:
  /// **'Max goals in the match'**
  String get maxGoals;

  /// No description provided for @minGoals.
  ///
  /// In en, this message translates to:
  /// **'Min goals in the match'**
  String get minGoals;

  /// No description provided for @draw.
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get draw;

  /// No description provided for @potentialPts.
  ///
  /// In en, this message translates to:
  /// **'{pts} pts'**
  String potentialPts(Object pts);

  /// No description provided for @totalEstimated.
  ///
  /// In en, this message translates to:
  /// **'Estimated total → {pts} points'**
  String totalEstimated(Object pts);

  /// No description provided for @exactResult.
  ///
  /// In en, this message translates to:
  /// **'Exact score → 25 points'**
  String get exactResult;

  /// No description provided for @myRooms.
  ///
  /// In en, this message translates to:
  /// **'My Rooms'**
  String get myRooms;

  /// No description provided for @createRoom.
  ///
  /// In en, this message translates to:
  /// **'Create room'**
  String get createRoom;

  /// No description provided for @joinRoom.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get joinRoom;

  /// No description provided for @joinWithCode.
  ///
  /// In en, this message translates to:
  /// **'Join with a code'**
  String get joinWithCode;

  /// No description provided for @noRooms.
  ///
  /// In en, this message translates to:
  /// **'No rooms yet'**
  String get noRooms;

  /// No description provided for @noRoomsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a room and invite your friends to play together!'**
  String get noRoomsSubtitle;

  /// No description provided for @roomName.
  ///
  /// In en, this message translates to:
  /// **'Room name'**
  String get roomName;

  /// No description provided for @roomNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Friends, Family...'**
  String get roomNameHint;

  /// No description provided for @roomCode.
  ///
  /// In en, this message translates to:
  /// **'Room code'**
  String get roomCode;

  /// No description provided for @roomCodeHint.
  ///
  /// In en, this message translates to:
  /// **'WC26-XXXX'**
  String get roomCodeHint;

  /// No description provided for @roomCreated.
  ///
  /// In en, this message translates to:
  /// **'Room created! 🎉'**
  String get roomCreated;

  /// No description provided for @roomCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'{name} was created successfully.'**
  String roomCreatedSuccess(Object name);

  /// No description provided for @shareCode.
  ///
  /// In en, this message translates to:
  /// **'Share this code with your friends:'**
  String get shareCode;

  /// No description provided for @great.
  ///
  /// In en, this message translates to:
  /// **'Great!'**
  String get great;

  /// No description provided for @leaveRoom.
  ///
  /// In en, this message translates to:
  /// **'Leave room'**
  String get leaveRoom;

  /// No description provided for @leaveRoomConfirm.
  ///
  /// In en, this message translates to:
  /// **'You are about to leave \"{name}\".'**
  String leaveRoomConfirm(Object name);

  /// No description provided for @leaveRoomTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave room?'**
  String get leaveRoomTitle;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get members;

  /// No description provided for @myRank.
  ///
  /// In en, this message translates to:
  /// **'My rank'**
  String get myRank;

  /// No description provided for @myPoints.
  ///
  /// In en, this message translates to:
  /// **'My points'**
  String get myPoints;

  /// No description provided for @memberPronostics.
  ///
  /// In en, this message translates to:
  /// **'Members\' predictions'**
  String get memberPronostics;

  /// No description provided for @leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// No description provided for @codeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied!'**
  String get codeCopied;

  /// No description provided for @noPronosticsYet.
  ///
  /// In en, this message translates to:
  /// **'No predictions yet'**
  String get noPronosticsYet;

  /// No description provided for @beFirstToPronostic.
  ///
  /// In en, this message translates to:
  /// **'Be the first to predict!'**
  String get beFirstToPronostic;

  /// No description provided for @visibleAfterStart.
  ///
  /// In en, this message translates to:
  /// **'Visible after kick-off'**
  String get visibleAfterStart;

  /// No description provided for @noPronostic.
  ///
  /// In en, this message translates to:
  /// **'No prediction'**
  String get noPronostic;

  /// No description provided for @didNotPronostic.
  ///
  /// In en, this message translates to:
  /// **'Did not predict'**
  String get didNotPronostic;

  /// No description provided for @modify.
  ///
  /// In en, this message translates to:
  /// **'Edit →'**
  String get modify;

  /// No description provided for @invalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid code — room not found'**
  String get invalidCode;

  /// No description provided for @askCodeFromAdmin.
  ///
  /// In en, this message translates to:
  /// **'Ask the room admin for the code.'**
  String get askCodeFromAdmin;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get myProfile;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @totalPoints.
  ///
  /// In en, this message translates to:
  /// **'Total points'**
  String get totalPoints;

  /// No description provided for @totalPronostics.
  ///
  /// In en, this message translates to:
  /// **'Predictions'**
  String get totalPronostics;

  /// No description provided for @avgPtsPerMatch.
  ///
  /// In en, this message translates to:
  /// **'Avg pts/match'**
  String get avgPtsPerMatch;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @exactScores.
  ///
  /// In en, this message translates to:
  /// **'Exact scores'**
  String get exactScores;

  /// No description provided for @successRate.
  ///
  /// In en, this message translates to:
  /// **'Success rate'**
  String get successRate;

  /// No description provided for @bestMatch.
  ///
  /// In en, this message translates to:
  /// **'Best match'**
  String get bestMatch;

  /// No description provided for @correctWinners.
  ///
  /// In en, this message translates to:
  /// **'Correct winners'**
  String get correctWinners;

  /// No description provided for @pronosticHistory.
  ///
  /// In en, this message translates to:
  /// **'Prediction history'**
  String get pronosticHistory;

  /// No description provided for @noPronosticsHistory.
  ///
  /// In en, this message translates to:
  /// **'No predictions yet'**
  String get noPronosticsHistory;

  /// No description provided for @makeFirstPronostic.
  ///
  /// In en, this message translates to:
  /// **'Make your first predictions!'**
  String get makeFirstPronostic;

  /// No description provided for @maxPts.
  ///
  /// In en, this message translates to:
  /// **'Max: {pts} pts · {status}'**
  String maxPts(Object pts, Object status);

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get inProgress;

  /// No description provided for @mode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get mode;

  /// No description provided for @predictedScore.
  ///
  /// In en, this message translates to:
  /// **'Predicted score'**
  String get predictedScore;

  /// No description provided for @whoWon.
  ///
  /// In en, this message translates to:
  /// **'Who wins'**
  String get whoWon;

  /// No description provided for @maxGoalsLabel.
  ///
  /// In en, this message translates to:
  /// **'Max goals (≤{n})'**
  String maxGoalsLabel(Object n);

  /// No description provided for @minGoalsLabel.
  ///
  /// In en, this message translates to:
  /// **'Min goals (≥{n})'**
  String minGoalsLabel(Object n);

  /// No description provided for @totalObtained.
  ///
  /// In en, this message translates to:
  /// **'Total earned'**
  String get totalObtained;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @exactScoreMode.
  ///
  /// In en, this message translates to:
  /// **'Exact score'**
  String get exactScoreMode;

  /// No description provided for @otherMode.
  ///
  /// In en, this message translates to:
  /// **'Other predictions'**
  String get otherMode;

  /// No description provided for @groupStandings.
  ///
  /// In en, this message translates to:
  /// **'Group {name}'**
  String groupStandings(Object name);

  /// No description provided for @bestThirds.
  ///
  /// In en, this message translates to:
  /// **'Best 3rds'**
  String get bestThirds;

  /// No description provided for @bestThirdsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'8 qualify from 12 groups — FIFA rules'**
  String get bestThirdsSubtitle;

  /// No description provided for @qualifiedFor32.
  ///
  /// In en, this message translates to:
  /// **'Qualified for Round of 32'**
  String get qualifiedFor32;

  /// No description provided for @eliminated.
  ///
  /// In en, this message translates to:
  /// **'Eliminated'**
  String get eliminated;

  /// No description provided for @availableAfterGroups.
  ///
  /// In en, this message translates to:
  /// **'Available after the group stage'**
  String get availableAfterGroups;

  /// No description provided for @qualified.
  ///
  /// In en, this message translates to:
  /// **'Qualified'**
  String get qualified;

  /// No description provided for @possibleThird.
  ///
  /// In en, this message translates to:
  /// **'Possible 3rd'**
  String get possibleThird;

  /// No description provided for @played.
  ///
  /// In en, this message translates to:
  /// **'P'**
  String get played;

  /// No description provided for @won.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get won;

  /// No description provided for @drawnShort.
  ///
  /// In en, this message translates to:
  /// **'D'**
  String get drawnShort;

  /// No description provided for @lost.
  ///
  /// In en, this message translates to:
  /// **'L'**
  String get lost;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'Pts'**
  String get points;

  /// No description provided for @team.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get team;

  /// No description provided for @groupShort.
  ///
  /// In en, this message translates to:
  /// **'Grp'**
  String get groupShort;

  /// No description provided for @groupMatches.
  ///
  /// In en, this message translates to:
  /// **'Group matches'**
  String get groupMatches;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @connectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection error'**
  String get connectionError;

  /// No description provided for @loadingError.
  ///
  /// In en, this message translates to:
  /// **'Loading error'**
  String get loadingError;

  /// No description provided for @me.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get me;

  /// No description provided for @chooseDate.
  ///
  /// In en, this message translates to:
  /// **'Choose a date'**
  String get chooseDate;

  /// No description provided for @clearDate.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearDate;

  /// No description provided for @last32.
  ///
  /// In en, this message translates to:
  /// **'Round of 32'**
  String get last32;

  /// No description provided for @last16.
  ///
  /// In en, this message translates to:
  /// **'Round of 16'**
  String get last16;

  /// No description provided for @quarterFinals.
  ///
  /// In en, this message translates to:
  /// **'Quarter-finals'**
  String get quarterFinals;

  /// No description provided for @semiFinals.
  ///
  /// In en, this message translates to:
  /// **'Semi-finals'**
  String get semiFinals;

  /// No description provided for @thirdPlace.
  ///
  /// In en, this message translates to:
  /// **'3rd place'**
  String get thirdPlace;

  /// No description provided for @finalMatch.
  ///
  /// In en, this message translates to:
  /// **'Final'**
  String get finalMatch;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @joinedRoom.
  ///
  /// In en, this message translates to:
  /// **'You joined \"{name}\"!'**
  String joinedRoom(Object name);
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
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

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
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
