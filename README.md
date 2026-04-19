# Cody - Competitive Programming Platform

Cody is a mobile competitive programming platform designed for practicing competitive programming. This application provides a curated learning path through 46 categorized challenges, allowing users to solve algorithmic problems in both Python and Dart on a mobile device.

## Academic Context
This application was developed as a final project for the **Application Development & Emerging Technologies** subject. It explores mobile-first developer tools, cloud-powered code execution, and persistent user-state management.

## Core Features
- **Integrated Code Execution**: Leverages the Codapi Cloud API for high-performance, sandboxed execution of Python and Dart code.
- **Automated Test Validation**: Features an internal test-case engine that automatically validates user logic against structured inputs and expected outputs.
- **Curricular Roadmap**: Includes a 46-problem curriculum spread across five levels:
  - Level 1: Basics
  - Level 2: Arrays & Strings
  - Level 3: Problem Solving Patterns
  - Level 4: Recursion & Backtracking
  - Level 5: Data Structures
- **Session Persistence**: Implements real-time data serialization for user progress (XP, streaks, badges) and code drafts using `SharedPreferences`.
- **Responsive IDE**: A tailored mobile editor featuring syntax-awareness, quick symbols, and a dual-mode "Test/Run" workflow.

## Technology Stack
- **Framework**: Flutter (v3.41.2)
- **Language**: Dart
- **State Management**: Riverpod
- **Execution Engine**: Codapi Service
- **Storage**: SharedPreferences (Local Storage)

## Setup and Installation
To run this project locally, ensure you have the Flutter SDK installed on your machine.

1. Clone the repository.
2. Run `flutter pub get` to install dependencies.
3. Connect an Android device or start an emulator.
4. Execute `flutter run` from the project root.

## Disclaimer
This project is intended for educational purposes as part of a university-level curriculum.

## License
This project is licensed under the MIT License - see the LICENSE file for details.
