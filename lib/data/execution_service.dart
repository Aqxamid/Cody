import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import '../data/problem_bank.dart';

class ExecutionService {
  static const String codapiURL = 'https://api.codapi.org/v1/exec';

  static Future<ExecutionResult> run(String problemId, String code, String language, {bool isSubmission = true}) async {
    final problem = ProblemBank.getById(problemId);
    if (problem == null) return _errorResult('Problem not found.');

    final lang = language.toLowerCase();
    
    // Inject test harness based on whether it's a submission or just a test run
    final finalCode = _generateFinalCode(problem, code, lang, isSubmission);

    return _runViaCodapi(problem, finalCode, lang, isSubmission);
  }

  static String _generateFinalCode(Problem problem, String code, String language, bool isSubmission) {
    if (language == 'python') {
      if (!isSubmission) {
        // Just a simple run of the user's code + a call to the function with first test input
        final firstCase = problem.testCases.first;
        return '''
$code

if __name__ == "__main__":
    # Test Run with first case: ${firstCase.input}
    print(${problem.functionName}(${firstCase.input}))
''';
      } else {
        // Submission: Run all test cases with delimiters for parsing
        String harness = '\n\nif __name__ == "__main__":\n';
        for (int i = 0; i < problem.testCases.length; i++) {
          final tc = problem.testCases[i];
          harness += '    print("---CASE_START---")\n';
          harness += '    try:\n';
          harness += '        print(${problem.functionName}(${tc.input}))\n';
          harness += '    except Exception as e:\n';
          harness += '        print(f"ERROR: {e}")\n';
          harness += '    print("---CASE_END---")\n';
        }
        return code + harness;
      }
    } else if (language == 'dart') {
      if (!isSubmission) {
        final firstCase = problem.testCases.first;
        return '''
$code

void main() {
  // Test Run with first case: ${firstCase.input}
  print(${problem.functionName}(${firstCase.input}));
}
''';
      } else {
        String harness = '\n\nvoid main() {\n';
        for (int i = 0; i < problem.testCases.length; i++) {
          final tc = problem.testCases[i];
          harness += '  print("---CASE_START---");\n';
          harness += '  try {\n';
          harness += '    print(${problem.functionName}(${tc.input.replaceAll('\n', ', ')}));\n';
          harness += '  } catch (e) {\n';
          harness += '    print("ERROR: \$e");\n';
          harness += '  }\n';
          harness += '  print("---CASE_END---");\n';
        }
        harness += '}\n';
        return code + harness;
      }
    }
    return code;
  }

  static Future<ExecutionResult> _runViaCodapi(Problem problem, String code, String language, bool isSubmission) async {
    try {
      final sandbox = language == 'python' ? 'python' : 'dart';
      final response = await http.post(
        Uri.parse(codapiURL),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sandbox': sandbox,
          'command': 'run',
          'files': {sandbox == 'python' ? 'main.py' : 'main.dart': code},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final stdout = (data['stdout'] ?? '').toString().trim();
        final stderr = (data['stderr'] ?? '').toString().trim();

        if (stderr.isNotEmpty) return _errorResult(stderr);

        if (!isSubmission) {
          // For test runs, we just return the raw output and a neutral result
          return ExecutionResult(
            status: SubmissionStatus.pending,
            passedCount: 0,
            totalCount: 0,
            runtimeMs: 0,
            memoryMb: 0,
            stdout: stdout,
            stderr: '',
            testResults: [],
            xpEarned: 0,
          );
        }

        return _validateSubmission(problem, stdout, stderr);
      }
      return _errorResult('API Error (Status ${response.statusCode})');
    } catch (e) {
      return _errorResult('Connection failed: $e');
    }
  }

  static ExecutionResult _validateSubmission(Problem problem, String stdout, String stderr) {
    final testResults = <TestResult>[];
    int passed = 0;

    // Use regex to extract outputs between CASE markers
    final cases = RegExp(r'---CASE_START---\n([\s\S]*?)---CASE_END---', multiLine: true).allMatches(stdout).toList();

    for (int i = 0; i < problem.testCases.length; i++) {
      final tc = problem.testCases[i];
      String actual = 'No output';
      if (i < cases.length) {
        actual = cases[i].group(1)?.trim() ?? 'No output';
      }

      final expected = tc.expectedOutput.trim();
      // Handle simple list/dict string conversions between Python/Dart outputs
      final normalizedActual = actual.replaceAll(' ', '').toLowerCase();
      final normalizedExpected = expected.replaceAll(' ', '').toLowerCase();
      
      final isCasePassed = normalizedActual == normalizedExpected;
      if (isCasePassed) passed++;

      testResults.add(TestResult(
        caseLabel: tc.isHidden ? 'Hidden Case' : 'Case #${i + 1}',
        input: tc.isHidden ? '(hidden)' : tc.input,
        expectedOutput: tc.isHidden ? '(hidden)' : expected,
        actualOutput: tc.isHidden ? null : actual,
        passed: isCasePassed,
        errorMessage: isCasePassed ? null : 'Wrong Answer',
      ));
    }

    final allPassed = passed == problem.testCases.length;
    return ExecutionResult(
      status: allPassed ? SubmissionStatus.passed : SubmissionStatus.failed,
      passedCount: passed,
      totalCount: problem.testCases.length,
      runtimeMs: 15,
      memoryMb: 12.0,
      stdout: stdout,
      stderr: stderr,
      testResults: testResults,
      xpEarned: allPassed ? problem.xpReward : 0,
    );
  }

  static ExecutionResult _errorResult(String message) {
    return ExecutionResult(
      status: SubmissionStatus.error,
      passedCount: 0,
      totalCount: 0,
      runtimeMs: 0,
      memoryMb: 0,
      stdout: '',
      stderr: message,
      testResults: [],
      xpEarned: 0,
    );
  }
}
