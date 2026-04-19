import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../data/problem_bank.dart';

// ── Settings State ─────────────────────────────────────────────────────────────
class SettingsState {
  final String themeMode; // 'system', 'light', 'dark'
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

  SettingsNotifier(this._prefs) : super(const SettingsState()) {
    _load();
  }

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

// ── Shared Preferences instance ────────────────────────────────────────────────
final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize with override in main()');
});

// ── User Profile Provider ──────────────────────────────────────────────────────
class UserNotifier extends StateNotifier<UserProfile> {
  final SharedPreferences _prefs;

  UserNotifier(this._prefs)
      : super(UserProfile(
          username: 'CodeNinja42',
          xp: 0,
          level: 1,
          globalRank: 1204,
          streak: 0,
          solvedProblemIds: {},
          badges: [],
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
      username: username,
      xp: xp,
      level: _levelFromXp(xp),
      globalRank: 1204,
      streak: streak,
      solvedProblemIds: solved,
      badges: badges,
    );
  }

  int _levelFromXp(int xp) => (xp ~/ 500) + 1;

  Future<void> awardXp(int amount, String problemId) async {
    if (state.solvedProblemIds.contains(problemId)) return; // no double XP
    final newXp = state.xp + amount;
    final newSolved = {...state.solvedProblemIds, problemId};
    final newLevel = _levelFromXp(newXp);
    final newBadges = List<String>.from(state.badges);

    // Badge: first solve
    if (state.solvedProblemIds.isEmpty) newBadges.add('First Blood');
    // Badge: 5 solves
    if (newSolved.length == 5) newBadges.add('Problem Crusher');
    // Badge: solved a hard
    final problem = ProblemBank.getById(problemId);
    if (problem?.difficulty == Difficulty.hard && !newBadges.contains('Hard Boiled')) {
      newBadges.add('Hard Boiled');
    }

    state = state.copyWith(
      xp: newXp,
      level: newLevel,
      solvedProblemIds: newSolved,
      badges: newBadges,
    );

    await _prefs.setInt('user_xp', newXp);
    await _prefs.setStringList('solved_ids', newSolved.toList());
    await _prefs.setStringList('badges', newBadges);
  }

  Future<void> incrementStreak() async {
    final newStreak = state.streak + 1;
    state = state.copyWith(streak: newStreak);
    await _prefs.setInt('user_streak', newStreak);
  }

  Future<void> updateUsername(String username) async {
    state = state.copyWith(username: username);
    await _prefs.setString('username', username);
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

  const EditorState({
    required this.problemId,
    required this.language,
    required this.code,
    this.isRunning = false,
  });

  EditorState copyWith({
    String? problemId,
    String? language,
    String? code,
    bool? isRunning,
  }) {
    return EditorState(
      problemId: problemId ?? this.problemId,
      language: language ?? this.language,
      code: code ?? this.code,
      isRunning: isRunning ?? this.isRunning,
    );
  }
}

class EditorNotifier extends StateNotifier<EditorState> {
  final SharedPreferences _prefs;

  EditorNotifier(this._prefs)
      : super(EditorState(
          problemId: _prefs.getString('last_problem_id') ?? 'sum_two',
          language: _prefs.getString('last_language') ?? 'Python',
          code: '', // will be loaded in loadProblem or switchLanguage
        )) {
    loadProblem(state.problemId, language: state.language);
  }

  void loadProblem(String problemId, {String? language}) {
    final problem = ProblemBank.getById(problemId);
    if (problem == null) return;
    final lang = language ?? state.language;
    // Save as last problem
    _prefs.setString('last_problem_id', problemId);
    _prefs.setString('last_language', lang);
    
    // Load saved draft or starter code
    final savedKey = 'draft_${problemId}_$lang';
    final draft = _prefs.getString(savedKey);
    state = EditorState(
      problemId: problemId,
      language: lang,
      code: draft ?? problem.starterCode[lang] ?? '',
    );
  }

  void switchLanguage(String language) {
    final problem = ProblemBank.getById(state.problemId);
    if (problem == null) return;
    _prefs.setString('last_language', language);
    final savedKey = 'draft_${state.problemId}_$language';
    final draft = _prefs.getString(savedKey);
    state = state.copyWith(
      language: language,
      code: draft ?? problem.starterCode[language] ?? '',
    );
  }

  void updateCode(String code) {
    state = state.copyWith(code: code);
    // Autosave draft
    final key = 'draft_${state.problemId}_${state.language}';
    _prefs.setString(key, code);
  }

  void insertSnippet(String snippet) {
    // Appends snippet at end for simplicity (a real editor would insert at cursor)
    final newCode = state.code + snippet;
    updateCode(newCode);
  }

  void resetToStarter() {
    final problem = ProblemBank.getById(state.problemId);
    if (problem == null) return;
    final starter = problem.starterCode[state.language] ?? '';
    state = state.copyWith(code: starter);
    final key = 'draft_${state.problemId}_${state.language}';
    _prefs.remove(key);
  }

  void setRunning(bool running) {
    state = state.copyWith(isRunning: running);
  }
}

final editorProvider = StateNotifierProvider<EditorNotifier, EditorState>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return EditorNotifier(prefs);
});

// ── Execution Result Provider ──────────────────────────────────────────────────
final executionResultProvider = StateProvider<ExecutionResult?>((ref) => null);

// ── Selected Problem Provider ──────────────────────────────────────────────────
final selectedProblemIdProvider = StateProvider<String>((ref) => 'two_sum');

// ── Leaderboard Provider ────────────────────────────────────────────────────────
final leaderboardProvider = Provider<List<LeaderboardEntry>>((ref) {
  final user = ref.watch(userProvider);
  final entries = [
    LeaderboardEntry(rank: user.globalRank, username: user.username, xp: user.xp, solved: user.solvedProblemIds.length),
  ]..sort((a, b) => b.xp.compareTo(a.xp));
  return entries;
});

// ── Onboarding Provider ────────────────────────────────────────────────────────
class OnboardingNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;
  OnboardingNotifier(this._prefs)
      : super(_prefs.getBool('onboarding_completed') ?? false);

  void completeOnboarding() {
    state = true;
    _prefs.setBool('onboarding_completed', true);
  }

  void resetOnboarding() {
    state = false;
    _prefs.setBool('onboarding_completed', false);
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return OnboardingNotifier(prefs);
});
