import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../data/problem_bank.dart';
import '../services/profile_service.dart';

// ── Shared Preferences instance ────────────────────────────────────────────────
final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize with override in main()');
});

// ── Auth State Provider ─────────────────────────────────────────────────────────
enum AuthStatus { guest, authenticated }

class AuthState {
  final AuthStatus status;
  final User? user;
  const AuthState({this.status = AuthStatus.guest, this.user});
  bool get isAuthenticated => status == AuthStatus.authenticated;
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _init();
  }

  void _init() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      state = AuthState(status: AuthStatus.authenticated, user: user);
    }
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final u = data.session?.user;
      state = u != null
          ? AuthState(status: AuthStatus.authenticated, user: u)
          : const AuthState(status: AuthStatus.guest);
    });
  }

  void setGuest() => state = const AuthState(status: AuthStatus.guest);

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    state = const AuthState(status: AuthStatus.guest);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// ── Settings State ─────────────────────────────────────────────────────────────
class SettingsState {
  final String themeMode;
  final bool soundEffects;
  const SettingsState({this.themeMode = 'system', this.soundEffects = true});
  SettingsState copyWith({String? themeMode, bool? soundEffects}) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      soundEffects: soundEffects ?? this.soundEffects,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final SharedPreferences _prefs;
  SettingsNotifier(this._prefs) : super(const SettingsState()) { _load(); }

  void _load() {
    final themeMode = _prefs.getString('theme_mode') ?? 'system';
    final soundEffects = _prefs.getBool('sound_effects') ?? true;
    state = SettingsState(themeMode: themeMode, soundEffects: soundEffects);
  }

  void setThemeMode(String mode) {
    state = state.copyWith(themeMode: mode);
    _prefs.setString('theme_mode', mode);
  }

  void toggleSound(bool value) {
    state = state.copyWith(soundEffects: value);
    _prefs.setBool('sound_effects', value);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return SettingsNotifier(prefs);
});

// ── User Profile Provider ──────────────────────────────────────────────────────
class UserNotifier extends StateNotifier<UserProfile> {
  final SharedPreferences _prefs;

  UserNotifier(this._prefs)
      : super(UserProfile(
          username: 'CodeNinja42',
          xp: 0, level: 1, globalRank: 1204, streak: 0,
          solvedProblemIds: {}, badges: [],
        )) {
    _load();
  }

  void _load() {
    final xp = _prefs.getInt('user_xp') ?? 0;
    final streak = _prefs.getInt('user_streak') ?? 0;
    final solved = _prefs.getStringList('solved_ids')?.toSet() ?? {};
    final badges = _prefs.getStringList('badges') ?? [];
    final username = _prefs.getString('username') ?? 'CodeNinja42';
    state = UserProfile(
      username: username, xp: xp, level: _levelFromXp(xp),
      globalRank: 1204, streak: streak,
      solvedProblemIds: solved, badges: badges,
    );
    _refreshRank(xp);
  }

  Future<void> _refreshRank(int currentXp) async {
    final rank = await ProfileService.fetchGlobalRank(currentXp);
    if (rank != state.globalRank) {
      state = state.copyWith(globalRank: rank);
    }
  }

  int _levelFromXp(int xp) => (xp ~/ 500) + 1;

  Future<void> _syncToSupabase() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    await ProfileService.upsertProfile(
      userId: user.id,
      username: state.username,
      xp: state.xp, level: state.level, streak: state.streak,
      solvedIds: state.solvedProblemIds.toList(),
      badges: state.badges,
    );
    _refreshRank(state.xp);
  }

  Future<void> awardXp(int amount, String problemId) async {
    if (state.solvedProblemIds.contains(problemId)) return;
    final newXp = state.xp + amount;
    final newSolved = {...state.solvedProblemIds, problemId};
    final newLevel = _levelFromXp(newXp);
    final newBadges = List<String>.from(state.badges);
    if (state.solvedProblemIds.isEmpty) newBadges.add('First Blood');
    if (newSolved.length == 5) newBadges.add('Problem Crusher');
    final problem = ProblemBank.getById(problemId);
    if (problem?.difficulty == Difficulty.hard && !newBadges.contains('Hard Boiled')) {
      newBadges.add('Hard Boiled');
    }
    state = state.copyWith(xp: newXp, level: newLevel, solvedProblemIds: newSolved, badges: newBadges);
    await _prefs.setInt('user_xp', newXp);
    await _prefs.setStringList('solved_ids', newSolved.toList());
    await _prefs.setStringList('badges', newBadges);
    await _syncToSupabase();
  }

  Future<void> updateStreak() async {
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final lastSolveStr = _prefs.getString('last_solve_date');

    if (lastSolveStr == todayStr) {
      return; // Already incremented today
    }

    int newStreak = 1;
    if (lastSolveStr != null) {
      final lastSolve = DateTime.parse(lastSolveStr);
      final difference = DateTime(now.year, now.month, now.day)
          .difference(DateTime(lastSolve.year, lastSolve.month, lastSolve.day))
          .inDays;

      if (difference == 1) {
        newStreak = state.streak + 1;
      }
    }

    state = state.copyWith(streak: newStreak);
    await _prefs.setInt('user_streak', newStreak);
    await _prefs.setString('last_solve_date', todayStr);
    await _syncToSupabase();
  }

  Future<void> updateUsername(String username) async {
    state = state.copyWith(username: username);
    await _prefs.setString('username', username);
    await _syncToSupabase();
  }

  Future<void> loadFromSupabase(String userId) async {
    final data = await ProfileService.fetchProfile(userId);
    if (data == null) {
      final user = Supabase.instance.client.auth.currentUser;
      final name = user?.userMetadata?['full_name'] ?? user?.userMetadata?['name'] ?? state.username;
      state = state.copyWith(username: name);
      await _prefs.setString('username', name);
      await _syncToSupabase();
      return;
    }
    final xp = (data['xp'] as int?) ?? 0;
    final solved = Set<String>.from((data['solved_problem_ids'] as List<dynamic>?) ?? []);
    final badges = List<String>.from((data['badges'] as List<dynamic>?) ?? []);
    state = UserProfile(
      username: (data['display_name'] as String?) ?? state.username,
      xp: xp, level: _levelFromXp(xp),
      globalRank: state.globalRank,
      streak: (data['streak'] as int?) ?? 0,
      solvedProblemIds: solved, badges: badges,
    );
    await _prefs.setInt('user_xp', xp);
    await _prefs.setInt('user_streak', state.streak);
    await _prefs.setStringList('solved_ids', solved.toList());
    await _prefs.setStringList('badges', badges);
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserProfile>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return UserNotifier(prefs);
});

