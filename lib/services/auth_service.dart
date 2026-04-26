import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';
import 'email_service.dart';

class AuthService {
  static final _client = Supabase.instance.client;

  static User? get currentUser => _client.auth.currentUser;
  static bool get isGuest => currentUser == null;

  // ── Google OAuth ────────────────────────────────────────────────────────────
  static Future<bool> signInWithGoogle() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: AppConfig.oauthRedirectUrl,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Email / Password Sign Up ────────────────────────────────────────────────
  static Future<String?> signUp(String email, String password, String username) async {
    try {
      final res = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );
      if (res.user != null) {
        await EmailService.sendWelcome(username, email);
        return null; // success
      }
      return 'Sign up failed. Please try again.';
    } on AuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'Connection error. Please check your network.';
    }
  }

  // ── Email / Password Sign In ────────────────────────────────────────────────
  static Future<String?> signIn(String email, String password) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
      return null; // success
    } on AuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'Connection error. Please check your network.';
    }
  }

  // ── Forgot Password ─────────────────────────────────────────────────────────
  static Future<String?> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: AppConfig.oauthRedirectUrl,
      );
      return null; // success
    } on AuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'Connection error.';
    }
  }

  // ── Sign Out ────────────────────────────────────────────────────────────────
  static Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (_) {}
  }
}
