import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  static final _client = Supabase.instance.client;

  // ── Upsert profile to Supabase ─────────────────────────────────────────────
  static Future<void> upsertProfile({
    required String userId,
    required String username,
    required int xp,
    required int level,
    required int streak,
    required List<String> solvedIds,
    required List<String> badges,
    String? photoUrl,
  }) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      final avatarUrl = photoUrl
          ?? user?.userMetadata?['avatar_url'] as String?;
      await _client.from('profiles').upsert({
        'id': userId,
        'display_name': username,
        if (avatarUrl != null) 'photo_url': avatarUrl,
        'xp': xp,
        'streak': streak,
        'solved_problem_ids': solvedIds,
        'badges': badges,
        'last_active_date': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Supabase Upsert Error: $e');
      // Silent fail — local state is source of truth
    }
  }

  // ── Fetch leaderboard (top 50 by XP) ───────────────────────────────────────
  static Future<List<Map<String, dynamic>>> fetchLeaderboard() async {
    try {
      final data = await _client
          .from('profiles')
          .select('display_name, xp, solved_problem_ids, photo_url')
          .order('xp', ascending: false)
          .limit(50);
      return List<Map<String, dynamic>>.from(data);
    } catch (_) {
      return [];
    }
  }

  // ── Fetch own profile ───────────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> fetchProfile(String userId) async {
    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return data;
    } catch (_) {
      return null;
    }
  }

  // ── Fetch global rank ───────────────────────────────────────────────────────
  static Future<int> fetchGlobalRank(int userXp) async {
    try {
      final response = await _client
          .from('profiles')
          .select('id')
          .gt('xp', userXp)
          .count(CountOption.exact);
      return response.count + 1;
    } catch (_) {
      return 1204;
    }
  }
}