// ── Code Editor Provider ───────────────────────────────────────────────────────
class EditorState {
  final String problemId;
  final String language;
  final String code;
  final bool isRunning;
  const EditorState({required this.problemId, required this.language, required this.code, this.isRunning = false});
  EditorState copyWith({String? problemId, String? language, String? code, bool? isRunning}) {
    return EditorState(
      problemId: problemId ?? this.problemId, language: language ?? this.language,
      code: code ?? this.code, isRunning: isRunning ?? this.isRunning,
    );
  }
}

class EditorNotifier extends StateNotifier<EditorState> {
  final SharedPreferences _prefs;
  EditorNotifier(this._prefs) : super(EditorState(
    problemId: _prefs.getString('last_problem_id') ?? 'sum_two',
    language: _prefs.getString('last_language') ?? 'Python',
    code: '',
  )) {
    loadProblem(state.problemId, language: state.language);
  }

  void loadProblem(String problemId, {String? language}) {
    final problem = ProblemBank.getById(problemId);
    if (problem == null) return;
    final lang = language ?? state.language;
    _prefs.setString('last_problem_id', problemId);
    _prefs.setString('last_language', lang);
    final savedKey = 'draft_${problemId}_$lang';
    final draft = _prefs.getString(savedKey);
    state = EditorState(problemId: problemId, language: lang,
        code: draft ?? problem.starterCode[lang] ?? '');
  }

  void switchLanguage(String language) {
    final problem = ProblemBank.getById(state.problemId);
    if (problem == null) return;
    _prefs.setString('last_language', language);
    final savedKey = 'draft_${state.problemId}_$language';
    final draft = _prefs.getString(savedKey);
    state = state.copyWith(language: language,
        code: draft ?? problem.starterCode[language] ?? '');
  }

  void updateCode(String code) {
    state = state.copyWith(code: code);
    _prefs.setString('draft_${state.problemId}_${state.language}', code);
  }

  void insertSnippet(String snippet) => updateCode(state.code + snippet);

  void resetToStarter() {
    final problem = ProblemBank.getById(state.problemId);
    if (problem == null) return;
    final starter = problem.starterCode[state.language] ?? '';
    state = state.copyWith(code: starter);
    _prefs.remove('draft_${state.problemId}_${state.language}');
  }

  void setRunning(bool running) => state = state.copyWith(isRunning: running);
}

final editorProvider = StateNotifierProvider<EditorNotifier, EditorState>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return EditorNotifier(prefs);
});

// ── Execution Result Provider ──────────────────────────────────────────────────
final executionResultProvider = StateProvider<ExecutionResult?>((ref) => null);

// ── Selected Problem Provider ──────────────────────────────────────────────────
final selectedProblemIdProvider = StateProvider<String>((ref) => 'two_sum');

// ── Leaderboard Provider (Supabase) ────────────────────────────────────────────
final leaderboardProvider = FutureProvider<List<LeaderboardEntry>>((ref) async {
  try {
    final rows = await ProfileService.fetchLeaderboard();
    return rows.asMap().entries.map((e) {
      final i = e.key;
      final row = e.value;
      final solved = (row['solved_problem_ids'] as List<dynamic>?)?.length ?? 0;
      return LeaderboardEntry(
        rank: i + 1,
        username: (row['display_name'] as String?) ?? 'Unknown',
        avatarUrl: null, // Removed DB dependency
        xp: (row['xp'] as int?) ?? 0,
        solved: solved,
      );
    }).toList();
  } catch (_) {
    // Fallback: return local user
    return [];
  }
});

// ── Onboarding Provider ────────────────────────────────────────────────────────
class OnboardingNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;
  OnboardingNotifier(this._prefs) : super(_prefs.getBool('onboarding_completed') ?? false);

  void completeOnboarding() {
    state = true;
    _prefs.setBool('onboarding_completed', true);
  }

  void resetOnboarding() {
    state = false;
    _prefs.setBool('onboarding_completed', false);
  }
}

final onboardingProvider = StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return OnboardingNotifier(prefs);
});
