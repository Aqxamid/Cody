import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/settings_dialog.dart';
import '../providers/providers.dart';
import '../data/problem_bank.dart';
import '../models/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── Leaderboard ────────────────────────────────────────────────────────────────
class LeaderboardScreen extends ConsumerWidget {
  final ValueChanged<int> onNavigate;
  const LeaderboardScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('Leaderboard', style: GoogleFonts.spaceGrotesk(color: Theme.of(context).colorScheme.primary, fontSize: 20, fontWeight: FontWeight.w900)),
        actions: [
          IconButton(icon: Icon(Icons.settings, color: Theme.of(context).colorScheme.primary), onPressed: () => showSettingsModal(context)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(leaderboardProvider);
          final authId = Supabase.instance.client.auth.currentUser?.id;
          if (authId != null) {
            await ref.read(userProvider.notifier).loadFromSupabase(authId);
          }
        },
        child: Column(children: [
          // User's own rank banner
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1),
            child: Row(children: [
              Text('#${user.globalRank}', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.primary)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Your Ranking', style: GoogleFonts.inter(fontSize: 10, letterSpacing: 1.5, color: Theme.of(context).colorScheme.outline)),
                Text(user.username, style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('${user.xp} XP', style: GoogleFonts.firaMono(fontSize: 13, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.tertiary)),
                Text('${user.solvedProblemIds.length} solved', style: GoogleFonts.inter(fontSize: 11, color: Theme.of(context).colorScheme.outline)),
              ]),
            ]),
          ),
          Expanded(
            child: leaderboardAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.cloud_off, color: Theme.of(context).colorScheme.outline, size: 48),
                  const SizedBox(height: 12),
                  Text('Could not load leaderboard',
                      style: GoogleFonts.inter(color: Theme.of(context).colorScheme.outline, fontSize: 14)),
                  const SizedBox(height: 8),
                  TextButton(onPressed: () => ref.refresh(leaderboardProvider), child: const Text('Retry')),
                ]),
              ),
              data: (entries) => entries.isEmpty
                  ? Center(child: Text('No rankings yet. Be the first!',
                      style: GoogleFonts.inter(color: Theme.of(context).colorScheme.outline, fontSize: 14)))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                      itemCount: entries.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (ctx, i) {
                        final e = entries[i];
                        final isCurrentUser = e.username == user.username;
                        final effectiveAvatarUrl = e.avatarUrl;
                            
                        final rankColors = [
                          Theme.of(context).colorScheme.tertiary,
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.error
                        ];
                        final rankColorValue = e.rank <= 3 ? rankColors[e.rank - 1] : Theme.of(context).colorScheme.outline;
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isCurrentUser
                                ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1)
                                : Theme.of(context).colorScheme.surfaceContainerLow,
                            border: isCurrentUser ? Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)) : null,
                          ),
                          child: Row(children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 36, height: 36,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(4),
                                    image: effectiveAvatarUrl != null ? DecorationImage(image: NetworkImage(effectiveAvatarUrl), fit: BoxFit.cover) : null,
                                  ),
                                  alignment: Alignment.center,
                                  child: effectiveAvatarUrl == null
                                      ? Text(
                                          e.username.isNotEmpty ? e.username.substring(0, e.username.length.clamp(0, 2)).toUpperCase() : '?',
                                          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 14, color: Theme.of(context).colorScheme.onPrimaryContainer),
                                        )
                                      : null,
                                ),
                                Positioned(
                                  bottom: -6,
                                  right: -6,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surface,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: rankColorValue, width: 1.5),
                                    ),
                                    child: Text('#${e.rank}', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 9, color: rankColorValue)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(children: [
                                Text(e.username, style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700, fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
                                if (isCurrentUser) ...[
                                  const SizedBox(width: 8),
                                  Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                                    child: Text('YOU', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1, color: Theme.of(context).colorScheme.primary))),
                                ],
                              ]),
                              Text('${e.solved} solved', style: GoogleFonts.inter(fontSize: 11, color: Theme.of(context).colorScheme.outline)),
                            ])),
                            Text('${e.xp} XP', style: GoogleFonts.firaMono(fontSize: 13, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.tertiary)),
                          ]),
                        );
                      },
                    ),
            ),
          ),
        ]),
      ),
      bottomNavigationBar: CodyBottomNav(currentIndex: 2, onTap: onNavigate),
    );
  }
}

