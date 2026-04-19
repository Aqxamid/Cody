import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/settings_dialog.dart';
import '../providers/providers.dart';
import '../models/models.dart';

class ExecutionResultsScreen extends ConsumerWidget {
  final ValueChanged<int> onNavigate;
  final VoidCallback onSubmit;
  final VoidCallback onRetry;

  const ExecutionResultsScreen({
    super.key,
    required this.onNavigate,
    required this.onSubmit,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(executionResultProvider);

    if (result == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.tertiary)),
        bottomNavigationBar: CodyBottomNav(currentIndex: 1, onTap: onNavigate),
      );
    }

    final allPassed = result.passedCount == result.totalCount;
    final statusColor = result.status == SubmissionStatus.error
        ? Theme.of(context).colorScheme.error
        : allPassed
            ? Theme.of(context).colorScheme.tertiary
            : Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('Execution Results', style: GoogleFonts.spaceGrotesk(color: Theme.of(context).colorScheme.primary, fontSize: 18, fontWeight: FontWeight.w700)),
        actions: [IconButton(icon: Icon(Icons.settings_outlined, color: Theme.of(context).colorScheme.primary), onPressed: () => showSettingsModal(context))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // XP Banner (if earned)
          if (result.xpEarned > 0) _buildXpBanner(context, result.xpEarned),
          if (result.xpEarned > 0) const SizedBox(height: 12),
          // Summary cards
          _buildStatusCard(context, result, statusColor),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _buildMetricCard(context, 'RUNTIME', '${result.runtimeMs}', 'ms', result.runtimeMs / 500)),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricCard(context, 'MEMORY', result.memoryMb.toStringAsFixed(1), 'MB', result.memoryMb / 100)),
          ]),
          const SizedBox(height: 20),
          // STDOUT
          if (result.stdout.isNotEmpty) ...[_buildOutputCard(context, 'STDOUT', result.stdout, false), const SizedBox(height: 16)],
          // STDERR
          if (result.stderr.isNotEmpty) ...[_buildOutputCard(context, 'STDERR', result.stderr, true), const SizedBox(height: 16)],
          // Test cases
          _buildTestCases(context, result),
          const SizedBox(height: 24),
          // Submit button
          _buildSubmitButton(context, result, allPassed),
          if (!allPassed || result.status == SubmissionStatus.error) ...[
            const SizedBox(height: 12),
            _buildRetryButton(context),
          ],
        ]),
      ),
      bottomNavigationBar: CodyBottomNav(currentIndex: 1, onTap: onNavigate),
    );
  }

  Widget _buildXpBanner(BuildContext context, int xp) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1),
        border: Border.all(color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(children: [
        Icon(Icons.emoji_events, color: Theme.of(context).colorScheme.tertiary, size: 28),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('All Tests Passed! 🎉', style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.tertiary)),
          Text('+$xp XP earned and added to your profile', style: GoogleFonts.inter(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ])),
      ]),
    );
  }

  Widget _buildStatusCard(BuildContext context, ExecutionResult result, Color statusColor) {
    final statusLabel = result.status == SubmissionStatus.error
        ? 'ERROR'
        : result.passedCount == result.totalCount
            ? 'ACCEPTED'
            : 'WRONG ANSWER';

    return Container(
      padding: const EdgeInsets.all(20),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('EXECUTION STATUS', style: GoogleFonts.inter(fontSize: 10, letterSpacing: 2, color: Theme.of(context).colorScheme.outline)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: statusColor.withValues(alpha: 0.15),
            child: Text(statusLabel, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1, color: statusColor)),
          ),
        ]),
        const SizedBox(height: 12),
        Text('${result.passedCount}/${result.totalCount} Passed',
            style: GoogleFonts.spaceGrotesk(fontSize: 38, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface)),
        Text('Test suite evaluation', style: GoogleFonts.firaMono(fontSize: 12, color: Theme.of(context).colorScheme.outline)),
      ]),
    );
  }

  Widget _buildMetricCard(BuildContext context, String label, String value, String unit, double progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.inter(fontSize: 10, letterSpacing: 2, color: Theme.of(context).colorScheme.outline)),
        const SizedBox(height: 8),
        Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
          Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary)),
          const SizedBox(width: 4),
          Text(unit, style: GoogleFonts.inter(fontSize: 13, color: Theme.of(context).colorScheme.outline)),
        ]),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: progress.clamp(0.0, 1.0), backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh, valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary), minHeight: 3),
      ]),
    );
  }

  Widget _buildOutputCard(BuildContext context, String title, String content, bool isError) {
    return Column(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Icon(isError ? Icons.error_outline : Icons.description_outlined, size: 14, color: isError ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.outline),
            const SizedBox(width: 8),
            Text(title, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5, color: isError ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onSurfaceVariant)),
          ]),
          if (!isError) Text('UTF-8', style: GoogleFonts.firaMono(fontSize: 10, color: Theme.of(context).colorScheme.outline)),
        ]),
      ),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        constraints: const BoxConstraints(maxHeight: 180),
        child: SingleChildScrollView(
          child: Text(content, style: GoogleFonts.firaMono(fontSize: 12, color: isError ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onSurface, height: 1.6)),
        ),
      ),
    ]);
  }

  Widget _buildTestCases(BuildContext context, ExecutionResult result) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Test Cases', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
      const SizedBox(height: 16),
      ...result.testResults.map((tc) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Material(
          color: tc.passed ? Theme.of(context).colorScheme.surfaceContainer : Theme.of(context).colorScheme.error.withValues(alpha: 0.05),
          child: InkWell(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(border: tc.passed ? null : Border(left: BorderSide(color: Theme.of(context).colorScheme.error, width: 2))),
              child: Row(children: [
                Container(width: 8, height: 8,
                  decoration: BoxDecoration(color: tc.passed ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.error, shape: BoxShape.circle)),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(tc.caseLabel, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 2),
                  if (tc.input != '(hidden)')
                    Text('Input: ${tc.input}', style: GoogleFonts.firaMono(fontSize: 10, color: Theme.of(context).colorScheme.outline), maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (!tc.passed && tc.actualOutput != null)
                    Text('Got: ${tc.actualOutput}  Expected: ${tc.expectedOutput}',
                      style: GoogleFonts.firaMono(fontSize: 10, color: Theme.of(context).colorScheme.error), maxLines: 1, overflow: TextOverflow.ellipsis),
                ])),
                Icon(tc.passed ? Icons.check_circle_outline : Icons.cancel_outlined,
                  color: tc.passed ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.error, size: 18),
              ]),
            ),
          ),
        ),
      )),
    ]);
  }

  Widget _buildSubmitButton(BuildContext context, ExecutionResult result, bool allPassed) {
    return Column(children: [
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: allPassed ? onSubmit : null,
          icon: Icon(allPassed ? Icons.rocket_launch_outlined : Icons.lock_outline, size: 20),
          label: Text(
            allPassed ? 'SUBMIT SOLUTION' : 'FIX FAILING TESTS FIRST',
            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.5),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: allPassed ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.surfaceContainerHigh,
            foregroundColor: allPassed ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.outline,
            disabledBackgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
            disabledForegroundColor: Theme.of(context).colorScheme.outline,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(2))),
            padding: const EdgeInsets.symmetric(vertical: 18),
            elevation: allPassed ? 8 : 0,
            shadowColor: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.2),
          ),
        ),
      ),
      const SizedBox(height: 8),
      Text(
        allPassed
            ? 'FINAL EVALUATION WILL RUN 50+ HIDDEN TEST CASES'
            : 'ALL VISIBLE TEST CASES MUST PASS TO SUBMIT',
        style: GoogleFonts.inter(fontSize: 9, letterSpacing: 0.8, color: Theme.of(context).colorScheme.outline),
        textAlign: TextAlign.center,
      ),
    ]);
  }

  Widget _buildRetryButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.edit_note_outlined, size: 20),
        label: Text(
          'BACK TO EDITOR',
          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.5),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 1.5),
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(2))),
          padding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}
