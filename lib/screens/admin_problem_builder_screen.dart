import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../services/problem_service.dart';

class AdminProblemBuilderScreen extends StatefulWidget {
  final VoidCallback onBack;
  const AdminProblemBuilderScreen({super.key, required this.onBack});

  @override
  State<AdminProblemBuilderScreen> createState() => _AdminProblemBuilderScreenState();
}

class _AdminProblemBuilderScreenState extends State<AdminProblemBuilderScreen> {
  final _formKey = GlobalKey<FormState>();

  String _title = '';
  String _id = '';
  Difficulty _difficulty = Difficulty.easy;
  String _description = '';
  String _constraints = '';
  int _xpReward = 50;
  String _tagsStr = '';
  String _functionName = 'solve';

  List<ProblemExample> _examples = [];
  List<TestCase> _testCases = [];

  String _starterPython = 'def solve(nums):\n    # Implement here\n    return 0';
  String _starterDart = 'int solve(List<int> nums) {\n  // Implement here\n  return 0;\n}';
  String _starterJS = 'function solve(nums) {\n    // Implement here\n    return 0;\n}';
  String _starterJava = 'public static int solve(int[] nums) {\n    // Implement here\n    return 0;\n}';
  String _starterCpp = 'int solve(vector<int>& nums) {\n    // Implement here\n    return 0;\n}';
  String _starterC = 'int solve(int* nums, int numsSize) {\n    // Implement here\n    return 0;\n}';

  bool _isUploading = false;

  void _addExample() {
    setState(() => _examples.add(const ProblemExample(input: '', output: '', explanation: '')));
  }

  void _addTestCase() {
    setState(() => _testCases.add(const TestCase(input: '', expectedOutput: '', isHidden: false)));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isUploading = true);

    try {
      final tags = _tagsStr.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      
      final problem = Problem(
        id: _id,
        title: _title,
        description: _description,
        difficulty: _difficulty,
        tags: tags,
        examples: _examples,
        testCases: _testCases,
        constraints: _constraints,
        xpReward: _xpReward,
        functionName: _functionName,
        starterCode: {
          'Python': _starterPython,
          'Dart': _starterDart,
          'JavaScript': _starterJS,
          'Java': _starterJava,
          'C++': _starterCpp,
          'C': _starterC,
        },
      );

      await ProblemService.uploadProblem(problem);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Problem uploaded successfully!')));
      widget.onBack();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onBack),
        title: Text('Admin Problem Builder', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
        actions: [
          _isUploading
              ? const Padding(padding: EdgeInsets.all(16.0), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
              : IconButton(icon: const Icon(Icons.cloud_upload), onPressed: _submit, tooltip: 'Upload Problem'),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionHeader('Basic Info'),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Title (e.g. Two Sum)'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
                onSaved: (v) => _title = v!,
                onChanged: (v) {
                  if (_id.isEmpty || _id == v.toLowerCase().replaceAll(' ', '_')) {
                    setState(() => _id = v.toLowerCase().replaceAll(' ', '_'));
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'ID (e.g. two_sum)'),
                initialValue: _id,
                validator: (v) => v!.isEmpty ? 'Required' : null,
                onSaved: (v) => _id = v!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Difficulty>(
                value: _difficulty,
                decoration: const InputDecoration(labelText: 'Difficulty'),
                items: Difficulty.values.map((d) => DropdownMenuItem(value: d, child: Text(d.name.toUpperCase()))).toList(),
                onChanged: (v) => setState(() => _difficulty = v!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Tags (comma separated, e.g. Math, Arrays)'),
                onSaved: (v) => _tagsStr = v ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'XP Reward (e.g. 50)'),
                keyboardType: TextInputType.number,
                initialValue: '50',
                onSaved: (v) => _xpReward = int.tryParse(v ?? '50') ?? 50,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Main Function Name (e.g. solve)'),
                initialValue: 'solve',
                onSaved: (v) => _functionName = v ?? 'solve',
              ),
              
              const Divider(height: 48),
              _buildSectionHeader('Content'),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description', alignLabelWithHint: true),
                maxLines: 4,
                validator: (v) => v!.isEmpty ? 'Required' : null,
                onSaved: (v) => _description = v!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Constraints (e.g. 0 <= N <= 100)'),
                onSaved: (v) => _constraints = v ?? '',
              ),

              const Divider(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionHeader('Examples'),
                  TextButton.icon(onPressed: _addExample, icon: const Icon(Icons.add), label: const Text('Add')),
                ],
              ),
              ..._examples.asMap().entries.map((e) => _buildExampleFields(e.key, e.value)),

              const Divider(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionHeader('Test Cases'),
                  TextButton.icon(onPressed: _addTestCase, icon: const Icon(Icons.add), label: const Text('Add')),
                ],
              ),
              ..._testCases.asMap().entries.map((e) => _buildTestCaseFields(e.key, e.value)),

              const Divider(height: 48),
              _buildSectionHeader('Starter Code'),
              _buildCodeField('Python', _starterPython, (v) => _starterPython = v!),
              _buildCodeField('Dart', _starterDart, (v) => _starterDart = v!),
              _buildCodeField('JavaScript', _starterJS, (v) => _starterJS = v!),
              _buildCodeField('Java', _starterJava, (v) => _starterJava = v!),
              _buildCodeField('C++', _starterCpp, (v) => _starterCpp = v!),
              
              const SizedBox(height: 64),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.tertiary, foregroundColor: Colors.white),
                  onPressed: _isUploading ? null : _submit,
                  child: Text('UPLOAD PROBLEM TO SUPABASE', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(title, style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
    );
  }

  Widget _buildExampleFields(int index, ProblemExample example) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Example ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => _examples.removeAt(index))),
              ],
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Input (e.g. nums=[2,7], target=9)'),
              initialValue: example.input,
              onChanged: (v) => _examples[index] = ProblemExample(input: v, output: _examples[index].output, explanation: _examples[index].explanation),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Output (e.g. [0,1])'),
              initialValue: example.output,
              onChanged: (v) => _examples[index] = ProblemExample(input: _examples[index].input, output: v, explanation: _examples[index].explanation),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Explanation (optional)'),
              initialValue: example.explanation,
              onChanged: (v) => _examples[index] = ProblemExample(input: _examples[index].input, output: _examples[index].output, explanation: v),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestCaseFields(int index, TestCase tc) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Test Case ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => _testCases.removeAt(index))),
              ],
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Input (e.g. [2,7]\\n9)'),
              initialValue: tc.input,
              maxLines: 2,
              onChanged: (v) => _testCases[index] = TestCase(input: v, expectedOutput: _testCases[index].expectedOutput, isHidden: _testCases[index].isHidden),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Expected Output (e.g. [0, 1])'),
              initialValue: tc.expectedOutput,
              onChanged: (v) => _testCases[index] = TestCase(input: _testCases[index].input, expectedOutput: v, isHidden: _testCases[index].isHidden),
            ),
            SwitchListTile(
              title: const Text('Is Hidden Test Case?'),
              value: tc.isHidden,
              onChanged: (v) => setState(() => _testCases[index] = TestCase(input: _testCases[index].input, expectedOutput: _testCases[index].expectedOutput, isHidden: v)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeField(String language, String initial, FormFieldSetter<String> onSaved) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        decoration: InputDecoration(labelText: '$language Starter Code', alignLabelWithHint: true),
        initialValue: initial,
        maxLines: 4,
        style: GoogleFonts.firaMono(fontSize: 13),
        onSaved: onSaved,
      ),
    );
  }
}
