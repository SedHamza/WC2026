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
  String get news => 'News';
}
