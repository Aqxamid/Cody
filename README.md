# Cody - Competitive Programming Platform

Cody is a mobile competitive programming platform designed for practicing competitive programming. This application provides a curated learning path through 37 categorized challenges, allowing users to solve algorithmic problems in Python, Dart, C++, Java, and JavaScript on a mobile device.

## Academic Context
This application was developed as a final project for the **Application Development & Emerging Technologies** subject. It explores mobile-first developer tools, cloud-powered code execution, real-time backend synchronization, and persistent user-state management.

## Core Features
- **Integrated Code Execution**: Leverages the Codapi Cloud API for high-performance, sandboxed execution across 5 programming languages.
- **Automated Test Validation**: Features an internal test-case engine with an advanced output normalizer that automatically validates user logic against structured inputs and expected outputs, regardless of syntax artifacts.
- **Curricular Roadmap**: Includes a 37-problem spread across five difficulty levels with a sequential progression system—problems lock and unlock dynamically based on your success within that difficulty tier.
- **Authentication & Backend**: Secure sign-in powered by Supabase with Google OAuth integration, dynamically pulling user profile metadata and avatars.
- **Session Persistence**: Implements real-time data serialization for user progress (XP, true consecutive day streaks, badges) and code drafts using `SharedPreferences` locally and Supabase remotely.
- **Responsive IDE**: A tailored mobile editor featuring syntax-awareness, quick symbols, and a dual-mode "Test/Run" workflow.

## Technology Stack
- **Framework**: Flutter (v3.41.2)
- **State Management**: Riverpod
- **Backend Service**: Supabase (Auth & Postgres)
- **Execution Engine**: Codapi Service
- **Storage**: SharedPreferences (Local Storage)

## Setup and Installation
To run this project locally, ensure you have the Flutter SDK installed on your machine.

1. Clone the repository.
2. Run `flutter pub get` to install dependencies.
3. Add your Supabase `anonKey` and `url` to `lib/config/app_config.dart`.
4. Connect an Android device or start an emulator.
5. Execute `flutter run --release` from the project root.

## Disclaimer
This project is intended for educational purposes as part of a university-level curriculum.

## License
This project is licensed under the MIT License - see the LICENSE file for details.

## Contributors

- **[Jeffrey Balmedina](https://github.com/balmedinajeffrey-art)** – Led UI/UX design and developed the initial MVP, shaping the user experience and interface foundation of Cody.
- **[Allen Ronn Parado](https://github.com/Aqxamid)** – Lead Developer; handled feature expansion, system architecture, and overall implementation.
