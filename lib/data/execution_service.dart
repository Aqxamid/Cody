import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import '../data/problem_bank.dart';

class ExecutionService {
  static const String _codapiUrl = 'https://api.codapi.org/v1/exec';

  // ── Language → codapi sandbox mapping ────────────────────────────────────────
  static const Map<String, Map<String, String>> _sandboxes = {
    'python':     {'sandbox': 'python',     'file': 'main.py'},
    'dart':       {'sandbox': 'dart',       'file': 'main.dart'},
    'c':          {'sandbox': 'gcc',          'file': 'main.c'},
    'c++':        {'sandbox': 'cpp',        'file': 'main.cpp'},
    'java':       {'sandbox': 'java',       'file': 'main.java'},
    'javascript': {'sandbox': 'typescript', 'file': 'main.ts'},
  };

  static Future<ExecutionResult> run(
    String problemId, String code, String language, {bool isSubmission = true}
  ) async {
    final problem = ProblemBank.getById(problemId);
    if (problem == null) return _errorResult('Problem not found.');
    if (problem.testCases.isEmpty) return _errorResult('No test cases defined.');

    final lang = language.toLowerCase();
    final sandbox = _sandboxes[lang];
    if (sandbox == null) return _errorResult('Unsupported language: $language');

    final finalCode = _generateFinalCode(problem, code, lang, isSubmission);
    return _runViaCodapi(problem, finalCode, sandbox, isSubmission);
  }

  // ── Code harness generator ────────────────────────────────────────────────────
  static String _generateFinalCode(Problem p, String code, String lang, bool isSubmission) {
    switch (lang) {
      case 'python':     return _pythonHarness(p, code, isSubmission);
      case 'dart':       return _dartHarness(p, code, isSubmission);
      case 'c':          return _cHarness(p, code, isSubmission);
      case 'c++':        return _cppHarness(p, code, isSubmission);
      case 'java':       return _javaHarness(p, code, isSubmission);
      case 'javascript': return _jsHarness(p, code, isSubmission);
      default:           return code;
    }
  }

  static String _pythonHarness(Problem p, String code, bool isSubmission) {
    if (!isSubmission) {
      final first = p.testCases.first;
      return '$code\n\nif __name__ == "__main__":\n    print(${p.functionName}(${_simpleArgs(first.input)}))\n';
    }
    String h = '\n\nif __name__ == "__main__":\n';
    for (final tc in p.testCases) {
      h += '    print("---CASE_START---")\n    try:\n        print(${p.functionName}(${_simpleArgs(tc.input)}))\n    except Exception as e:\n        print(f"ERROR: {e}")\n    print("---CASE_END---")\n';
    }
    return code + h;
  }

  static String _dartHarness(Problem p, String code, bool isSubmission) {
    if (!isSubmission) {
      final first = p.testCases.first;
      return '$code\n\nvoid main() {\n  print(${p.functionName}(${first.input.replaceAll('\n', ', ')}));\n}\n';
    }
    String h = '\n\nvoid main() {\n';
    for (final tc in p.testCases) {
      h += '  print("---CASE_START---");\n  try {\n    print(${p.functionName}(${tc.input.replaceAll('\n', ', ')}));\n  } catch (e) {\n    print("ERROR: \$e");\n  }\n  print("---CASE_END---");\n';
    }
    return '${code + h}}\n';
  }

  static String _cHarness(Problem p, String code, bool isSubmission) {
    const inc = '#include <stdio.h>\n#include <stdlib.h>\n#include <string.h>\n#include <stdbool.h>\n\n';
    if (!isSubmission) {
      final args = _simpleArgs(p.testCases.first.input);
      return '${inc}$code\n\nint main() {\n    printf("%s\\n", "---TEST---");\n    // Call: ${p.functionName}($args)\n    return 0;\n}\n';
    }
    String main = '\n\nint main() {\n';
    for (final tc in p.testCases) {
      final args = _simpleArgs(tc.input);
      main += '    printf("---CASE_START---\\n");\n    printf("%d\\n", ${p.functionName}($args));\n    printf("---CASE_END---\\n");\n';
    }
    return '$inc$code${main}    return 0;\n}\n';
  }

