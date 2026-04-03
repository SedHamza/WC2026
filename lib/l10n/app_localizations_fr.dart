// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'WC 2026';

  @override
  String get login => 'Connexion';

  @override
  String get register => 'Inscription';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mot de passe';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get firstName => 'Prénom';

  @override
  String get lastName => 'Nom';

  @override
  String get continueWith => 'ou continuer avec';

  @override
  String get noAccount => 'Pas de compte ? ';

  @override
  String get alreadyAccount => 'Déjà un compte ? ';

  @override
  String get welcomeBack => 'Bon retour 👋';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get joinCompetition => 'Rejoignez la compétition de pronostics';

  @override
  String get signIn => 'Se connecter';

  @override
  String get signInGoogle => 'Google';

  @override
  String get signInFacebook => 'Facebook';

  @override
  String get terms => 'Conditions d\'utilisation';

  @override
  String get privacy => 'Politique de confidentialité';

  @override
  String termsText(Object terms, Object privacy) {
    return 'En créant un compte, vous acceptez nos $terms et notre $privacy';
  }

  @override
  String get networkError => 'Vérifiez votre connexion internet';

  @override
  String get serverError => 'Erreur serveur, réessayez plus tard';

  @override
  String get unknownError => 'Une erreur est survenue';

  @override
  String get sessionExpired => 'Session expirée, reconnectez-vous';

  @override
  String get invalidEmail => 'Adresse email invalide';

  @override
  String get weakPassword => 'Mot de passe trop faible';

  @override
  String get emailInUse => 'Email déjà utilisé';

  @override
  String get wrongPassword => 'Mot de passe incorrect';

  @override
  String get userNotFound => 'Aucun compte trouvé pour cet email';

  @override
  String get fieldRequired => 'Ce champ est obligatoire';

  @override
  String get passwordMismatch => 'Les mots de passe ne correspondent pas';
}
