import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/bottom_nav.dart';
import '../widgets/settings_dialog.dart';
import '../providers/providers.dart';
import '../data/problem_bank.dart';
import '../models/models.dart';

class ProblemsListScreen extends ConsumerStatefulWidget {
  final ValueChanged<int> onNavigate;
  final ValueChanged<String> onProblemSelected;

  const ProblemsListScreen({super.key, required this.onNavigate, required this.onProblemSelected});

  @override
  ConsumerState<ProblemsListScreen> createState() => _ProblemsListScreenState();
}

class _ProblemsListScreenState extends ConsumerState<ProblemsListScreen> {
  Difficulty? _filter;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    var problems = ProblemBank.problems;
    if (_filter != null) problems = problems.where((p) => p.difficulty == _filter).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('Challenges', style: GoogleFonts.spaceGrotesk(color: Theme.of(context).colorScheme.primary, fontSize: 20, fontWeight: FontWeight.w900)),
        actions: [
          IconButton(icon: Icon(Icons.settings, color: Theme.of(context).colorScheme.primary), onPressed: () => showSettingsModal(context)),
        ],
      ),
      body: Column(children: [
        // Filter chips
        Container(
          height: 52,
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            children: [
              _FilterChip(label: 'ALL', isActive: _filter == null, onTap: () => setState(() => _filter = null)),
              const SizedBox(width: 8),
              _FilterChip(label: 'EASY', isActive: _filter == Difficulty.easy, color: Theme.of(context).colorScheme.tertiary, onTap: () => setState(() => _filter = Difficulty.easy)),
              const SizedBox(width: 8),
              _FilterChip(label: 'MEDIUM', isActive: _filter == Difficulty.medium, color: Theme.of(context).colorScheme.primary, onTap: () => setState(() => _filter = Difficulty.medium)),
              const SizedBox(width: 8),
              _FilterChip(label: 'HARD', isActive: _filter == Difficulty.hard, color: Theme.of(context).colorScheme.error, onTap: () => setState(() => _filter = Difficulty.hard)),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await ProblemBank.loadFromSupabase();
              if (mounted) setState(() {});
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: problems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
              final p = problems[i];
              final firstUnsolvedIndex = ProblemBank.problems.indexWhere((prob) => !user.solvedProblemIds.contains(prob.id));
              final absoluteIndex = ProblemBank.problems.indexOf(p);
              final isLocked = firstUnsolvedIndex != -1 && absoluteIndex > firstUnsolvedIndex;
              final solved = user.solvedProblemIds.contains(p.id);
              final diffColor = p.difficulty == Difficulty.easy
                  ? Theme.of(context).colorScheme.tertiary
                  : p.difficulty == Difficulty.medium
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.error;
              return Opacity(
                opacity: isLocked ? 0.5 : 1.0,
                child: Material(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  child: InkWell(
                    onTap: isLocked ? null : () => widget.onProblemSelected(p.id),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(children: [
                        Container(
                          width: 40, height: 40,
                          color: solved ? Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.15) : Theme.of(context).colorScheme.surfaceContainerHighest,
                          alignment: Alignment.center,
                          child: isLocked 
                              ? Icon(Icons.lock_outline, color: Theme.of(context).colorScheme.outline, size: 18)
                              : solved
                                  ? Icon(Icons.check, color: Theme.of(context).colorScheme.tertiary, size: 20)
                                  : Text('${ProblemBank.problems.indexOf(p) + 1}'.padLeft(2, '0'), style: GoogleFonts.firaMono(fontSize: 13, fontWeight: FontWeight.w700, color: diffColor)),
                        ),
                      const SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(p.title, style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
                        const SizedBox(height: 4),
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            color: diffColor.withValues(alpha: 0.1),
                            child: Text(p.difficulty.name.toUpperCase(), style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1, color: diffColor)),
                          ),
                          const SizedBox(width: 8),
                          ...p.tags.take(2).map((t) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Text(t, style: GoogleFonts.inter(fontSize: 9, color: Theme.of(context).colorScheme.outline, letterSpacing: 0.5)),
                          )),
                        ]),
                      ])),
                      Row(children: [
                        if (isLocked)
                          Icon(Icons.lock, color: Theme.of(context).colorScheme.outline, size: 16)
                        else ...[
                          Icon(Icons.bolt, color: Theme.of(context).colorScheme.tertiary, size: 14),
                          Text('+${p.xpReward}', style: GoogleFonts.firaMono(fontSize: 11, color: Theme.of(context).colorScheme.tertiary)),
                          const SizedBox(width: 8),
                          Icon(Icons.arrow_forward, color: Theme.of(context).colorScheme.outline, size: 18),
                        ],
                      ]),
                    ]),
                  ),
                ),
              ),
            );
          },
            ),
          ),
        ),
      ]),
      bottomNavigationBar: CodyBottomNav(currentIndex: 1, onTap: widget.onNavigate),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.isActive, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? (color ?? Theme.of(context).colorScheme.primary).withValues(alpha: 0.15) : Theme.of(context).colorScheme.surfaceContainerHigh,
          border: Border.all(color: isActive ? (color ?? Theme.of(context).colorScheme.primary).withValues(alpha: 0.5) : Colors.transparent),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? (color ?? Theme.of(context).colorScheme.primary) : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