  static String _cppHarness(Problem p, String code, bool isSubmission) {
    const inc = '#include <iostream>\n'
        '#include <vector>\n'
        '#include <string>\n'
        '#include <algorithm>\n'
        '#include <map>\n'
        '#include <set>\n'
        '#include <utility>\n'
        'using namespace std;\n\n'
        '// Helper to print various types\n'
        'template<typename T> void print_val(const T& v) { cout << v; }\n'
        'void print_val(const string& v) { cout << "\\"" << v << "\\""; }\n'
        'void print_val(bool v) { cout << (v ? "true" : "false"); }\n\n'
        'template<typename T1, typename T2> void print_val(const pair<T1, T2>& p) {\n'
        '    cout << "("; print_val(p.first); cout << ", "; print_val(p.second); cout << ")";\n'
        '}\n\n'
        'template<typename T> void print_val(const vector<T>& v) {\n'
        '    cout << "[";\n'
        '    for (size_t i = 0; i < v.size(); ++i) {\n'
        '        print_val(v[i]);\n'
        '        if (i < v.size() - 1) cout << ", ";\n'
        '    }\n'
        '    cout << "]";\n'
        '}\n\n'
        'template<typename K, typename V> void print_val(const map<K, V>& m) {\n'
        '    cout << "{";\n'
        '    size_t i = 0;\n'
        '    for (typename map<K, V>::const_iterator it = m.begin(); it != m.end(); ++it) {\n'
        '        print_val(it->first); cout << ": "; print_val(it->second);\n'
        '        if (++i < m.size()) cout << ", ";\n'
        '    }\n'
        '    cout << "}";\n'
        '}\n\n';

    if (!isSubmission) {
      final args = _simpleArgs(p.testCases.first.input);
      return '${inc}$code\n\nint main() {\n    print_val(${p.functionName}($args));\n    cout << endl;\n    return 0;\n}\n';
    }
    String main = '\n\nint main() {\n';
    for (final tc in p.testCases) {
      final args = _simpleArgs(tc.input);
      main += '    cout << "---CASE_START---" << endl;\n'
          '    print_val(${p.functionName}($args));\n'
          '    cout << endl << "---CASE_END---" << endl;\n';
    }
    return '$inc$code${main}    return 0;\n}\n';
  }

  static String _javaArgs(String input) {
    final parts = input.split('\n');
    final formatted = parts.map((part) {
      part = part.trim();
      if (part.startsWith('[') && part.endsWith(']')) {
        if (part.startsWith('[[') && part.endsWith(']]')) {
          String inner = part.replaceAll('[', '{').replaceAll(']', '}');
          if (part.contains('"') || part.contains("'")) {
            return 'new String[][]$inner';
          }
          return 'new int[][]$inner';
        } else {
          String inner = part.replaceAll('[', '{').replaceAll(']', '}');
          if (part.contains('"') || part.contains("'")) {
            return 'new String[]$inner';
          }
          return 'new int[]$inner';
        }
      }
      return part;
    }).join(', ');
    return formatted;
  }

  static String _javaHarness(Problem p, String code, bool isSubmission) {
    const inc = 'import java.util.*;\n\n';
    const helper = '    static void print_val(Object o) {\n'
        '        if (o == null) { System.out.print("null"); }\n'
        '        else if (o instanceof int[]) { System.out.print(Arrays.toString((int[])o)); }\n'
        '        else if (o instanceof int[][]) { System.out.print(Arrays.deepToString((int[][])o)); }\n'
        '        else if (o instanceof String[]) { System.out.print(Arrays.toString((String[])o)); }\n'
        '        else if (o instanceof Object[]) { System.out.print(Arrays.deepToString((Object[])o)); }\n'
        '        else { System.out.print(o); }\n'
        '    }\n';

    if (!isSubmission) {
      final args = _javaArgs(p.testCases.first.input);
      return '${inc}public class main {\n$helper\n    $code\n\n    public static void main(String[] args) {\n        print_val(${p.functionName}($args));\n        System.out.println();\n    }\n}\n';
    }
    String main = '\n    public static void main(String[] args) {\n';
    for (final tc in p.testCases) {
      final args = _javaArgs(tc.input);
      main += '        System.out.println("---CASE_START---");\n'
          '        try {\n'
          '            print_val(${p.functionName}($args));\n'
          '            System.out.println();\n'
          '        } catch (Exception e) {\n'
          '            System.out.println("ERROR: " + e.getMessage());\n'
          '        }\n'
          '        System.out.println("---CASE_END---");\n';
    }
    return '${inc}public class main {\n$helper\n    $code\n$main    }\n}\n';
  }