// ── Profile ────────────────────────────────────────────────────────────────────
class ProfileScreen extends ConsumerWidget {
  final ValueChanged<int> onNavigate;
  const ProfileScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('Profile', style: GoogleFonts.spaceGrotesk(color: Theme.of(context).colorScheme.primary, fontSize: 20, fontWeight: FontWeight.w900)),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
            onPressed: () => _showEditUsername(context, ref, user.username),
          ),
          IconButton(
            icon: Icon(Icons.settings, color: Theme.of(context).colorScheme.primary),
            onPressed: () => showSettingsModal(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final authId = Supabase.instance.client.auth.currentUser?.id;
          if (authId != null) {
            await ref.read(userProvider.notifier).loadFromSupabase(authId);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          child: Column(children: [
          // Avatar + info
          _buildProfileHeader(context, user),
          const SizedBox(height: 16),
          // Stats row
          _buildStatsRow(context, user),
          const SizedBox(height: 16),
          // XP Progress
          _buildXpCard(context, user),
          const SizedBox(height: 16),
          // Badges
          if (user.badges.isNotEmpty) ...[_buildBadges(context, user.badges), const SizedBox(height: 16)],
          // Solved problems
          _buildSolvedProblems(context, user),
        ]),
      ),
    ),
    bottomNavigationBar: CodyBottomNav(currentIndex: 3, onTap: onNavigate),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserProfile user) {
    final authUser = Supabase.instance.client.auth.currentUser;
    final avatarUrl = authUser?.userMetadata?['avatar_url'] as String?;

    return Container(
      padding: const EdgeInsets.all(20),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Row(children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer, 
            borderRadius: BorderRadius.circular(4),
            image: avatarUrl != null ? DecorationImage(image: NetworkImage(avatarUrl), fit: BoxFit.cover) : null,
          ),
          alignment: Alignment.center,
          child: avatarUrl == null
            ? Text(
                user.username.isNotEmpty ? user.username.substring(0, user.username.length.clamp(0, 2)).toUpperCase() : '?',
                style: GoogleFonts.spaceGrotesk(fontSize: 26, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onPrimaryContainer),
              )
            : null,
        ),
        const SizedBox(width: 20),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(user.username, style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 4),
          Text('LEVEL ${user.level}  •  #${user.globalRank} Global', style: GoogleFonts.inter(fontSize: 12, color: Theme.of(context).colorScheme.outline)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1),
            child: Text('${user.streak} DAY STREAK', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1, color: Theme.of(context).colorScheme.tertiary)),
          ),
        ])),
      ]),
    );
  }

  Widget _buildStatsRow(BuildContext context, UserProfile user) {
    return Row(children: [
      _StatBox(value: '${user.solvedProblemIds.length}', label: 'Solved'),
      const SizedBox(width: 12),
      _StatBox(value: '${user.xp}', label: 'XP Total'),
      const SizedBox(width: 12),
      _StatBox(value: '${user.streak}', label: 'Streak'),
    ]);
  }

  Widget _buildXpCard(BuildContext context, UserProfile user) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('LEVEL ${user.level}', style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.primary)),
          Text('LEVEL ${user.level + 1}', style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.outline)),
        ]),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: user.levelProgress, backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest, valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.tertiary), minHeight: 6),
        const SizedBox(height: 8),
        Text('${user.xp} / ${user.xpForNextLevel} XP', style: GoogleFonts.firaMono(fontSize: 11, color: Theme.of(context).colorScheme.outline)),
      ]),
    );
  }

  Widget _buildBadges(BuildContext context, List<String> badges) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('BADGES', style: GoogleFonts.inter(fontSize: 10, letterSpacing: 2, color: Theme.of(context).colorScheme.outline)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: badges.map((b) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.15), border: Border.all(color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)), borderRadius: BorderRadius.circular(2)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.military_tech, color: Theme.of(context).colorScheme.primary, size: 14),
              const SizedBox(width: 6),
              Text(b, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary)),
            ]),
          )).toList(),
        ),
      ]),
    );
  }

  Widget _buildSolvedProblems(BuildContext context, UserProfile user) {
    final solved = ProblemBank.problems.where((p) => user.solvedProblemIds.contains(p.id)).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('SOLVED PROBLEMS', style: GoogleFonts.inter(fontSize: 10, letterSpacing: 2, color: Theme.of(context).colorScheme.outline)),
        const SizedBox(height: 12),
        if (solved.isEmpty)
          Text('No problems solved yet. Start coding!', style: GoogleFonts.inter(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant))
        else
          ...solved.map((p) {
            final diffColor = p.difficulty == Difficulty.easy ? Theme.of(context).colorScheme.tertiary : p.difficulty == Difficulty.medium ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  Icon(Icons.check_circle, color: Theme.of(context).colorScheme.tertiary, size: 16),
                  const SizedBox(width: 10),
                  Text(p.title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
                ]),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  color: diffColor.withValues(alpha: 0.1),
                  child: Text(p.difficulty.name.toUpperCase(), style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1, color: diffColor)),
                ),
              ]),
            );
          }),
      ]),
    );
  }

  void _showEditUsername(BuildContext context, WidgetRef ref, String current) {
    final ctrl = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        title: Text('Edit Username', style: GoogleFonts.spaceGrotesk(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: ctrl,
          style: GoogleFonts.inter(color: Theme.of(context).colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: 'Enter username',
            hintStyle: GoogleFonts.inter(color: Theme.of(context).colorScheme.outline),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(2), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('CANCEL', style: GoogleFonts.inter(color: Theme.of(context).colorScheme.outline))),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                ref.read(userProvider.notifier).updateUsername(ctrl.text.trim());
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Theme.of(context).colorScheme.onPrimary, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(2)))),
            child: Text('SAVE', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  const _StatBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        child: Column(children: [
          Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.inter(fontSize: 10, letterSpacing: 1, color: Theme.of(context).colorScheme.outline)),
        ]),
      ),
    );
  }
}
