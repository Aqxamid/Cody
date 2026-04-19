import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme/cody_theme.dart';
import 'providers/providers.dart';
import 'data/problem_bank.dart';
import 'screens/dashboard_screen.dart';
import 'screens/problems_list_screen.dart';
import 'screens/problem_detail_screen.dart';
import 'screens/code_editor_screen.dart';
import 'screens/execution_results_screen.dart';
import 'screens/leaderboard_profile_screen.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      case 'light':
        mode = ThemeMode.light;
        break;
      case 'dark':
        mode = ThemeMode.dark;
        break;
      default:
        mode = ThemeMode.system;
    }

    final onboardingCompleted = ref.watch(onboardingProvider);

    return MaterialApp(
      title: 'Cody',
      debugShowCheckedModeBanner: false,
      theme: CodyTheme.light,
      darkTheme: CodyTheme.dark,
      themeMode: mode,
      home: onboardingCompleted 
          ? const MainNavigator() 
          : OnboardingScreen(onFinished: () => ref.read(onboardingProvider.notifier).completeOnboarding()),
    );
  }
}

enum _Screen {
  dashboard,
  problemsList,
  problemDetail,
  editor,
  results,
  leaderboard,
  profile
}

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
    setState(() {
      _currentProblemId = id;
      _screen = _Screen.problemDetail;
    });
  }

  void _onNavigate(int index) {
    setState(() {
      switch (index) {
        case 0:
          _screen = _Screen.dashboard;
          break;
        case 1:
          _screen = _Screen.problemsList;
          break;
        case 2:
          _screen = _Screen.leaderboard;
          break;
        case 3:
          _screen = _Screen.profile;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_screen) {
      case _Screen.dashboard:
        return DashboardScreen(
          onNavigate: _onNavigate,
          onProblemSelected: _onProblemSelected,
        );
      case _Screen.problemsList:
        return ProblemsListScreen(
          onNavigate: _onNavigate,
          onProblemSelected: _onProblemSelected,
        );
      case _Screen.problemDetail:
        return ProblemDetailScreen(
          problemId: _currentProblemId,
          onNavigate: _onNavigate,
          onStartCoding: () => _goTo(_Screen.editor),
        );
      case _Screen.editor:
        return CodeEditorScreen(
          onNavigate: _onNavigate,
          onRunComplete: () => _goTo(_Screen.results),
        );
      case _Screen.results:
        return ExecutionResultsScreen(
          onNavigate: _onNavigate,
          onSubmit: () => _goTo(_Screen.dashboard),
          onRetry: () => _goTo(_Screen.editor),
        );
      case _Screen.leaderboard:
        return LeaderboardScreen(
          onNavigate: _onNavigate,
        );
      case _Screen.profile:
        return ProfileScreen(
          onNavigate: _onNavigate,
        );
    }
  }
}
