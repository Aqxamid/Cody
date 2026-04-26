import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class EmailService {
  static const String _brevoUrl = 'https://api.brevo.com/v3/smtp/email';
  static const String _welcomeSentKey = 'welcome_email_sent';

  /// Sends a branded welcome email via Brevo REST API.
  /// Guards against duplicate sends using SharedPreferences.
  static Future<void> sendWelcome(String name, String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_welcomeSentKey) == true) return;

      final displayName = name.isNotEmpty ? name : 'Coder';

      final response = await http.post(
        Uri.parse(_brevoUrl),
        headers: {
          'api-key': AppConfig.brevoApiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'sender': {
            'name': AppConfig.brevoSenderName,
            'email': AppConfig.brevoSenderEmail,
          },
          'to': [
            {'email': email, 'name': displayName}
          ],
          'subject': 'Welcome to Cody 🚀',
          'htmlContent': '''
<!DOCTYPE html>
<html>
<body style="font-family:sans-serif;background:#0F0F12;color:#FDFDFF;padding:40px;margin:0">
  <div style="max-width:560px;margin:0 auto;background:#1A1A24;border-radius:12px;padding:40px">
    <h1 style="color:#6366F1;font-size:28px;margin-bottom:8px">Welcome to Cody</h1>
    <p style="font-size:16px;color:#94A3B8">Hi <strong style="color:#FDFDFF">$displayName</strong>,</p>
    <p style="font-size:15px;color:#94A3B8;line-height:1.7">
      You're now part of a global arena of competitive programmers.
      Solve problems, earn XP, and climb the leaderboard.
    </p>
    <div style="margin:32px 0;text-align:center">
      <span style="background:#6366F1;color:#fff;padding:14px 32px;border-radius:8px;font-weight:700;font-size:16px">
        Start Coding
      </span>
    </div>
    <p style="font-size:12px;color:#475569;margin-top:32px">
      You're receiving this because you signed up for Cody.
    </p>
  </div>
</body>
</html>
''',
        }),
      );

      if (response.statusCode == 201) {
        await prefs.setBool(_welcomeSentKey, true);
      }
    } catch (_) {
      // Silent fail — email is non-critical
    }
  }
}
