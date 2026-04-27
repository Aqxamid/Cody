import '../models/models.dart';
import '../services/problem_service.dart';

class ProblemBank {
  static List<Problem> problems = [
    // ── LEVEL 1: BASICS ─────────────────────────────────────────────────────
    Problem(
      id: 'sum_two',
      title: 'Sum of two numbers',
      difficulty: Difficulty.easy,
      tags: ['Math', 'Basics'],
      xpReward: 50,
      functionName: 'solve',
      description: 'Given two integers a and b, return their sum.',
      examples: [ProblemExample(input: 'a = 5, b = 3', output: '8')],
      testCases: [
        TestCase(input: '5, 3', expectedOutput: '8'),
        TestCase(input: '-1, -1', expectedOutput: '-2'),
        TestCase(input: '0, 0', expectedOutput: '0', isHidden: true),
      
        TestCase(input: '1000000, 999999', expectedOutput: '1999999', isHidden: true),
      ],
      constraints: '-10⁹ ≤ a, b ≤ 10⁹',
      starterCode: {
        'Python': 'def solve(a, b):\n    # Implement here\n    return 0',
        'Dart': 'int solve(int a, int b) {\n  // Implement here\n  return 0;\n}',
      
        'C': 'int solve(int a, int b) {\n    // Implement here\n    return 0;\n}',
        'C++': 'int solve(int a, int b) {\n    // Implement here\n    return 0;\n}',
        'Java': 'public static int solve(int a, int b) {\n    // Implement here\n    return 0;\n}',
        'JavaScript': 'function solve(a, b) {\n    // Implement here\n    return 0;\n}',
      },
    ),
    Problem(
      id: 'even_odd',
      title: 'Check even or odd',
      difficulty: Difficulty.easy,
      tags: ['Basics', 'Logic'],
      xpReward: 50,
      functionName: 'solve',
      description: 'Given an integer n, return "Even" if the number is even, or "Odd" if it is odd.',
      examples: [ProblemExample(input: 'n = 4', output: 'Even')],
      testCases: [
        TestCase(input: '4', expectedOutput: 'Even'),
        TestCase(input: '7', expectedOutput: 'Odd'),
        TestCase(input: '0', expectedOutput: 'Even', isHidden: true),
        TestCase(input: '-3', expectedOutput: 'Odd', isHidden: true),
      ],
      constraints: '-10⁹ ≤ n ≤ 10⁹',
      starterCode: {
        'Python': 'def solve(n):\n    # Implement here\n    return ""',
        'Dart': 'String solve(int n) {\n  // Implement here\n  return "";\n}',
      
        'C': 'char* solve(int n) {\n    // Return "Even" or "Odd"\n    return "";\n}',
        'C++': 'string solve(int n) {\n    // Return "Even" or "Odd"\n    return "";\n}',
        'Java': 'public static String solve(int n) {\n    // Implement here\n    return "";\n}',
        'JavaScript': 'function solve(n) {\n    // Return "Even" or "Odd"\n    return "";\n}',
      },
    ),
    Problem(
      id: 'largest_three',
      title: 'Largest of three numbers',
      difficulty: Difficulty.easy,
      tags: ['Logic', 'Basics'],
      xpReward: 50,
      functionName: 'solve',
      description: 'Given three integers a, b, and c, return the largest one.',
      examples: [ProblemExample(input: '1, 5, 3', output: '5')],
      testCases: [
        TestCase(input: '1, 5, 3', expectedOutput: '5'),
        TestCase(input: '-1, -5, -3', expectedOutput: '-1'),
        TestCase(input: '7, 7, 7', expectedOutput: '7', isHidden: true),
      ],
      constraints: '-10⁹ ≤ a, b, c ≤ 10⁹',
      starterCode: {
        'Python': 'def solve(a, b, c):\n    # Implement here\n    return 0',
        'Dart': 'int solve(int a, int b, int c) {\n  // Implement here\n  return 0;\n}',
      
        'C': 'int solve(int a, int b, int c) {\n    // Implement here\n    return 0;\n}',
        'C++': 'int solve(int a, int b, int c) {\n    // Implement here\n    return 0;\n}',
        'Java': 'public static int solve(int a, int b, int c) {\n    // Implement here\n    return 0;\n}',
        'JavaScript': 'function solve(a, b, c) {\n    // Implement here\n    return 0;\n}',
      },
    ),
    Problem(
      id: 'reverse_string',
      title: 'Reverse a string',
      difficulty: Difficulty.easy,
      tags: ['String', 'Basics'],
      xpReward: 50,
      functionName: 'solve',
      description: 'Given a string s, return the reversed string.',
      examples: [ProblemExample(input: 's = "hello"', output: '"olleh"')],
      testCases: [
        TestCase(input: '"hello"', expectedOutput: 'olleh'),
        TestCase(input: '"a"', expectedOutput: 'a'),
        TestCase(input: '"racecar"', expectedOutput: 'racecar', isHidden: true),
      ],
      constraints: '1 ≤ s.length ≤ 1000',
      starterCode: {
        'Python': 'def solve(s):\n    # Implement here\n    return ""',
        'Dart': 'String solve(String s) {\n  // Implement here\n  return "";\n}',
      
        'C': 'char* solve(char* s) {\n    // Implement here\n    return s;\n}',
        'C++': 'string solve(string s) {\n    // Implement here\n    return "";\n}',
        'Java': 'public static String solve(String s) {\n    // Implement here\n    return "";\n}',
        'JavaScript': 'function solve(s) {\n    // Implement here\n    return "";\n}',
      },
    ),
    Problem(
      id: 'count_vowels',
      title: 'Count vowels in a string',
      difficulty: Difficulty.easy,
      tags: ['String', 'Logic'],
      xpReward: 50,
      functionName: 'solve',
      description: 'Count the number of vowels (a, e, i, o, u) in a given string s.',
      examples: [ProblemExample(input: 's = "coding"', output: '2')],
      testCases: [
        TestCase(input: '"coding"', expectedOutput: '2'),
        TestCase(input: '"aeiou"', expectedOutput: '5'),
        TestCase(input: '"xyz"', expectedOutput: '0', isHidden: true),
      ],
      constraints: '1 ≤ s.length ≤ 1000',
      starterCode: {
        'Python': 'def solve(s):\n    # Implement here\n    return 0',
        'Dart': 'int solve(String s) {\n  // Implement here\n  return 0;\n}',
      
        'C': 'int solve(char* s) {\n    // Implement here\n    return 0;\n}',
        'C++': 'int solve(string s) {\n    // Implement here\n    return 0;\n}',
        'Java': 'public static int solve(String s) {\n    // Implement here\n    return 0;\n}',
        'JavaScript': 'function solve(s) {\n    // Implement here\n    return 0;\n}',
      },
    ),
    Problem(
      id: 'factorial',
      title: 'Factorial (iterative and recursive)',
      difficulty: Difficulty.easy,
      tags: ['Math', 'Recursion'],
      xpReward: 60,
      functionName: 'factorial',
      description: 'Return the factorial of a non-negative integer n.',
      examples: [ProblemExample(input: 'n = 5', output: '120')],
      testCases: [
        TestCase(input: '5', expectedOutput: '120'),
        TestCase(input: '0', expectedOutput: '1'),
        TestCase(input: '10', expectedOutput: '3628800', isHidden: true),
      ],
      constraints: '0 ≤ n ≤ 20',
      starterCode: {
        'Python': 'def factorial(n):\n    # Implement here\n    return 1',
        'Dart': 'int factorial(int n) {\n  // Implement here\n  return 1;\n}',
      
        'C': 'long long factorial(int n) {\n    // Implement here\n    return 1;\n}',
        'C++': 'long long factorial(int n) {\n    // Implement here\n    return 1;\n}',
        'Java': 'public static long factorial(int n) {\n    // Implement here\n    return 1;\n}',
        'JavaScript': 'function factorial(n) {\n    // Implement here\n    return 1;\n}',
      },
    ),
    Problem(
      id: 'fibonacci',
      title: 'Fibonacci sequence (n terms)',
      difficulty: Difficulty.easy,
      tags: ['Math', 'Basics'],
      xpReward: 60,
      functionName: 'solve',
      description: 'Return the first n terms of the Fibonacci sequence.',
      examples: [ProblemExample(input: 'n = 5', output: '[0, 1, 1, 2, 3]')],
      testCases: [
        TestCase(input: '5', expectedOutput: '0 1 1 2 3'),
        TestCase(input: '1', expectedOutput: '0'),
        TestCase(input: '8', expectedOutput: '0 1 1 2 3 5 8 13', isHidden: true),
      ],
      constraints: '1 ≤ n ≤ 50',
      starterCode: {
        'Python': 'def solve(n):\n    # Implement here\n    return []',
        'Dart': 'List<int> solve(int n) {\n  // Implement here\n  return [];\n}',
      
        'JavaScript': 'function solve(n) {\n    // Return array of first n Fibonacci numbers\n    return [];\n}',
      },
    ),
    Problem(
      id: 'check_prime',
      title: 'Check prime number',
      difficulty: Difficulty.easy,
      tags: ['Math', 'Logic'],
      xpReward: 60,
      functionName: 'isPrime',
      description: 'Determine if an integer n is a prime number.',
      examples: [ProblemExample(input: 'n = 7', output: 'true')],
      testCases: [
        TestCase(input: '7', expectedOutput: 'true'),
        TestCase(input: '1', expectedOutput: 'false'),
        TestCase(input: '2', expectedOutput: 'true', isHidden: true),
        TestCase(input: '100', expectedOutput: 'false', isHidden: true),
      ],
      constraints: '1 ≤ n ≤ 10⁹',
      starterCode: {
        'Python': 'def isPrime(n):\n    # Implement here\n    return False',
        'Dart': 'bool isPrime(int n) {\n  // Implement here\n  return false;\n}',
      
        'C': 'bool isPrime(int n) {\n    // Implement here\n    return false;\n}',
        'C++': 'bool isPrime(int n) {\n    // Implement here\n    return false;\n}',
        'Java': 'public static boolean isPrime(int n) {\n    // Implement here\n    return false;\n}',
        'JavaScript': 'function isPrime(n) {\n    // Implement here\n    return false;\n}',
      },
    ),
    Problem(
      id: 'celsius_fahrenheit',
      title: 'Celsius to Fahrenheit conversion',
      difficulty: Difficulty.easy,
      tags: ['Math', 'Basics'],
      xpReward: 50,
      functionName: 'solve',
      description: 'Convert Celsius to Fahrenheit.',
      examples: [ProblemExample(input: '0', output: '32.0')],
      testCases: [
        TestCase(input: '0', expectedOutput: '32.0'),
        TestCase(input: '100', expectedOutput: '212.0'),
        TestCase(input: '-40', expectedOutput: '-40.0', isHidden: true),
      ],
      constraints: '-273.15 ≤ c ≤ 1000',
      starterCode: {
        'Python': 'def solve(c):\n    # Implement here\n    return 0.0',
        'Dart': 'double solve(double c) {\n  // Implement here\n  return 0.0;\n}',
      
        'C++': 'double solve(double c) {\n    // Implement here\n    return 0.0;\n}',
        'Java': 'public static double solve(double c) {\n    // Implement here\n    return 0.0;\n}',
        'JavaScript': 'function solve(c) {\n    // Implement here\n    return 0.0;\n}',
      },
    ),
    Problem(
      id: 'sum_digits',
      title: 'Sum of digits of a number',
      difficulty: Difficulty.easy,
      tags: ['Math', 'Logic'],
      xpReward: 50,
      functionName: 'solve',
      description: 'Calculate the sum of digits of a positive integer n.',
      examples: [ProblemExample(input: '123', output: '6')],
      testCases: [
        TestCase(input: '123', expectedOutput: '6'),
        TestCase(input: '0', expectedOutput: '0'),
        TestCase(input: '9999', expectedOutput: '36', isHidden: true),
      ],
      constraints: '0 ≤ n ≤ 10⁹',
      starterCode: {
        'Python': 'def solve(n):\n    # Implement here\n    return 0',
        'Dart': 'int solve(int n) {\n  // Implement here\n  return 0;\n}',
      
        'C': 'int solve(int n) {\n    // Implement here\n    return 0;\n}',
        'C++': 'int solve(int n) {\n    // Implement here\n    return 0;\n}',
        'Java': 'public static int solve(int n) {\n    // Implement here\n    return 0;\n}',
        'JavaScript': 'function solve(n) {\n    // Implement here\n    return 0;\n}',
      },
    ),

    // ── LEVEL 2: ARRAYS & STRINGS ───────────────────────────────────────────
    Problem(
      id: 'max_array',
      title: 'Find maximum in an array',
      difficulty: Difficulty.easy,
      tags: ['Array'],
      xpReward: 70,
      functionName: 'solve',
      description: 'Find the largest number in an array.',
      examples: [ProblemExample(input: '[1, 5, 3]', output: '5')],
      testCases: [TestCase(input: '[1, 5, 3]', expectedOutput: '5'),
        TestCase(input: '[-3, -1, -2]', expectedOutput: '-1'),
        TestCase(input: '[42]', expectedOutput: '42', isHidden: true),
      ],
      constraints: '1 ≤ length ≤ 10⁴',
      starterCode: {
        'Python': 'def solve(nums):\n    # Implement here\n    return 0',
        'Dart': 'int solve(List<int> nums) {\n  // Implement here\n  return 0;\n}',
      },
    ),
    Problem(
      id: 'remove_duplicates',
      title: 'Remove duplicates from array',
      difficulty: Difficulty.easy,
      tags: ['Array'],
      xpReward: 70,
      functionName: 'solve',
      description: 'Return array with duplicates removed.',
      examples: [ProblemExample(input: '[1, 2, 2]', output: '[1, 2]')],
      testCases: [TestCase(input: '[1, 2, 2]', expectedOutput: '[1, 2]')],
      constraints: '0 ≤ length ≤ 10⁴',
      starterCode: {
        'Python': 'def solve(nums):\n    # Implement here\n    return []',
        'Dart': 'List<int> solve(List<int> nums) {\n  // Implement here\n  return [];\n}',
      },
    ),
    Problem(
      id: 'sort_array',
      title: 'Sort array (without built-in sort)',
      difficulty: Difficulty.easy,
      tags: ['Array', 'Algorithm'],
      xpReward: 80,
      functionName: 'solve',
      description: 'Sort an array using any algorithm.',
      examples: [ProblemExample(input: '[5, 2, 1]', output: '[1, 2, 5]')],
      testCases: [TestCase(input: '[5, 2, 1]', expectedOutput: '[1, 2, 5]')],
      constraints: '1 ≤ length ≤ 1000',
      starterCode: {
        'Python': 'def solve(nums):\n    # Implement here\n    return []',
        'Dart': 'List<int> solve(List<int> nums) {\n  // Implement here\n  return [];\n}',
      },
    ),
    Problem(
      id: 'second_largest',
      title: 'Find second largest number',
      difficulty: Difficulty.easy,
      tags: ['Array'],
      xpReward: 75,
      functionName: 'solve',
      description: 'Find the second largest number in an array.',
      examples: [ProblemExample(input: '[10, 5, 8]', output: '8')],
      testCases: [TestCase(input: '[10, 5, 8]', expectedOutput: '8')],
      constraints: '2 ≤ length ≤ 10⁴',
      starterCode: {
        'Python': 'def solve(nums):\n    # Implement here\n    return 0',
        'Dart': 'int solve(List<int> nums) {\n  // Implement here\n  return 0;\n}',
      },
    ),
    Problem(
      id: 'merge_arrays',
      title: 'Merge two arrays',
      difficulty: Difficulty.easy,
      tags: ['Array'],
      xpReward: 70,
      functionName: 'solve',
      description: 'Combine two arrays.',
      examples: [ProblemExample(input: '[1],[2]', output: '[1,2]')],
      testCases: [TestCase(input: '[1]\n[2]', expectedOutput: '[1, 2]')],
      constraints: '0 ≤ length ≤ 10⁴',
      starterCode: {
        'Python': 'def solve(a, b):\n    # Implement here\n    return []',
        'Dart': 'List<int> solve(List<int> a, List<int> b) {\n  // Implement here\n  return [];\n}',
      },
    ),
    Problem(
      id: 'count_freq',
      title: 'Count frequency of elements',
      difficulty: Difficulty.easy,
      tags: ['Array', 'Map'],
      xpReward: 75,
      functionName: 'solve',
      description: 'Count element frequency.',
      examples: [ProblemExample(input: '[1, 1]', output: '{1: 2}')],
      testCases: [TestCase(input: '[1, 1]', expectedOutput: '{1: 2}')],
      constraints: '0 ≤ length ≤ 10⁴',
      starterCode: {
        'Python': 'def solve(nums):\n    # Implement here\n    return {}',
        'Dart': 'Map<int, int> solve(List<int> nums) {\n  // Implement here\n  return {};\n}',
      },
    ),
    Problem(
      id: 'is_palindrome',
      title: 'Check palindrome string',
      difficulty: Difficulty.easy,
      tags: ['String'],
      xpReward: 60,
      functionName: 'solve',
      description: 'Is it a palindrome?',
      examples: [ProblemExample(input: 'madam', output: 'true')],
      testCases: [
        TestCase(input: '"madam"', expectedOutput: 'true'),
        TestCase(input: '"racecar"', expectedOutput: 'true', isHidden: true),
        TestCase(input: '"hello"', expectedOutput: 'false'),
      ],
      constraints: '0 ≤ length ≤ 10⁴',
      starterCode: {
        'Python': 'def solve(s):\n    # Implement here\n    return False',
        'Dart': 'bool solve(String s) {\n  // Implement here\n  return false;\n}',
      
        'C++': 'bool solve(string s) {\n    // Implement here\n    return false;\n}',
        'Java': 'public static boolean solve(String s) {\n    // Implement here\n    return false;\n}',
        'JavaScript': 'function solve(s) {\n    // Implement here\n    return false;\n}',
      },
    ),
    Problem(
      id: 'all_substrings',
      title: 'Generate all substrings',
      difficulty: Difficulty.easy,
      tags: ['String'],
      xpReward: 80,
      functionName: 'solve',
      description: 'Generate every possible substring.',
      examples: [ProblemExample(input: 'abc', output: 'a, ab, abc, b, bc, c')],
      testCases: [
        TestCase(input: '"abc"', expectedOutput: 'a, ab, abc, b, bc, c'),
        TestCase(input: '"a"', expectedOutput: 'a', isHidden: true),
      ],
      constraints: '1 ≤ length ≤ 50',
      starterCode: {
        'Python': 'def solve(s):\n    # Implement here\n    return []',
        'Dart': 'List<String> solve(String s) {\n  // Implement here\n  return [];\n}',
      },
    ),
    Problem(
      id: 'rotate_array',
      title: 'Rotate array by k steps',
      difficulty: Difficulty.easy,
      tags: ['Array'],
      xpReward: 80,
      functionName: 'solve',
      description: 'Rotate right by k steps.',
      examples: [ProblemExample(input: '[1,2,3], 1', output: '[3,1,2]')],
      testCases: [TestCase(input: '[1,2,3]\n1', expectedOutput: '[3, 1, 2]')],
      constraints: '1 ≤ length, k ≤ 10⁵',
      starterCode: {
        'Python': 'def solve(nums, k):\n    # Implement here\n    return []',
        'Dart': 'List<int> solve(List<int> nums, int k) {\n  // Implement here\n  return [];\n}',
      },
    ),
    Problem(
      id: 'move_zeros',
      title: 'Move zeros to the end',
      difficulty: Difficulty.easy,
      tags: ['Array'],
      xpReward: 80,
      functionName: 'solve',
      description: 'Maintain order, but zeros to back.',
      examples: [ProblemExample(input: '[0, 1]', output: '[1, 0]')],
      testCases: [TestCase(input: '[0, 1]', expectedOutput: '[1, 0]')],
      constraints: '1 ≤ length ≤ 10⁴',
      starterCode: {
        'Python': 'def solve(nums):\n    # Implement here\n    return []',
        'Dart': 'List<int> solve(List<int> nums) {\n  // Implement here\n  return [];\n}',
      },
    ),

    // ── LEVEL 3: PROBLEM SOLVING PATTERNS ───────────────────────────────────
    Problem(
      id: 'two_sum_3',
      title: 'Two Sum (sorted and unsorted)',
      difficulty: Difficulty.medium,
      tags: ['Two Pointers', 'Hashing'],
      xpReward: 100,
      functionName: 'solve',
      description: 'Find indices of two numbers that add up to target.',
      examples: [ProblemExample(input: 'nums=[2,7], target=9', output: '[0,1]')],
      testCases: [TestCase(input: '[2,7]\n9', expectedOutput: '[0, 1]'),
        TestCase(input: '[3,2,4]\n6', expectedOutput: '[1, 2]'),
        TestCase(input: '[3,3]\n6', expectedOutput: '[0, 1]', isHidden: true),
      ],
      constraints: '2 ≤ length ≤ 10⁵',
      starterCode: {
        'Python': 'def solve(nums, target):\n    # Implement here\n    return []',
        'Dart': 'List<int> solve(List<int> nums, int target) {\n  // Implement here\n  return [];\n}',
      
        'JavaScript': 'function solve(nums, target) {\n    // Implement here\n    return [];\n}',
      },
    ),
    Problem(
      id: 'rm_dups_sorted',
      title: 'Remove duplicates from sorted array',
      difficulty: Difficulty.medium,
      tags: ['Two Pointers'],
      xpReward: 90,
      functionName: 'solve',
      description: 'Remove duplicates in-place.',
      examples: [ProblemExample(input: '[1, 1, 2]', output: '2, [1, 2]')],
      testCases: [TestCase(input: '[1, 1, 2]', expectedOutput: '2')],
      constraints: '0 ≤ length ≤ 10⁵',
      starterCode: {
        'Python': 'def solve(nums):\n    # Implement here\n    return 0',
        'Dart': 'int solve(List<int> nums) {\n  // Implement here\n  return 0;\n}',
      },
    ),
    Problem(
      id: 'container_water',
      title: 'Container with most water',
      difficulty: Difficulty.medium,
      tags: ['Two Pointers'],
      xpReward: 110,
      functionName: 'solve',
      description: 'Find two lines that form a container with most water.',
      examples: [ProblemExample(input: '[1,8,6,2,5,4,8,3,7]', output: '49')],
      testCases: [TestCase(input: '[1,8,6,2,5,4,8,3,7]', expectedOutput: '49'),
        TestCase(input: '[1,1]', expectedOutput: '1'),
        TestCase(input: '[4,3,2,1,4]', expectedOutput: '16', isHidden: true),
      ],
      constraints: 'n ≤ 10⁵',
      starterCode: {
        'Python': 'def solve(h):\n    # Implement here\n    return 0',
        'Dart': 'int solve(List<int> h) {\n  // Implement here\n  return 0;\n}',
      },
    ),
    Problem(
      id: 'max_sum_k',
      title: 'Maximum sum subarray of size k',
      difficulty: Difficulty.medium,
      tags: ['Sliding Window'],
      xpReward: 100,
      functionName: 'solve',
      description: 'Largest sum of size k.',
      examples: [ProblemExample(input: '[2,1,5,1,3,2], 3', output: '9')],
      testCases: [TestCase(input: '[2,1,5,1,3,2]\n3', expectedOutput: '9'),
        TestCase(input: '[1,1,1,1]\n2', expectedOutput: '2'),
        TestCase(input: '[5,5,5,5,5]\n3', expectedOutput: '15', isHidden: true),
      ],
      constraints: 'k ≤ length',
      starterCode: {
        'Python': 'def solve(nums, k):\n    # Implement here\n    return 0',
        'Dart': 'int solve(List<int> nums, int k) {\n  // Implement here\n  return 0;\n}',
      
        'JavaScript': 'function solve(nums, k) {\n    // Implement here\n    return 0;\n}',
        'Java': 'public static int solve(int[] nums, int k) {\n    // Implement here\n    return 0;\n}',
      },
    ),
    Problem(
      id: 'longest_substring',
      title: 'Longest substring without repeating characters',
      difficulty: Difficulty.medium,
      tags: ['Sliding Window'],
      xpReward: 120,
      functionName: 'solve',
      description: 'Find length of longest substring without repeats.',
      examples: [ProblemExample(input: 'abcabcbb', output: '3')],
      testCases: [
        TestCase(input: '"abcabcbb"', expectedOutput: '3'),
        TestCase(input: '"bbbbb"', expectedOutput: '1'),
        TestCase(input: '"pwwkew"', expectedOutput: '3', isHidden: true),
      ],
      constraints: 'n ≤ 10⁵',
      starterCode: {
        'Python': 'def solve(s):\n    # Implement here\n    return 0',
        'Dart': 'int solve(String s) {\n  // Implement here\n  return 0;\n}',
      
        'C': 'int solve(char* s) {\n    // Implement here\n    return 0;\n}',
        'C++': 'int solve(string s) {\n    // Implement here\n    return 0;\n}',
        'Java': 'public static int solve(String s) {\n    // Implement here\n    return 0;\n}',
        'JavaScript': 'function solve(s) {\n    // Implement here\n    return 0;\n}',
      },
    ),
    Problem(
      id: 'min_window',
      title: 'Minimum window substring',
      difficulty: Difficulty.hard,
      tags: ['Sliding Window'],
      xpReward: 150,
      functionName: 'solve',
      description: 'Find smallest substring containing all characters of target.',
      examples: [ProblemExample(input: 'ADOBECODEBANC, ABC', output: 'BANC')],
      testCases: [
        TestCase(input: '"ADOBECODEBANC"\n"ABC"', expectedOutput: 'BANC'),
        TestCase(input: '"a"\n"a"', expectedOutput: 'a'),
        TestCase(input: '"a"\n"b"', expectedOutput: '', isHidden: true),
      ],
      constraints: 'n ≤ 10⁵',
      starterCode: {
        'Python': 'def solve(s, t):\n    # Implement here\n    return ""',
        'Dart': 'String solve(String s, String t) {\n  // Implement here\n  return "";\n}',
      },
    ),
    Problem(
      id: 'first_non_repeat',
      title: 'First non-repeating character',
      difficulty: Difficulty.easy,
      tags: ['Hashing'],
      xpReward: 70,
      functionName: 'solve',
      description: 'Return index of first non-repeating char.',
      examples: [ProblemExample(input: 'leetcode', output: '0')],
      testCases: [TestCase(input: '"leetcode"', expectedOutput: '0')],
      constraints: 'n ≤ 10⁵',
      starterCode: {
        'Python': 'def solve(s):\n    # Implement here\n    return -1',
        'Dart': 'int solve(String s) {\n  // Implement here\n  return -1;\n}',
      },
    ),
    Problem(
      id: 'group_anagrams_3',
      title: 'Group anagrams',
      difficulty: Difficulty.medium,
      tags: ['Hashing'],
      xpReward: 110,
      functionName: 'solve',
      description: 'Group them together.',
      examples: [ProblemExample(input: 'eat,tea,tan', output: '[[eat,tea],[tan]]')],
      testCases: [TestCase(input: 'eat tea tan', expectedOutput: '[["eat", "tea"], ["tan"]]')],
      constraints: 'n ≤ 10⁴',
      starterCode: {
        'Python': 'def solve(strs):\n    # Implement here\n    return []',
        'Dart': 'List<List<String>> solve(List<String> strs) {\n  // Implement here\n  return [];\n}',
      },
    ),
    Problem(
      id: 'find_dups',
      title: 'Find duplicates in array',
      difficulty: Difficulty.medium,
      tags: ['Hashing'],
      xpReward: 90,
      functionName: 'solve',
      description: 'Find all elements that appear twice.',
      examples: [ProblemExample(input: '[4,3,2,7,8,2,3,1]', output: '[2,3]')],
      testCases: [TestCase(input: '[4,3,2,7,8,2,3,1]', expectedOutput: '[2, 3]')],
      constraints: 'n ≤ 10⁵',
      starterCode: {
        'Python': 'def solve(nums):\n    # Implement here\n    return []',
        'Dart': 'List<int> solve(List<int> nums) {\n  // Implement here\n  return [];\n}',
      },
    ),

    // ── LEVEL 4: RECURSION & BACKTRACKING ───────────────────────────────────
    Problem(
      id: 'pow_x_n',
      title: 'Power function (xⁿ)',
      difficulty: Difficulty.medium,
      tags: ['Recursion'],
      xpReward: 100,
      functionName: 'my_pow',
      description: 'Implement pow(x, n).',
      examples: [ProblemExample(input: '2, 10', output: '1024.0')],
      testCases: [TestCase(input: '2\n10', expectedOutput: '1024.0')],
      constraints: '-100 < x < 100, -2³¹ ≤ n ≤ 2³¹-1',
      starterCode: {
        'Python': 'def my_pow(x, n):\n    # Implement here\n    return 0.0',
        'Dart': 'double my_pow(double x, int n) {\n  // Implement here\n  return 0.0;\n}',
      },
    ),
    Problem(
      id: 'perms_string',
      title: 'Generate permutations of a string',
      difficulty: Difficulty.medium,
      tags: ['Recursion'],
      xpReward: 130,
      functionName: 'solve',
      description: 'Return all permutations.',
      examples: [ProblemExample(input: 'abc', output: 'abc, acb, bac, bca, cab, cba')],
      testCases: [TestCase(input: '"abc"', expectedOutput: 'abc acb bac bca cab cba')],
      constraints: '1 ≤ n ≤ 8',
      starterCode: {
        'Python': 'def solve(s):\n    # Implement here\n    return []',
        'Dart': 'List<String> solve(String s) {\n  // Implement here\n  return [];\n}',
      },
    ),
    Problem(
      id: 'subsets_power',
      title: 'Generate subsets (power set)',
      difficulty: Difficulty.medium,
      tags: ['Backtracking'],
      xpReward: 120,
      functionName: 'solve',
      description: 'Return all possible subsets.',
      examples: [ProblemExample(input: '[1,2]', output: '[[],[1],[2],[1,2]]')],
      testCases: [TestCase(input: '[1,2]', expectedOutput: '[[], [1], [2], [1, 2]]')],
      constraints: 'n ≤ 10',
      starterCode: {
        'Python': 'def solve(nums):\n    # Implement here\n    return []',
        'Dart': 'List<List<int>> solve(List<int> nums) {\n  // Implement here\n  return [];\n}',
      },
    ),
    
    
    Problem(
      id: 'combination_sum',
      title: 'Combination sum',
      difficulty: Difficulty.medium,
      tags: ['Backtracking'],
      xpReward: 120,
      functionName: 'solve',
      description: 'Find all unique combinations of candidates that sum to target.',
      examples: [ProblemExample(input: '[2,3,6,7], 7', output: '[[2,2,3],[7]]')],
      testCases: [TestCase(input: '[2,3,6,7]\n7', expectedOutput: '[[2, 2, 3], [7]]')],
      constraints: 'n ≤ 30',
      starterCode: {
        'Python': 'def solve(nums, target):\n    # Implement here\n    return []',
        'Dart': 'List<List<int>> solve(List<int> nums, int target) {\n  // Implement here\n  return [];\n}',
      },
    ),

    // ── LEVEL 5: DATA STRUCTURES ────────────────────────────────────────────
    
    Problem(
      id: 'valid_parens_5',
      title: 'Valid parentheses checker',
      difficulty: Difficulty.medium,
      tags: ['Stack'],
      xpReward: 80,
      functionName: 'solve',
      description: 'Check bracket validity.',
      examples: [ProblemExample(input: '()', output: 'true')],
      testCases: [
        TestCase(input: '"()"', expectedOutput: 'true'),
        TestCase(input: '"([{}])"', expectedOutput: 'true'),
        TestCase(input: '"(]"', expectedOutput: 'false', isHidden: true),
        TestCase(input: '"{[()]}"', expectedOutput: 'true', isHidden: true),
      ],
      constraints: 'n < 10⁴',
      starterCode: {
        'Python': 'def solve(s):\n    # Implement here\n    return False',
        'Dart': 'bool solve(String s) {\n  // Implement here\n  return false;\n}',
      
        'C++': 'bool solve(string s) {\n    // Implement here\n    return false;\n}',
        'Java': 'public static boolean solve(String s) {\n    // Implement here\n    return false;\n}',
        'JavaScript': 'function solve(s) {\n    // Implement here\n    return false;\n}',
      },
    ),
    Problem(
      id: 'next_greater',
      title: 'Next greater element',
      difficulty: Difficulty.hard,
      tags: ['Stack'],
      xpReward: 140,
      functionName: 'solve',
      description: 'Find the next greater element for each item in array.',
      examples: [ProblemExample(input: '[4,1,2],[1,3,4,2]', output: '[-1,3,-1]')],
      testCases: [TestCase(input: '[4,1,2]\n[1,3,4,2]', expectedOutput: '[-1, 3, -1]')],
      constraints: 'n < 1000',
      starterCode: {
        'Python': 'def solve(nums1, nums2):\n    # Implement here\n    return []',
        'Dart': 'List<int> solve(List<int> n1, List<int> n2) {\n  // Implement here\n  return [];\n}',
      },
    ),
    
    
    Problem(
      id: 'sliding_window_max',
      title: 'Sliding window maximum',
      difficulty: Difficulty.hard,
      tags: ['Queue', 'Sliding Window'],
      xpReward: 200,
      functionName: 'solve',
      description: 'Find max in every window of size k.',
      examples: [ProblemExample(input: '[1,3,-1,-3,5,3,6,7], 3', output: '[3,3,5,5,6,7]')],
      testCases: [TestCase(input: '[1,3,-1,-3,5,3,6,7]\n3', expectedOutput: '[3, 3, 5, 5, 6, 7]')],
      constraints: 'n < 10⁵',
      starterCode: {
        'Python': 'def solve(nums, k):\n    # Implement here\n    return []',
        'Dart': 'List<int> solve(List<int> nums, int k) {\n  // Implement here\n  return [];\n}',
      },
    ),
    
    
    
    
  ];

