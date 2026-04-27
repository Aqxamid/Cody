import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import 'config/app_config.dart';
import 'theme/cody_theme.dart';
import 'providers/providers.dart';
import 'data/problem_bank.dart';
import 'screens/splash_video_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/problems_list_screen.dart';
import 'screens/problem_detail_screen.dart';
import 'screens/code_editor_screen.dart';
import 'screens/execution_results_screen.dart';
import 'screens/leaderboard_profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  final prefs = await SharedPreferences.getInstance();

  runApp(ProviderScope(
    overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
    child: const CodyApp(),
  ));
}

class CodyApp extends ConsumerWidget {
  const CodyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    ThemeMode mode;
    switch (settings.themeMode) {
      case 'light': mode = ThemeMode.light; break;
      case 'dark': mode = ThemeMode.dark; break;
      default: mode = ThemeMode.system;
    }

    return MaterialApp(
      title: 'Cody',
      debugShowCheckedModeBanner: false,
      theme: CodyTheme.light,
      darkTheme: CodyTheme.dark,
      themeMode: mode,
      home: const _AppRouter(),
    );
  }
}

// ── App router handles splash → onboarding → auth → main ──────────────────────
class _AppRouter extends ConsumerStatefulWidget {
  const _AppRouter();
  @override
  ConsumerState<_AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends ConsumerState<_AppRouter> {
  _Route _route = _Route.loading;

  @override
  void initState() {
    super.initState();
    _determineRoute();
  }

  Future<void> _determineRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final splashShown = prefs.getBool('splash_shown') ?? false;
    if (!mounted) return;
    if (!splashShown) {
      setState(() => _route = _Route.splash);
    } else {
      _afterSplash();
    }
  }

  void _afterSplash() {
    final prefs = ref.read(sharedPrefsProvider);
    final onboardingDone = prefs.getBool('onboarding_completed') ?? false;
    if (!onboardingDone) {
      setState(() => _route = _Route.onboarding);
    } else {
      _afterOnboarding();
    }
  }

  void _afterOnboarding() {
    final authState = ref.read(authProvider);
    if (authState.isAuthenticated) {
      // Load Supabase data for existing authenticated session (e.g. app restart)
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        ref.read(userProvider.notifier).loadFromSupabase(user.id);
      }
      setState(() => _route = _Route.main);
    } else {
      setState(() => _route = _Route.auth);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Reactively listen to auth state changes so that Google OAuth deep-link
    // callbacks (which fire onAuthStateChange) automatically navigate the app.
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isAuthenticated && _route == _Route.auth) {
        // Google OAuth or any external auth callback landed — load data & go home
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) {
          ref.read(userProvider.notifier).loadFromSupabase(user.id);
        }
        setState(() => _route = _Route.main);
      } else if (!next.isAuthenticated && _route == _Route.main) {
        // Signed out from settings — go back to auth
        setState(() => _route = _Route.auth);
      }
    });

    return switch (_route) {
      _Route.loading => const Scaffold(
          backgroundColor: Color(0xFF0F0F12),
          body: Center(child: CircularProgressIndicator()),
        ),
      _Route.splash => SplashVideoScreen(onFinished: () {
          setState(() => _route = _Route.onboarding);
          // Mark splash as shown inside the screen already
        }),
      _Route.onboarding => OnboardingScreen(
          onFinished: () {
            ref.read(onboardingProvider.notifier).completeOnboarding();
            _afterOnboarding();
          },
        ),
      _Route.auth => AuthScreen(
          onAuthenticated: () {
            // Email/password sign-in — sync profile then navigate
            final user = Supabase.instance.client.auth.currentUser;
            if (user != null) {
              ref.read(userProvider.notifier).loadFromSupabase(user.id);
            }
            setState(() => _route = _Route.main);
          },
          onGuest: () => setState(() => _route = _Route.main),
        ),
      _Route.main => const MainNavigator(),
    };
  }
}

enum _Route { loading, splash, onboarding, auth, main }

// ── Main Navigator ─────────────────────────────────────────────────────────────
enum _Screen { dashboard, problemsList, problemDetail, editor, results, leaderboard, profile }

class MainNavigator extends ConsumerStatefulWidget {
  const MainNavigator({super.key});
  @override
  ConsumerState<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends ConsumerState<MainNavigator> {
  _Screen _screen = _Screen.dashboard;
  String _currentProblemId = 'two_sum';

  void _goTo(_Screen s) => setState(() => _screen = s);

  void _onProblemSelected(String id) {
    setState(() { _currentProblemId = id; _screen = _Screen.problemDetail; });
  }

  void _onNavigate(int index) {
    setState(() {
      switch (index) {
        case 0: _screen = _Screen.dashboard; break;
        case 1: _screen = _Screen.problemsList; break;
        case 2: _screen = _Screen.leaderboard; break;
        case 3: _screen = _Screen.profile; break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return switch (_screen) {
      _Screen.dashboard => DashboardScreen(onNavigate: _onNavigate, onProblemSelected: _onProblemSelected),
      _Screen.problemsList => ProblemsListScreen(onNavigate: _onNavigate, onProblemSelected: _onProblemSelected),
      _Screen.problemDetail => ProblemDetailScreen(problemId: _currentProblemId, onNavigate: _onNavigate, onStartCoding: () => _goTo(_Screen.editor), onBack: () => _goTo(_Screen.problemsList)),
      _Screen.editor => CodeEditorScreen(onNavigate: _onNavigate, onRunComplete: () => _goTo(_Screen.results), onBack: () => _goTo(_Screen.problemDetail)),
      _Screen.results => ExecutionResultsScreen(onNavigate: _onNavigate, onSubmit: () => _goTo(_Screen.dashboard), onRetry: () => _goTo(_Screen.editor)),
      _Screen.leaderboard => LeaderboardScreen(onNavigate: _onNavigate),
      _Screen.profile => ProfileScreen(onNavigate: _onNavigate),
    };
  }
}
