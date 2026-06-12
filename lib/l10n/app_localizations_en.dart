// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'WC 2026';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get firstName => 'First name';

  @override
  String get lastName => 'Last name';

  @override
  String get continueWith => 'or continue with';

  @override
  String get noAccount => 'Don\'t have an account? ';

  @override
  String get alreadyAccount => 'Already have an account? ';

  @override
  String get welcomeBack => 'Welcome back 👋';

  @override
  String get createAccount => 'Create account';

  @override
  String get joinCompetition => 'Join the predictions competition';

  @override
  String get signIn => 'Sign in';

  @override
  String get signInGoogle => 'Google';

  @override
  String get signInFacebook => 'Facebook';

  @override
  String get terms => 'Terms of use';

  @override
  String get privacy => 'Privacy policy';

  @override
  String termsText(Object terms, Object privacy) {
    return 'By creating an account, you agree to our $terms and $privacy';
  }

  @override
  String get networkError => 'Check your internet connection';

  @override
  String get serverError => 'Server error, please try again';

  @override
  String get unknownError => 'An error occurred';

  @override
  String get sessionExpired => 'Session expired, please sign in again';

  @override
  String get invalidEmail => 'Invalid email address';

  @override
  String get weakPassword => 'Password is too weak';

  @override
  String get emailInUse => 'Email already in use';

  @override
  String get wrongPassword => 'Wrong password';

  @override
  String get userNotFound => 'No account found for this email';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get home => 'Home';

  @override
  String get matches => 'Matches';

  @override
  String get pronostics => 'Predictions';

  @override
  String get standings => 'Standings';

  @override
  String get rooms => 'Rooms';

  @override
  String get profile => 'Profile';

  @override
  String get news => 'News';

  @override
  String get todayMatches => 'Today\'s Matches';

  @override
  String get noMatchToday => 'No matches today';

  @override
  String get tournamentStarts => 'Tournament starts June 11, 2026';

  @override
  String get liveMatches => 'Live';

  @override
  String get upcomingMatches => 'Upcoming';

  @override
  String get finishedMatches => 'Finished';

  @override
  String get allGroups => 'All';

  @override
  String group(Object name) {
    return 'Group $name';
  }

  @override
  String get knockoutStage => 'Knockout stage';

  @override
  String get byDate => 'By date';

  @override
  String get searchTeam => 'Search a team...';

  @override
  String get noMatchFound => 'No match found';

  @override
  String get matchInfo => 'Match info';

  @override
  String get competition => 'Competition';

  @override
  String get stage => 'Stage';

  @override
  String matchday(Object number) {
    return 'Matchday $number';
  }

  @override
  String get date => 'Date';

  @override
  String get time => 'Time';

  @override
  String get live => 'LIVE';

  @override
  String get finished => 'Finished';

  @override
  String get vs => 'VS';

  @override
  String get myPronostic => 'My Prediction';

  @override
  String get exactScore => 'Exact score';

  @override
  String get otherPronostics => 'Other predictions';

  @override
  String get exactScorePts => '31 pts';

  @override
  String get otherPtsMax => 'up to 31 pts';

  @override
  String get confirmPronostic => 'Confirm prediction';

  @override
  String get updatePronostic => 'Update';

  @override
  String get pronosticSaved => 'Prediction saved';

  @override
  String get clearPronostic => 'Clear';

  @override
  String get lockedMatch => 'Match started — prediction locked';

  @override
  String get whoWins => 'Who will win?';

  @override
  String get maxGoals => 'Max goals in the match';

  @override
  String get minGoals => 'Min goals in the match';

  @override
  String get draw => 'Draw';

  @override
  String potentialPts(Object pts) {
    return '$pts pts';
  }

  @override
  String totalEstimated(Object pts) {
    return 'Estimated total → $pts points';
  }

  @override
  String get exactResult => 'Exact score → 31 points';

  @override
  String get myRooms => 'My Rooms';

  @override
  String get createRoom => 'Create room';

  @override
  String get joinRoom => 'Join';

  @override
  String get joinWithCode => 'Join with a code';

  @override
  String get noRooms => 'No rooms yet';

  @override
  String get noRoomsSubtitle =>
      'Create a room and invite your friends to play together!';

  @override
  String get roomName => 'Room name';

  @override
  String get roomNameHint => 'e.g. Friends, Family...';

  @override
  String get roomCode => 'Room code';

  @override
  String get roomCodeHint => 'WC26-XXXX';

  @override
  String get roomCreated => 'Room created! 🎉';

  @override
  String roomCreatedSuccess(Object name) {
    return '$name was created successfully.';
  }

  @override
  String get shareCode => 'Share this code with your friends:';

  @override
  String get great => 'Great!';

  @override
  String get leaveRoom => 'Leave room';

  @override
  String leaveRoomConfirm(Object name) {
    return 'You are about to leave \"$name\".';
  }

  @override
  String get leaveRoomTitle => 'Leave room?';

  @override
  String get cancel => 'Cancel';

  @override
  String get leave => 'Leave';

  @override
  String get members => 'Members';

  @override
  String get myRank => 'My rank';

  @override
  String get myPoints => 'My points';

  @override
  String get memberPronostics => 'Members\' predictions';

  @override
  String get leaderboard => 'Leaderboard';

  @override
  String get codeCopied => 'Code copied!';

  @override
  String get noPronosticsYet => 'No predictions yet';

  @override
  String get beFirstToPronostic => 'Be the first to predict!';

  @override
  String get visibleAfterStart => 'Visible after kick-off';

  @override
  String get noPronostic => 'No prediction';

  @override
  String get didNotPronostic => 'Did not predict';

  @override
  String get modify => 'Edit →';

  @override
  String get invalidCode => 'Invalid code — room not found';

  @override
  String get askCodeFromAdmin => 'Ask the room admin for the code.';

  @override
  String get myProfile => 'Profile';

  @override
  String get signOut => 'Sign out';

  @override
  String get totalPoints => 'Total points';

  @override
  String get totalPronostics => 'Predictions';

  @override
  String get avgPtsPerMatch => 'Avg pts/match';

  @override
  String get statistics => 'Statistics';

  @override
  String get exactScores => 'Exact scores';

  @override
  String get successRate => 'Success rate';

  @override
  String get bestMatch => 'Best match';

  @override
  String get correctWinners => 'Correct winners';

  @override
  String get pronosticHistory => 'Prediction history';

  @override
  String get noPronosticsHistory => 'No predictions yet';

  @override
  String get makeFirstPronostic => 'Make your first predictions!';

  @override
  String maxPts(Object pts, Object status) {
    return 'Max: $pts pts · $status';
  }

  @override
  String get pending => 'Pending';

  @override
  String get inProgress => 'Live';

  @override
  String get mode => 'Mode';

  @override
  String get predictedScore => 'Predicted score';

  @override
  String get whoWon => 'Who wins';

  @override
  String maxGoalsLabel(Object n) {
    return 'Max goals (≤$n)';
  }

  @override
  String minGoalsLabel(Object n) {
    return 'Min goals (≥$n)';
  }

  @override
  String get totalObtained => 'Total earned';

  @override
  String get close => 'Close';

  @override
  String get edit => 'Edit';

  @override
  String get exactScoreMode => 'Exact score';

  @override
  String get otherMode => 'Other predictions';

  @override
  String groupStandings(Object name) {
    return 'Group $name';
  }

  @override
  String get bestThirds => 'Best 3rds';

  @override
  String get bestThirdsSubtitle => '8 qualify from 12 groups — FIFA rules';

  @override
  String get qualifiedFor32 => 'Qualified for Round of 32';

  @override
  String get eliminated => 'Eliminated';

  @override
  String get availableAfterGroups => 'Available after the group stage';

  @override
  String get qualified => 'Qualified';

  @override
  String get possibleThird => 'Possible 3rd';

  @override
  String get played => 'P';

  @override
  String get won => 'W';

  @override
  String get drawnShort => 'D';

  @override
  String get lost => 'L';

  @override
  String get points => 'Pts';

  @override
  String get team => 'Team';

  @override
  String get groupShort => 'Grp';

  @override
  String get groupMatches => 'Group matches';

  @override
  String get retry => 'Retry';

  @override
  String get connectionError => 'Connection error';

  @override
  String get loadingError => 'Loading error';

  @override
  String get me => 'Me';

  @override
  String get chooseDate => 'Choose a date';

  @override
  String get clearDate => 'Clear';

  @override
  String get last32 => 'Round of 32';

  @override
  String get last16 => 'Round of 16';

  @override
  String get quarterFinals => 'Quarter-finals';

  @override
  String get semiFinals => 'Semi-finals';

  @override
  String get thirdPlace => '3rd place';

  @override
  String get finalMatch => 'Final';

  @override
  String get all => 'All';

  @override
  String joinedRoom(Object name) {
    return 'You joined \"$name\"!';
  }

  @override
  String finalResult(Object home, Object away) {
    return 'Final result: $home - $away';
  }

  @override
  String get settings => 'Settings';

  @override
  String get account => 'Account';

  @override
  String get appearance => 'Appearance';

  @override
  String get language => 'Language';

  @override
  String get memberSince => 'Member since';

  @override
  String get pseudo => 'Username';

  @override
  String get darkMode => 'Theme';

  @override
  String get testMode => 'Test mode';

  @override
  String get testModeSubtitle => 'Match simulator';

  @override
  String get appVersion => 'Version';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountConfirm => 'This action is irreversible.';

  @override
  String get delete => 'Delete';

  @override
  String get application => 'Application';

  @override
  String get testModeUnlocked => '🧪 Test mode unlocked!';

  @override
  String get editPseudo => 'Edit username';

  @override
  String get pseudoHint => 'Your username...';

  @override
  String get save => 'Save';

  @override
  String get pseudoUpdated => 'Username updated!';

  @override
  String get tournament => 'Tournament';

  @override
  String get exactScoreLabel => 'Exact score';

  @override
  String get winnerLabel => 'Winner';

  @override
  String maxGoalsLabel2(Object n) {
    return 'Max ≤$n goals';
  }

  @override
  String minGoalsLabel2(Object n) {
    return 'Min ≥$n goals';
  }

  @override
  String currentScore(Object home, Object away) {
    return 'Current score: $home - $away';
  }

  @override
  String livePoints(Object pts) {
    return '🔴 $pts pts live';
  }

  @override
  String get maxGoalsFormula => '(7 - value) × 3 pts';

  @override
  String get minGoalsFormula => 'value × 3 pts';

  @override
  String get hasPronostic => 'Predicted';

  @override
  String get bothTeamsScore => 'Will both teams score?';

  @override
  String bothTeamsScoreLabel(Object choice) {
    return 'BTTS: $choice';
  }

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get upcomingToday => 'Coming up today';
}
