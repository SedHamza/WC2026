import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../pronostics/data/repositories/pronostic_repository_impl.dart';

final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<User?> {
  final PronosticRepositoryImpl _pronosticRepo = PronosticRepositoryImpl();

  AuthNotifier() : super(FirebaseAuth.instance.currentUser) {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      state = user;
    });
  }

  // ── Crée le profil Firestore si pas encore existant ──────────────────────
  Future<void> _createProfileIfNeeded(User user) async {
    await _pronosticRepo.createUserProfile(
      user.uid,
      user.displayName ?? user.email?.split('@')[0] ?? 'Utilisateur',
      user.email ?? '',
    );
  }

  // ── EMAIL / PASSWORD ──────────────────────────────────────────────────────

  Future<String?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        await _createProfileIfNeeded(credential.user!);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e.code);
    } catch (e) {
      return 'Une erreur est survenue';
    }
  }

  Future<String?> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName('$firstName $lastName');

      if (credential.user != null) {
        // Recharge l'user pour avoir le displayName mis à jour
        await credential.user!.reload();
        final updatedUser = FirebaseAuth.instance.currentUser;
        await _pronosticRepo.createUserProfile(
          updatedUser!.uid,
          '$firstName $lastName',
          email,
        );
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e.code);
    } catch (e) {
      return 'Une erreur est survenue';
    }
  }

  // ── GOOGLE ────────────────────────────────────────────────────────────────

  Future<String?> signInWithGoogle() async {
    try {
      await GoogleSignIn.instance.initialize(
        serverClientId: Platform.isIOS
            ? '193867110649-qre2c5jeqjrrpkjkqk06ljl2sdvstmi1.apps.googleusercontent.com'
            : '193867110649-9lmfsnf7t9jbadthnaqp40t9i7slkbf6.apps.googleusercontent.com',
      );

      final googleUser = await GoogleSignIn.instance.authenticate();
      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        await _createProfileIfNeeded(userCredential.user!);
      }
      return null;
    } on GoogleSignInException catch (e) {
      return 'Erreur Google: ${e.description}';
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e.code);
    } catch (e) {
      return 'Erreur Google Sign In: $e';
    }
  }

  // ── SIGN OUT ──────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    await FirebaseAuth.instance.signOut();
  }

  // ── ERROR HANDLER ─────────────────────────────────────────────────────────

  String _handleAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Aucun compte trouvé pour cet email';
      case 'wrong-password':
        return 'Mot de passe incorrect';
      case 'email-already-in-use':
        return 'Email déjà utilisé';
      case 'weak-password':
        return 'Mot de passe trop faible (min 6 caractères)';
      case 'invalid-email':
        return 'Adresse email invalide';
      case 'user-disabled':
        return 'Ce compte a été désactivé';
      case 'too-many-requests':
        return 'Trop de tentatives, réessayez plus tard';
      case 'network-request-failed':
        return 'Vérifiez votre connexion internet';
      case 'invalid-credential':
        return 'Email ou mot de passe incorrect';
      default:
        return 'Une erreur est survenue ($code)';
    }
  }
}
