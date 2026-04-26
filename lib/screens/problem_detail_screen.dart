import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/settings_dialog.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../data/problem_bank.dart';

class ProblemDetailScreen extends ConsumerWidget {
  final String problemId;
  final ValueChanged<int> onNavigate;
  final VoidCallback onStartCoding;

  final VoidCallback onBack;

  const ProblemDetailScreen({super.key, required this.problemId, required this.onNavigate, required this.onStartCoding, required this.onBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final editor = ref.read(editorProvider.notifier);

    // Sync current problem ID
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selectedProblemIdProvider.notifier).state = problemId;
      editor.loadProblem(problemId);
    });

    // Find problem in bank
    final bank = ProblemBank.getById(problemId);
    if (bank == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final solved = user.solvedProblemIds.contains(problemId);
    final diffColor = bank.difficulty == Difficulty.easy
        ? Theme.of(context).colorScheme.tertiary
        : bank.difficulty == Difficulty.medium
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.error;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack, color: Theme.of(context).colorScheme.primary),
        title: Text('Cody', style: GoogleFonts.spaceGrotesk(color: Theme.of(context).colorScheme.primary, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        actions: [IconButton(icon: Icon(Icons.settings_outlined, color: Theme.of(context).colorScheme.primary), onPressed: () => showSettingsModal(context))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (solved) _buildSolvedBanner(context),
          const SizedBox(height: 8),
          _buildDescription(context, bank),
          const SizedBox(height: 20),
          ...bank.examples.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildExample(context, 'Example ${e.key + 1}', e.value),
          )),
          _buildConstraints(context, bank),
          if (bank.followUp != null) ...[const SizedBox(height: 16), _buildFollowUp(context, bank.followUp!)],
          const SizedBox(height: 20),
          _buildMetaCard(context, bank, diffColor, solved, onStartCoding),
          const SizedBox(height: 16),
          _buildSkillRewards(context, bank),
        ]),
      ),
      bottomNavigationBar: CodyBottomNav(currentIndex: 1, onTap: onNavigate),
    );
  }

  Widget _buildSolvedBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1),
      child: Row(children: [
        Icon(Icons.check_circle, color: Theme.of(context).colorScheme.tertiary, size: 20),
        const SizedBox(width: 12),
        Text('SOLVED', style: GoogleFonts.spaceGrotesk(color: Theme.of(context).colorScheme.tertiary, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
      ]),
    );
  }

  Widget _buildDescription(BuildContext context, Problem problem) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(problem.title, style: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface)),
      const SizedBox(height: 16),
      Text(problem.description, style: GoogleFonts.inter(fontSize: 15, height: 1.6, color: Theme.of(context).colorScheme.onSurfaceVariant)),
    ]);
  }

  Widget _buildExample(BuildContext context, String title, ProblemExample e) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.outline)),
        const SizedBox(height: 12),
        Text('Input: ${e.input}', style: GoogleFonts.firaMono(fontSize: 12, color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 4),
        Text('Output: ${e.output}', style: GoogleFonts.firaMono(fontSize: 12, color: Theme.of(context).colorScheme.onSurface)),
        if (e.explanation != null) ...[
          const SizedBox(height: 8),
          Text('Explanation: ${e.explanation}', style: GoogleFonts.inter(fontSize: 12, fontStyle: FontStyle.italic, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ]),
    );
  }

  Widget _buildConstraints(BuildContext context, Problem problem) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('CONSTRAINTS', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: Theme.of(context).colorScheme.outline)),
      const SizedBox(height: 12),
      Text(problem.constraints, style: GoogleFonts.firaMono(fontSize: 12, height: 1.6, color: Theme.of(context).colorScheme.onSurfaceVariant)),
    ]);
  }

  Widget _buildFollowUp(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05), border: Border(left: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('FOLLOW UP', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, color: Theme.of(context).colorScheme.primary)),
        const SizedBox(height: 6),
        Text(text, style: GoogleFonts.inter(fontSize: 13, height: 1.5, color: Theme.of(context).colorScheme.onSurface)),
      ]),
    );
  }

  Widget _buildMetaCard(BuildContext context, Problem problem, Color diffColor, bool solved, VoidCallback onStart) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _MetaItem(label: 'DIFFICULTY', value: problem.difficulty.name.toUpperCase(), color: diffColor),
          _MetaItem(label: 'TOPIC', value: problem.tags.first.toUpperCase(), color: Theme.of(context).colorScheme.outline),
          _MetaItem(label: 'XP', value: '${problem.xpReward}', color: Theme.of(context).colorScheme.tertiary),
        ]),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: onStart,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              elevation: 4,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(2))),
            ),
            child: Text(solved ? 'IMPROVE SOLUTION' : 'START CODING', style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
          ),
        ),
      ]),
    );
  }

  Widget _buildSkillRewards(BuildContext context, Problem problem) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('SKILLS EARNED', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: Theme.of(context).colorScheme.outline)),
      const SizedBox(height: 12),
      Wrap(spacing: 8, children: problem.tags.map((tag) => Chip(
        label: Text(tag, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600)),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        side: BorderSide.none,
        visualDensity: VisualDensity.compact,
      )).toList()),
    ]);
  }
}

class _MetaItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MetaItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 1, color: Theme.of(context).colorScheme.outline)),
      const SizedBox(height: 4),
      Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w900, color: color)),
    ]);
  }
}
