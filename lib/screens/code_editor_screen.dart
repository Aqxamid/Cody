import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/settings_dialog.dart';
import '../providers/providers.dart';
import '../data/problem_bank.dart';
import '../data/execution_service.dart';

class CodeEditorScreen extends ConsumerStatefulWidget {
  final ValueChanged<int> onNavigate;
  final VoidCallback onRunComplete;

  const CodeEditorScreen({super.key, required this.onNavigate, required this.onRunComplete});

  @override
  ConsumerState<CodeEditorScreen> createState() => _CodeEditorScreenState();
}

class _CodeEditorScreenState extends ConsumerState<CodeEditorScreen> {
  late TextEditingController _controller;
  final _scrollController = ScrollController();
  final _lineScrollController = ScrollController();
  bool _isRunning = false;

  final List<String> _specialKeys = ['{', '}', '[', ']', '(', ')', ':', 'TAB', '"', "'", ';', '=', '.', ','];

  @override
  void initState() {
    super.initState();
    final code = ref.read(editorProvider).code;
    _controller = TextEditingController(text: code);
    _controller.addListener(_onCodeChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onCodeChanged);
    _controller.dispose();
    _scrollController.dispose();
    _lineScrollController.dispose();
    super.dispose();
  }

  void _onCodeChanged() {
    ref.read(editorProvider.notifier).updateCode(_controller.text);
  }

  Future<void> _runCode({bool isSubmission = true}) async {
    final editorState = ref.read(editorProvider);
    setState(() => _isRunning = true);

    final result = await ExecutionService.run(
      editorState.problemId,
      editorState.code,
      editorState.language,
      isSubmission: isSubmission,
    );

    ref.read(executionResultProvider.notifier).state = result;

    if (isSubmission) {
      // Award XP if all passed
      if (result.xpEarned > 0) {
        await ref.read(userProvider.notifier).awardXp(result.xpEarned, editorState.problemId);
        await ref.read(userProvider.notifier).incrementStreak();
      }
      widget.onRunComplete();
    }
    
    setState(() => _isRunning = false);
  }