  static String _jsHarness(Problem p, String code, bool isSubmission) {
    if (!isSubmission) {
      final args = p.testCases.first.input.replaceAll('\n', ', ');
      return '$code\n\nconsole.log(JSON.stringify(${p.functionName}($args)));\n';
    }
    String h = '\n';
    for (final tc in p.testCases) {
      final args = tc.input.replaceAll('\n', ', ');
      h += 'console.log("---CASE_START---");\ntry {\n    let result = ${p.functionName}($args);\n    console.log(result !== undefined ? JSON.stringify(result) : "null");\n} catch(e) {\n    console.log("ERROR: " + e.message);\n}\nconsole.log("---CASE_END---");\n';
    }
    return code + h;
  }

  static String _simpleArgs(String input) => input.replaceAll('\n', ', ');

  // ── Codapi API call ───────────────────────────────────────────────────────────
  static Future<ExecutionResult> _runViaCodapi(
    Problem problem, String code, Map<String, String> sandbox, bool isSubmission
  ) async {
    try {
      final response = await http.post(
        Uri.parse(_codapiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sandbox': sandbox['sandbox'],
          'command': 'run',
          'files': {sandbox['file']!: code},
        }),
      ).timeout(const Duration(seconds: 20), onTimeout: () {
        throw Exception('Execution timeout');
      });

      if (response.body.isEmpty) {
        return _errorResult('Empty API response');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final stdout = (data['stdout'] ?? '').toString().trim();
        final stderr = (data['stderr'] ?? '').toString().trim();

        if (stderr.isNotEmpty && stdout.isEmpty) return _errorResult(stderr);

        if (!isSubmission) {
          return ExecutionResult(
            status: SubmissionStatus.pending,
            passedCount: 0, totalCount: 0, runtimeMs: 0, memoryMb: 0,
            stdout: stdout.isNotEmpty ? stdout : stderr,
            stderr: stderr, testResults: [], xpEarned: 0,
          );
        }
        return _validateSubmission(problem, stdout, stderr);
      }
      return _errorResult('API Error (${response.statusCode})');
    } catch (e) {
      return _errorResult('Connection failed: $e');
    }
  }

  // ── Validate submission results ───────────────────────────────────────────────
  static ExecutionResult _validateSubmission(Problem problem, String stdout, String stderr) {
    final testResults = <TestResult>[];
    int passed = 0;

    final parts = stdout.split('---CASE_START---');
    if (parts.isEmpty) {
      return _errorResult('Invalid execution output format');
    }

    for (int i = 0; i < problem.testCases.length; i++) {
      final tc = problem.testCases[i];
      String actual = 'No output';
      
      if (i + 1 < parts.length) {
        final caseOutput = parts[i + 1].split('---CASE_END---');
        if (caseOutput.isNotEmpty) {
          actual = caseOutput.first.trim();
        }
      }

      final expected = tc.expectedOutput.trim();
      final norm = (String s) {
        var str = s.toLowerCase().replaceAll(RegExp(r'\s+'), '');
        str = str.replaceAll('"', '').replaceAll("'", "");
        if (str == 'none' || str == 'undefined' || str == 'null') return 'null';
        if (str == 'true' || str == '1') return 'true';
        if (str == 'false' || str == '0') return 'false';
        return str;
      };
      
      final isCasePassed = norm(actual) == norm(expected);
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
      passedCount: passed, totalCount: problem.testCases.length,
      runtimeMs: 15, memoryMb: 12.0,
      stdout: stdout, stderr: stderr,
      testResults: testResults,
      xpEarned: allPassed ? problem.xpReward : 0,
    );
  }

  static ExecutionResult _errorResult(String message) => ExecutionResult(
    status: SubmissionStatus.error, passedCount: 0, totalCount: 0,
    runtimeMs: 0, memoryMb: 0, stdout: '', stderr: message,
    testResults: [], xpEarned: 0,
  );
}
