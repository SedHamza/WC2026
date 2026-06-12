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

  @override
  String get home => 'Accueil';

  @override
  String get matches => 'Matchs';

  @override
  String get pronostics => 'Pronostics';

  @override
  String get standings => 'Classement';

  @override
  String get rooms => 'Rooms';

  @override
  String get profile => 'Profil';

  @override
  String get news => 'Actualités';

  @override
  String get todayMatches => 'Matchs d\'aujourd\'hui';

  @override
  String get noMatchToday => 'Aucun match aujourd\'hui';

  @override
  String get tournamentStarts => 'Le tournoi commence le 11 juin 2026';

  @override
  String get liveMatches => 'En direct';

  @override
  String get upcomingMatches => 'À venir';

  @override
  String get finishedMatches => 'Terminés';

  @override
  String get allGroups => 'Tous';

  @override
  String group(Object name) {
    return 'Groupe $name';
  }

  @override
  String get knockoutStage => 'Phases finales';

  @override
  String get byDate => 'Par date';

  @override
  String get searchTeam => 'Rechercher une équipe...';

  @override
  String get noMatchFound => 'Aucun match trouvé';

  @override
  String get matchInfo => 'Informations';

  @override
  String get competition => 'Compétition';

  @override
  String get stage => 'Phase';

  @override
  String matchday(Object number) {
    return 'Journée $number';
  }

  @override
  String get date => 'Date';

  @override
  String get time => 'Heure';

  @override
  String get live => 'EN DIRECT';

  @override
  String get finished => 'Terminé';

  @override
  String get vs => 'VS';

  @override
  String get myPronostic => 'Mon Pronostic';

  @override
  String get exactScore => 'Résultat exact';

  @override
  String get otherPronostics => 'Autres pronostics';

  @override
  String get exactScorePts => '25 pts';

  @override
  String get otherPtsMax => 'jusqu\'à 19 pts';

  @override
  String get confirmPronostic => 'Confirmer le pronostic';

  @override
  String get updatePronostic => 'Mettre à jour';

  @override
  String get pronosticSaved => 'Pronostic enregistré';

  @override
  String get clearPronostic => 'Effacer';

  @override
  String get lockedMatch => 'Match commencé — pronostic verrouillé';

  @override
  String get whoWins => 'Qui va gagner ?';

  @override
  String get maxGoals => 'Max buts dans le match';

  @override
  String get minGoals => 'Min buts dans le match';

  @override
  String get draw => 'Égalité';

  @override
  String potentialPts(Object pts) {
    return '$pts pts';
  }

  @override
  String totalEstimated(Object pts) {
    return 'Total estimé → $pts points';
  }

  @override
  String get exactResult => 'Résultat exact → 25 points';

  @override
  String get myRooms => 'Mes Rooms';

  @override
  String get createRoom => 'Créer une room';

  @override
  String get joinRoom => 'Rejoindre';

  @override
  String get joinWithCode => 'Rejoindre avec un code';

  @override
  String get noRooms => 'Aucune room encore';

  @override
  String get noRoomsSubtitle =>
      'Crée une room et invite tes amis pour jouer ensemble !';

  @override
  String get roomName => 'Nom de la room';

  @override
  String get roomNameHint => 'Ex: Les Collègues, Famille...';

  @override
  String get roomCode => 'Code de la room';

  @override
  String get roomCodeHint => 'WC26-XXXX';

  @override
  String get roomCreated => 'Room créée ! 🎉';

  @override
  String roomCreatedSuccess(Object name) {
    return '$name a été créée avec succès.';
  }

  @override
  String get shareCode => 'Partage ce code avec tes amis :';

  @override
  String get great => 'Super !';

  @override
  String get leaveRoom => 'Quitter la room';

  @override
  String leaveRoomConfirm(Object name) {
    return 'Tu vas quitter \"$name\".';
  }

  @override
  String get leaveRoomTitle => 'Quitter la room ?';

  @override
  String get cancel => 'Annuler';

  @override
  String get leave => 'Quitter';

  @override
  String get members => 'Membres';

  @override
  String get myRank => 'Mon rang';

  @override
  String get myPoints => 'Mes points';

  @override
  String get memberPronostics => 'Pronostics des membres';

  @override
  String get leaderboard => 'Classement';

  @override
  String get codeCopied => 'Code copié !';

  @override
  String get noPronosticsYet => 'Aucun pronostic encore';

  @override
  String get beFirstToPronostic => 'Soyez le premier à pronostiquer !';

  @override
  String get visibleAfterStart => 'Visible après le début';

  @override
  String get noPronostic => 'Aucun pronostic';

  @override
  String get didNotPronostic => 'N\'a pas pronostiqué';

  @override
  String get modify => 'Modifier →';

  @override
  String get invalidCode => 'Code invalide — room introuvable';

  @override
  String get askCodeFromAdmin =>
      'Demande le code à l\'administrateur de la room.';

  @override
  String get myProfile => 'Profil';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get totalPoints => 'Points totaux';

  @override
  String get totalPronostics => 'Pronostics';

  @override
  String get avgPtsPerMatch => 'Moy. pts/match';

  @override
  String get statistics => 'Statistiques';

  @override
  String get exactScores => 'Scores exacts';

  @override
  String get successRate => 'Taux de réussite';

  @override
  String get bestMatch => 'Meilleur match';

  @override
  String get correctWinners => 'Vainqueurs corrects';

  @override
  String get pronosticHistory => 'Historique des pronostics';

  @override
  String get noPronosticsHistory => 'Aucun pronostic encore';

  @override
  String get makeFirstPronostic => 'Fais tes premiers pronostics !';

  @override
  String maxPts(Object pts, Object status) {
    return 'Max : $pts pts · $status';
  }

  @override
  String get pending => 'En attente';

  @override
  String get inProgress => 'En direct';

  @override
  String get mode => 'Mode';

  @override
  String get predictedScore => 'Score prédit';

  @override
  String get whoWon => 'Qui gagne';

  @override
  String maxGoalsLabel(Object n) {
    return 'Max buts (≤$n)';
  }

  @override
  String minGoalsLabel(Object n) {
    return 'Min buts (≥$n)';
  }

  @override
  String get totalObtained => 'Total obtenu';

  @override
  String get close => 'Fermer';

  @override
  String get edit => 'Modifier';

  @override
  String get exactScoreMode => 'Résultat exact';

  @override
  String get otherMode => 'Autres pronostics';

  @override
  String groupStandings(Object name) {
    return 'Groupe $name';
  }

  @override
  String get bestThirds => 'Meilleurs 3èmes';

  @override
  String get bestThirdsSubtitle => '8 qualifiés sur 12 groupes — règles FIFA';

  @override
  String get qualifiedFor32 => 'Qualifié pour le 32è';

  @override
  String get eliminated => 'Éliminé';

  @override
  String get availableAfterGroups => 'Disponible après la phase de groupes';

  @override
  String get qualified => 'Qualifié';

  @override
  String get possibleThird => 'Possible 3ème';

  @override
  String get played => 'MJ';

  @override
  String get won => 'G';

  @override
  String get drawnShort => 'N';

  @override
  String get lost => 'P';

  @override
  String get points => 'Pts';

  @override
  String get team => 'Équipe';

  @override
  String get groupShort => 'Grp';

  @override
  String get groupMatches => 'Matchs du groupe';

  @override
  String get retry => 'Réessayer';

  @override
  String get connectionError => 'Erreur de connexion';

  @override
  String get loadingError => 'Erreur de chargement';

  @override
  String get me => 'Moi';

  @override
  String get chooseDate => 'Choisir une date';

  @override
  String get clearDate => 'Effacer';

  @override
  String get last32 => '32èmes';

  @override
  String get last16 => '16èmes';

  @override
  String get quarterFinals => 'Quarts';

  @override
  String get semiFinals => 'Demis';

  @override
  String get thirdPlace => '3ème place';

  @override
  String get finalMatch => 'Finale';

  @override
  String get all => 'Tous';

  @override
  String joinedRoom(Object name) {
    return 'Tu as rejoint \"$name\" !';
  }

  @override
  String finalResult(Object home, Object away) {
    return 'Résultat final : $home - $away';
  }

  @override
  String get settings => 'Paramètres';

  @override
  String get account => 'Compte';

  @override
  String get appearance => 'Apparence';

  @override
  String get language => 'Langue';

  @override
  String get memberSince => 'Membre depuis';

  @override
  String get pseudo => 'Pseudo';

  @override
  String get darkMode => 'Thème';

  @override
  String get testMode => 'Mode test';

  @override
  String get testModeSubtitle => 'Simulateur de matchs';

  @override
  String get appVersion => 'Version';

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String get deleteAccountConfirm => 'Cette action est irréversible.';

  @override
  String get delete => 'Supprimer';

  @override
  String get application => 'Application';

  @override
  String get testModeUnlocked => '🧪 Mode test débloqué !';

  @override
  String get editPseudo => 'Modifier le pseudo';

  @override
  String get pseudoHint => 'Ton pseudo...';

  @override
  String get save => 'Enregistrer';

  @override
  String get pseudoUpdated => 'Pseudo mis à jour !';

  @override
  String get tournament => 'Tournoi';

  @override
  String get exactScoreLabel => 'Score exact';

  @override
  String get winnerLabel => 'Vainqueur';

  @override
  String maxGoalsLabel2(Object n) {
    return 'Max ≤$n buts';
  }

  @override
  String minGoalsLabel2(Object n) {
    return 'Min ≥$n buts';
  }

  @override
  String currentScore(Object home, Object away) {
    return 'Score actuel : $home - $away';
  }

  @override
  String livePoints(Object pts) {
    return '🔴 $pts pts live';
  }

  @override
  String get maxGoalsFormula => '(7 - valeur) × 2 pts';

  @override
  String get minGoalsFormula => 'valeur × 2 pts';

  @override
  String get hasPronostic => 'A pronostiqué';
}