  void _insertKey(String key) {
    final text = _controller.text;
    final selection = _controller.selection;
    final cursorPos = selection.baseOffset < 0 ? text.length : selection.baseOffset;

    String insert = key == 'TAB' ? '    ' : key;
    final newText = text.substring(0, cursorPos) + insert + text.substring(cursorPos);
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: cursorPos + insert.length),
    );
  }

  void _switchLanguage(String lang) {
    ref.read(editorProvider.notifier).switchLanguage(lang);
    final newCode = ref.read(editorProvider).code;
    _controller.text = newCode;
  }

  int get _lineCount => _controller.text.split('\n').length;

  @override
  Widget build(BuildContext context) {
    final editorState = ref.watch(editorProvider);
    final problem = ProblemBank.getById(editorState.problemId);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('Cody', style: GoogleFonts.spaceGrotesk(color: Theme.of(context).colorScheme.primary, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        actions: [
          IconButton(
            icon: Icon(Icons.restart_alt, color: Theme.of(context).colorScheme.primary),
            tooltip: 'Reset to starter code',
            onPressed: () => _showResetDialog(),
          ),
          IconButton(icon: Icon(Icons.settings_outlined, color: Theme.of(context).colorScheme.primary), onPressed: () => showSettingsModal(context)),
        ],
      ),
      body: Column(children: [
        _buildSubHeader(editorState.language, problem?.title ?? ''),
        Expanded(child: _buildEditorArea()),
        _buildAccessoryKeyboard(),
        _buildActionBar(),
      ]),
      bottomNavigationBar: CodyBottomNav(currentIndex: 1, onTap: widget.onNavigate),
    );
  }

  Widget _buildSubHeader(String language, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          Icon(Icons.description_outlined, color: Theme.of(context).colorScheme.primary, size: 16),
          const SizedBox(width: 8),
          Text(title, style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w700)),
        ]),
        Container(
          padding: const EdgeInsets.all(3),
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          child: Row(children: ['Python', 'Dart'].map((lang) {
            final isSelected = language == lang;
            return GestureDetector(
              onTap: () => _switchLanguage(lang),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).colorScheme.primaryContainer : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(lang, style: GoogleFonts.inter(fontSize: 12, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? Theme.of(context).colorScheme.onPrimaryContainer : Theme.of(context).colorScheme.onSurfaceVariant)),
              ),
            );
          }).toList()),
        ),
      ]),
    );
  }

  Widget _buildEditorArea() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Line numbers - synced with scroll
        SizedBox(
          width: 48,
          child: NotificationListener<ScrollNotification>(
            onNotification: (n) => false,
            child: SingleChildScrollView(
              controller: _lineScrollController,
              physics: const NeverScrollableScrollPhysics(),
              child: Container(
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
                padding: const EdgeInsets.only(top: 16, right: 12, bottom: 16),
                child: ValueListenableBuilder(
                  valueListenable: _controller,
                  builder: (_, value, __) {
                    final lines = value.text.split('\n').length;
                    return Column(children: List.generate(lines, (i) => SizedBox(
                      height: 21,
                      child: Text(
                        '${i + 1}',
                        textAlign: TextAlign.right,
                        style: GoogleFonts.firaMono(fontSize: 13, color: Theme.of(context).colorScheme.outline),
                      ),
                    )));
                  },
                ),
              ),
            ),
          ),
        ),
        // Actual editable code area
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n is ScrollUpdateNotification) {
                _lineScrollController.jumpTo(_scrollController.offset);
              }
              return false;
            },
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  style: GoogleFonts.firaMono(fontSize: 13, color: Theme.of(context).colorScheme.onSurface, height: 1.6),
                  cursorColor: Theme.of(context).colorScheme.tertiary,
                  cursorWidth: 2,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (_) {
                    setState(() {}); // rebuild line numbers
                  },
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildAccessoryKeyboard() {
    return Container(
      height: 52,
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        itemCount: _specialKeys.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (ctx, i) {
          final key = _specialKeys[i];
          return GestureDetector(
            onTap: () => _insertKey(key),
            child: Container(
              width: key == 'TAB' ? 48 : 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(2),
              ),
              alignment: Alignment.center,
              child: Text(key, style: GoogleFonts.firaMono(fontSize: key == 'TAB' ? 11 : 15, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.primary)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Row(children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: Material(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(2),
              child: InkWell(
                borderRadius: BorderRadius.circular(2),
                onTap: () => _testAndShowResults(),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _isRunning 
                    ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.onSurface))
                    : Icon(Icons.science_outlined, size: 18, color: Theme.of(context).colorScheme.onSurface),
                  const SizedBox(width: 8),
                  Text(_isRunning ? 'Testing...' : 'Test', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
                ]),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _isRunning ? null : () => _runCode(isSubmission: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.tertiary,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                disabledBackgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(2))),
                elevation: 4,
                shadowColor: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.3),
              ),
              child: _isRunning
                  ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), strokeWidth: 2)),
                      const SizedBox(width: 8),
                      Text('Running...', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 14)),
                    ])
                  : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.play_arrow, size: 20),
                      const SizedBox(width: 6),
                      Text('Run', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 18)),
                    ]),
            ),
          ),
        ),
      ]),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        title: Text('Reset Code?', style: GoogleFonts.spaceGrotesk(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w700)),
        content: Text('This will replace your code with the starter template. Your current code will be lost.', style: GoogleFonts.inter(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('CANCEL', style: GoogleFonts.inter(color: Theme.of(context).colorScheme.outline))),
          ElevatedButton(
            onPressed: () {
              ref.read(editorProvider.notifier).resetToStarter();
              _controller.text = ref.read(editorProvider).code;
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error, foregroundColor: Theme.of(context).colorScheme.onError, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(2)))),
            child: Text('RESET', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Future<void> _testAndShowResults() async {
    if (_isRunning) return;
    await _runCode(isSubmission: false);
    _showTestResult();
  }

  void _showTestResult() {
    final result = ref.read(executionResultProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.science_outlined, color: Theme.of(context).colorScheme.primary, size: 18),
            const SizedBox(width: 8),
            Text('Quick Test Result', style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
            const Spacer(),
            IconButton(icon: Icon(Icons.close, color: Theme.of(context).colorScheme.outline), onPressed: () => Navigator.pop(ctx)),
          ]),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 250),
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            child: SingleChildScrollView(
              child: Text(
                result == null 
                  ? '> Error: No output captured.' 
                  : result.stderr.isNotEmpty
                    ? 'COMPILATION/RUNTIME ERROR:\n${result.stderr}'
                    : 'OUTPUT:\n${result.stdout}',
                style: GoogleFonts.firaMono(fontSize: 12, color: Theme.of(context).colorScheme.onSurface, height: 1.6),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Keep in mind: "Test" only runs a preview. Use "Run" to submit your solution.',
            style: GoogleFonts.inter(fontSize: 11, color: Theme.of(context).colorScheme.outline, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 12),
        ]),
      ),
    );
  }
}
