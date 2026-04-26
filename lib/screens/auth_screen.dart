import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

enum _AuthMode { login, signup, forgotPassword }

class AuthScreen extends StatefulWidget {
  final VoidCallback onAuthenticated;
  final VoidCallback onGuest;
  const AuthScreen({super.key, required this.onAuthenticated, required this.onGuest});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  _AuthMode _mode = _AuthMode.login;
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;
  String? _success;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _usernameCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleGoogle() async {
    setState(() { _loading = true; _error = null; });
    final ok = await AuthService.signInWithGoogle();
    if (!ok && mounted) {
      setState(() {
        _error = 'Google Sign-In is not configured yet.\nConfigure OAuth in your Supabase dashboard.';
        _loading = false;
      });
    }
    // On success Supabase deep-link callback triggers — no action needed here
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _handleEmailAction() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final username = _usernameCtrl.text.trim();
    setState(() { _loading = true; _error = null; _success = null; });

    if (_mode == _AuthMode.forgotPassword) {
      final err = await AuthService.resetPassword(email);
      if (mounted) {
        setState(() {
          _loading = false;
          if (err != null) _error = err;
          else _success = 'Password reset link sent! Check your email (via Brevo).';
        });
      }
      return;
    }

    final err = _mode == _AuthMode.signup
        ? await AuthService.signUp(email, password, username)
        : await AuthService.signIn(email, password);

    if (mounted) {
      if (err != null) {
        setState(() { _error = err; _loading = false; });
      } else {
        setState(() => _loading = false);
        if (_mode == _AuthMode.signup) {
          setState(() => _success = 'Check your email to verify your account!');
        } else {
          widget.onAuthenticated();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // Logo
              Center(
                child: Column(children: [
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: cs.primary.withValues(alpha: 0.3), blurRadius: 24)],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset('assets/app_icon.png', fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('CODY', style: GoogleFonts.spaceGrotesk(fontSize: 32, fontWeight: FontWeight.w900, color: cs.primary, letterSpacing: 4)),
                  const SizedBox(height: 4),
                  Text(_modeTitle, style: GoogleFonts.inter(fontSize: 14, color: cs.outline)),
                ]),
              ),
              const SizedBox(height: 40),

              // Google Sign-In
              if (_mode != _AuthMode.forgotPassword) ...[
                _GoogleButton(loading: _loading, onTap: _handleGoogle),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(child: Divider(color: cs.outlineVariant)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('OR', style: GoogleFonts.inter(fontSize: 11, color: cs.outline, letterSpacing: 1.5)),
                  ),
                  Expanded(child: Divider(color: cs.outlineVariant)),
                ]),
                const SizedBox(height: 20),
              ],

              // Username field (sign up only)
              if (_mode == _AuthMode.signup) ...[
                _field('Username', _usernameCtrl, false, cs, icon: Icons.person_outline),
                const SizedBox(height: 12),
              ],

              // Email
              _field('Email', _emailCtrl, false, cs, icon: Icons.email_outlined, type: TextInputType.emailAddress),
              const SizedBox(height: 12),

              // Password
              if (_mode != _AuthMode.forgotPassword) ...[
                _field('Password', _passwordCtrl, _obscure, cs,
                  icon: Icons.lock_outline,
                  suffix: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18, color: cs.outline),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Error / success
              if (_error != null) _message(_error!, cs.error, Icons.error_outline),
              if (_success != null) _message(_success!, cs.tertiary, Icons.check_circle_outline),

              // Forgot password link
              if (_mode == _AuthMode.login)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => setState(() { _mode = _AuthMode.forgotPassword; _error = null; _success = null; }),
                    child: Text('Forgot Password?', style: GoogleFonts.inter(fontSize: 13, color: cs.primary)),
                  ),
                ),

              const SizedBox(height: 8),

              // Main action button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _handleEmailAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: _loading
                      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: cs.onPrimary, strokeWidth: 2))
                      : Text(_modeAction, style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: 0.5)),
                ),
              ),
              const SizedBox(height: 16),

              // Toggle mode
              Center(child: _toggleRow(cs)),
              const SizedBox(height: 24),

              // Guest
              Center(
                child: TextButton(
                  onPressed: widget.onGuest,
                  child: Text(
                    'Continue as Guest',
                    style: GoogleFonts.inter(fontSize: 13, color: cs.outline, decoration: TextDecoration.underline),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _modeTitle => switch (_mode) {
    _AuthMode.login => 'Sign in to your account',
    _AuthMode.signup => 'Create your account',
    _AuthMode.forgotPassword => 'Reset your password',
  };

  String get _modeAction => switch (_mode) {
    _AuthMode.login => 'LOG IN',
    _AuthMode.signup => 'CREATE ACCOUNT',
    _AuthMode.forgotPassword => 'SEND RESET LINK',
  };

  Widget _field(String label, TextEditingController ctrl, bool obscure, ColorScheme cs,
      {IconData? icon, Widget? suffix, TextInputType? type}) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: type,
      style: GoogleFonts.inter(color: cs.onSurface, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: cs.outline, fontSize: 13),
        prefixIcon: icon != null ? Icon(icon, size: 18, color: cs.outline) : null,
        suffixIcon: suffix,
        filled: true,
        fillColor: cs.surfaceContainerLow,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: cs.primary, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _message(String msg, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(msg, style: GoogleFonts.inter(fontSize: 12, color: color))),
      ]),
    );
  }

  Widget _toggleRow(ColorScheme cs) {
    if (_mode == _AuthMode.forgotPassword) {
      return TextButton(
        onPressed: () => setState(() { _mode = _AuthMode.login; _error = null; _success = null; }),
        child: Text('Back to Log In', style: GoogleFonts.inter(fontSize: 13, color: cs.primary)),
      );
    }
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(
        _mode == _AuthMode.login ? "Don't have an account? " : 'Already have an account? ',
        style: GoogleFonts.inter(fontSize: 13, color: cs.outline),
      ),
      TextButton(
        onPressed: () => setState(() {
          _mode = _mode == _AuthMode.login ? _AuthMode.signup : _AuthMode.login;
          _error = null; _success = null;
        }),
        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
        child: Text(
          _mode == _AuthMode.login ? 'Sign Up' : 'Log In',
          style: GoogleFonts.inter(fontSize: 13, color: cs.primary, fontWeight: FontWeight.w700),
        ),
      ),
    ]);
  }
}

class _GoogleButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;
  const _GoogleButton({required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: loading ? null : onTap,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          side: BorderSide(color: cs.outlineVariant),
          backgroundColor: cs.surfaceContainerLow,
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          // Google G logo colours via icon
          const Text('G', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF4285F4))),
          const SizedBox(width: 10),
          Text('Continue with Google', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface)),
        ]),
      ),
    );
  }
}
