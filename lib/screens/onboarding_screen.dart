import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinished;

  const OnboardingScreen({super.key, required this.onFinished});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Code Anywhere',
      subtitle: 'A full-featured mobile IDE in your pocket. Support for Python and Dart with cloud-powered execution.',
      icon: Icons.code_rounded,
      color: const Color(0xFF6366F1),
    ),
    OnboardingData(
      title: 'Competitive Challenges',
      subtitle: 'Solve hand-crafted problems across 5 levels. Fight for the top spot on the leaderboard.',
      icon: Icons.military_tech_outlined,
      color: const Color(0xFFEF4444),
    ),
    OnboardingData(
      title: 'Track Progress',
      subtitle: 'Maintain your streak, earn badges, and watch your level rise as you master new patterns.',
      icon: Icons.auto_awesome_outlined,
      color: const Color(0xFF10B981),
    ),
    OnboardingData(
      title: 'Global Arena',
      subtitle: 'Compare your logic with developers worldwide and prove you are the ultimate Code Ninja.',
      icon: Icons.public_outlined,
      color: const Color(0xFFF59E0B),
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F12),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (idx) => setState(() => _currentPage = idx),
            itemBuilder: (ctx, i) => _OnboardingPage(data: _pages[i]),
          ),
          
          // Navigation indicators
          Positioned(
            bottom: 120,
            left: 0, right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (idx) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: _currentPage == idx ? 24 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == idx ? _pages[idx].color : const Color(0xFF2D2D35),
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
            ),
          ),

          // Bottom Button
          Positioned(
            bottom: 40,
            left: 24, right: 24,
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  if (_currentPage < _pages.length - 1) {
                    _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
                  } else {
                    _completeOnboarding();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _pages[_currentPage].color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  _currentPage == _pages.length - 1 ? 'GET STARTED' : 'NEXT',
                  style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  OnboardingData({required this.title, required this.subtitle, required this.icon, required this.color});
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingData data;
  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, size: 80, color: data.color),
          ),
          const SizedBox(height: 48),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 16, color: const Color(0xFF94A3B8), height: 1.6),
          ),
        ],
      ),
    );
  }
}