  static Problem? getById(String id) {
    try {
      return problems.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<Problem> getByDifficulty(Difficulty d) =>
      problems.where((p) => p.difficulty == d).toList();

  static Problem get dailyChallenge {
    if (problems.isEmpty) return const Problem(id: 'dummy', title: 'Loading...', description: '', difficulty: Difficulty.easy, tags: [], examples: [], testCases: [], constraints: '', xpReward: 0, functionName: '', starterCode: {});
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    return problems[dayOfYear % problems.length];
  }

  static Future<void> loadFromSupabase() async {
    final dbProblems = await ProblemService.fetchProblems();
    if (dbProblems.isNotEmpty) {
      // Merge local and DB problems (DB takes precedence if same ID)
      final Map<String, Problem> merged = {};
      for (final p in problems) {
        merged[p.id] = p;
      }
      for (final p in dbProblems) {
        merged[p.id] = p;
      }

      final allList = merged.values.toList();

      // Group them by difficulty to maintain sequential unlocking rules
      // (User must solve all Easy before seeing Medium, etc.)
      final easy = allList.where((p) => p.difficulty == Difficulty.easy).toList();
      final medium = allList.where((p) => p.difficulty == Difficulty.medium).toList();
      final hard = allList.where((p) => p.difficulty == Difficulty.hard).toList();

      // Overwrite the problems list in strict difficulty order
      problems = [...easy, ...medium, ...hard];
    }
  }
}
