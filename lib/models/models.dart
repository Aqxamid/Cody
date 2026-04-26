// ── Problem model ──────────────────────────────────────────────────────────────
enum Difficulty { easy, medium, hard }

class ProblemExample {
  final String input;
  final String output;
  final String? explanation;
  const ProblemExample({required this.input, required this.output, this.explanation});
}

class TestCase {
  final String input;
  final String expectedOutput;
  final bool isHidden;
  const TestCase({required this.input, required this.expectedOutput, this.isHidden = false});
}

class Problem {
  final String id;
  final String title;
  final String description;
  final Difficulty difficulty;
  final List<String> tags;
  final List<ProblemExample> examples;
  final List<TestCase> testCases;
  final String constraints;
  final String? followUp;
  final int xpReward;
  final String functionName;
  final Map<String, String> starterCode; // language -> starter code

  const Problem({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.tags,
    required this.examples,
    required this.testCases,
    required this.constraints,
    this.followUp,
    required this.xpReward,
    required this.functionName,
    required this.starterCode,
  });
}

// ── Submission / execution result model ────────────────────────────────────────
enum SubmissionStatus { passed, failed, error, pending }

class TestResult {
  final String caseLabel;
  final String input;
  final String expectedOutput;
  final String? actualOutput;
  final bool passed;
  final String? errorMessage;
  const TestResult({
    required this.caseLabel,
    required this.input,
    required this.expectedOutput,
    this.actualOutput,
    required this.passed,
    this.errorMessage,
  });
}

class ExecutionResult {
  final SubmissionStatus status;
  final int passedCount;
  final int totalCount;
  final int runtimeMs;
  final double memoryMb;
  final String stdout;
  final String stderr;
  final List<TestResult> testResults;
  final int xpEarned;

  const ExecutionResult({
    required this.status,
    required this.passedCount,
    required this.totalCount,
    required this.runtimeMs,
    required this.memoryMb,
    required this.stdout,
    required this.stderr,
    required this.testResults,
    required this.xpEarned,
  });
}

// ── User / progression model ────────────────────────────────────────────────────
class UserProfile {
  final String username;
  final int xp;
  final int level;
  final int globalRank;
  final int streak;
  final Set<String> solvedProblemIds;
  final List<String> badges;

  const UserProfile({
    required this.username,
    required this.xp,
    required this.level,
    required this.globalRank,
    required this.streak,
    required this.solvedProblemIds,
    required this.badges,
  });

  int get xpForCurrentLevel => (level - 1) * 500;
  int get xpForNextLevel => level * 500;
  double get levelProgress {
    final base = xpForCurrentLevel;
    final next = xpForNextLevel;
    return ((xp - base) / (next - base)).clamp(0.0, 1.0);
  }

  UserProfile copyWith({
    String? username,
    int? xp,
    int? level,
    int? globalRank,
    int? streak,
    Set<String>? solvedProblemIds,
    List<String>? badges,
  }) {
    return UserProfile(
      username: username ?? this.username,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      globalRank: globalRank ?? this.globalRank,
      streak: streak ?? this.streak,
      solvedProblemIds: solvedProblemIds ?? this.solvedProblemIds,
      badges: badges ?? this.badges,
    );
  }
}

// ── Leaderboard entry ───────────────────────────────────────────────────────────
class LeaderboardEntry {
  final int rank;
  final String username;
  final String? avatarUrl;
  final int xp;
  final int solved;
  const LeaderboardEntry({required this.rank, required this.username, this.avatarUrl, required this.xp, required this.solved});
}
