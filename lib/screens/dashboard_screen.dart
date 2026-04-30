import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/settings_dialog.dart';
import '../providers/providers.dart';
import '../data/problem_bank.dart';
import '../models/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardScreen extends ConsumerWidget {
  final ValueChanged<int> onNavigate;
  final ValueChanged<String> onProblemSelected;
  final VoidCallback? onAdminTap;

  const DashboardScreen({super.key, required this.onNavigate, required this.onProblemSelected, this.onAdminTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final daily = ProblemBank.dailyChallenge;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('Cody', style: GoogleFonts.spaceGrotesk(color: Theme.of(context).colorScheme.primary, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        actions: [
          if (user.role == 'admin')
            IconButton(
              icon: Icon(Icons.add_box_outlined, color: Theme.of(context).colorScheme.tertiary),
              onPressed: onAdminTap,
              tooltip: 'Admin Builder',
            ),
          IconButton(icon: Icon(Icons.settings, color: Theme.of(context).colorScheme.primary), onPressed: () => showSettingsModal(context)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ProblemBank.loadFromSupabase();
          final authId = Supabase.instance.client.auth.currentUser?.id;
          if (authId != null) {
            await ref.read(userProvider.notifier).loadFromSupabase(authId);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLevelSection(context, user),
              const SizedBox(height: 16),
              _buildXpProgress(context, user),
              const SizedBox(height: 24),
              _buildDailyChallenge(context, daily),
              const SizedBox(height: 24),
              _buildStatsGrid(context, user),
              const SizedBox(height: 32),
              _buildRecommended(context, user),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CodyBottomNav(currentIndex: 0, onTap: onNavigate),
    );
  }

  Widget _buildLevelSection(BuildContext context, UserProfile user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('CURRENT LEVEL', style: GoogleFonts.inter(fontSize: 10, letterSpacing: 2, color: Theme.of(context).colorScheme.outline)),
          const SizedBox(height: 4),
          Text('LEVEL ${user.level}', style: GoogleFonts.spaceGrotesk(fontSize: 32, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.primary, fontStyle: FontStyle.italic)),
        ]),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('GLOBAL RANK', style: GoogleFonts.inter(fontSize: 10, letterSpacing: 2, color: Theme.of(context).colorScheme.outline)),
          const SizedBox(height: 4),
          Text('#${user.globalRank}', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
        ]),
      ],
    );
  }

  Widget _buildXpProgress(BuildContext context, UserProfile user) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${user.xp} XP', style: GoogleFonts.firaMono(fontSize: 12, color: Theme.of(context).colorScheme.tertiary)),
          Text('${user.xpForNextLevel} XP', style: GoogleFonts.firaMono(fontSize: 12, color: Theme.of(context).colorScheme.outline)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          child: LinearProgressIndicator(
            value: user.levelProgress,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.tertiary),
            minHeight: 6,
          ),
        ),
      ]),
    );
  }

  Widget _buildDailyChallenge(BuildContext context, Problem daily) {
    final diffColor = daily.difficulty == Difficulty.easy
        ? Theme.of(context).colorScheme.tertiary
        : daily.difficulty == Difficulty.medium
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.error;

    return GestureDetector(
      onTap: () => onProblemSelected(daily.id),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2), Theme.of(context).colorScheme.surfaceContainer],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1), border: Border.all(color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.2))),
                child: Text('DAILY CHALLENGE', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: Theme.of(context).colorScheme.tertiary)),
              ),
              Row(children: [
                Icon(Icons.bolt, color: Theme.of(context).colorScheme.tertiary, size: 16),
                Text('+${daily.xpReward} XP', style: GoogleFonts.firaMono(fontSize: 12, color: Theme.of(context).colorScheme.tertiary)),
              ]),
            ]),
            const SizedBox(height: 16),
            Text(daily.title, style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              color: diffColor.withValues(alpha: 0.1),
              child: Text(
                daily.difficulty.name.toUpperCase(),
                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: diffColor),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => onProblemSelected(daily.id),
              icon: const Icon(Icons.play_arrow, size: 16),
              label: Text('SOLVE NOW', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.tertiary,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(2))),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, UserProfile user) {
    return Row(children: [
      Expanded(child: _StatCard(icon: Icons.calendar_today_outlined, value: '${user.streak}', label: 'DAY STREAK')),
      const SizedBox(width: 16),
      Expanded(child: _StatCard(icon: Icons.check_circle_outline, value: '${user.solvedProblemIds.length}', label: 'SOLVED')),
    ]);
  }

  Widget _buildRecommended(BuildContext context, UserProfile user) {
    final problems = ProblemBank.problems
        .where((p) => !user.solvedProblemIds.contains(p.id))
        .take(3)
        .toList();

    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Recommended', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
        GestureDetector(
          onTap: () => onNavigate(1),
          child: Row(children: [
            Text('VIEW ALL', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: Theme.of(context).colorScheme.primary)),
            Icon(Icons.chevron_right, size: 16, color: Theme.of(context).colorScheme.primary),
          ]),
        ),
      ]),
      const SizedBox(height: 16),
      if (problems.isEmpty)
        Container(
          padding: const EdgeInsets.all(24),
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          child: Column(children: [
            Icon(Icons.emoji_events, color: Theme.of(context).colorScheme.tertiary, size: 36),
            const SizedBox(height: 8),
            Text('All caught up!', style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
            Text('You solved all available problems.', style: GoogleFonts.inter(fontSize: 12, color: Theme.of(context).colorScheme.outline)),
          ]),
        )
      else
        ...problems.asMap().entries.map((e) {
          final i = e.key;
          final p = e.value;
          final firstUnsolvedIndex = ProblemBank.problems.indexWhere((prob) => !user.solvedProblemIds.contains(prob.id));
          final absoluteIndex = ProblemBank.problems.indexOf(p);
          final isLocked = firstUnsolvedIndex != -1 && absoluteIndex > firstUnsolvedIndex;
          final indexColors = [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.tertiary, Theme.of(context).colorScheme.error];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ProblemCard(
              index: '0${i + 1}',
              title: p.title,
              category: '${p.tags.first.toUpperCase()} • ${p.difficulty.name.toUpperCase()}',
              indexColor: indexColors[i % 3],
              isLocked: isLocked,
              onTap: isLocked ? null : () => onProblemSelected(p.id),
            ),
          );
        }),
    ]);
  }
}


class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(16),
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 36, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface)),
              Text(label, style: GoogleFonts.inter(fontSize: 10, letterSpacing: 1.5, color: Theme.of(context).colorScheme.outline)),
            ]),
          ],
        ),
      ),
    );
  }
}

class _ProblemCard extends StatelessWidget {
  final String index;
  final String title;
  final String category;
  final Color indexColor;
  final bool isLocked;
  final VoidCallback? onTap;

  const _ProblemCard({required this.index, required this.title, required this.category, required this.indexColor, this.isLocked = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isLocked ? 0.5 : 1.0,
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Container(
                width: 40, height: 40,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                alignment: Alignment.center,
                child: isLocked 
                    ? Icon(Icons.lock_outline, color: Theme.of(context).colorScheme.outline, size: 18)
                    : Text(index, style: GoogleFonts.firaMono(fontSize: 13, fontWeight: FontWeight.w700, color: indexColor)),
              ),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
                Text(category, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 1, color: Theme.of(context).colorScheme.outline)),
              ])),
              Icon(Icons.arrow_forward, color: Theme.of(context).colorScheme.outline, size: 20),
            ]),
          ),
        ),
      ),
    );
  }
}
