import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class ProblemService {
  static final _client = Supabase.instance.client;

  static Future<void> uploadProblem(Problem problem) async {
    final Map<String, dynamic> data = {
      'id': problem.id,
      'title': problem.title,
      'description': problem.description,
      'difficulty': problem.difficulty.name,
      'tags': problem.tags,
      'examples': problem.examples.map((e) => {
        'input': e.input,
        'output': e.output,
        'explanation': e.explanation,
      }).toList(),
      'test_cases': problem.testCases.map((tc) => {
        'input': tc.input,
        'expected_output': tc.expectedOutput,
        'is_hidden': tc.isHidden,
      }).toList(),
      'constraints': problem.constraints,
      'follow_up': problem.followUp,
      'xp_reward': problem.xpReward,
      'function_name': problem.functionName,
      'starter_code': problem.starterCode,
    };

    await _client.from('problems').insert(data);
  }

  static Future<List<Problem>> fetchProblems() async {
    try {
      final data = await _client.from('problems').select().order('created_at', ascending: true);
      return data.map((json) {
        return Problem(
          id: json['id'],
          title: json['title'],
          description: json['description'],
          difficulty: Difficulty.values.firstWhere((d) => d.name == json['difficulty'], orElse: () => Difficulty.easy),
          tags: List<String>.from(json['tags'] ?? []),
          examples: (json['examples'] as List<dynamic>? ?? []).map((e) => ProblemExample(
            input: e['input'] ?? '',
            output: e['output'] ?? '',
            explanation: e['explanation'],
          )).toList(),
          testCases: (json['test_cases'] as List<dynamic>? ?? []).map((e) => TestCase(
            input: e['input'] ?? '',
            expectedOutput: e['expected_output'] ?? '',
            isHidden: e['is_hidden'] ?? false,
          )).toList(),
          constraints: json['constraints'] ?? '',
          followUp: json['follow_up'],
          xpReward: json['xp_reward'] ?? 50,
          functionName: json['function_name'] ?? 'solve',
          starterCode: Map<String, String>.from(json['starter_code'] ?? {}),
        );
      }).toList();
    } catch (e) {
      print('Fetch problems error: $e');
      return [];
    }
  }
}
