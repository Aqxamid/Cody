/// App configuration constants.
/// Replace all placeholder values with your real credentials.
/// Before releasing to production, move API keys to a secure backend.
class AppConfig {
  // ── Supabase ─────────────────────────────────────────────────────────────────
  /// Your Supabase project URL (Settings → API → Project URL)
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';

  /// Your Supabase anon/public key (Settings → API → anon key)
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  // ── Brevo ─────────────────────────────────────────────────────────────────────
  /// Brevo REST API key (Brevo Dashboard → SMTP & API → API Keys)
  static const String brevoApiKey = 'YOUR_BREVO_API_KEY';

  /// Sender name shown in welcome emails
  static const String brevoSenderName = 'Cody App';

  /// Sender email address (must be verified in Brevo)
  static const String brevoSenderEmail = 'noreply@yourdomain.com';


  // ── OAuth Deep Link ───────────────────────────────────────────────────────────
  /// Redirect URI registered in Supabase Auth → URL Configuration
  static const String oauthRedirectUrl = 'com.cody.app://login-callback';

}
