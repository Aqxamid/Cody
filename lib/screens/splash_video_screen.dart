import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class SplashVideoScreen extends StatefulWidget {
  final VoidCallback onFinished;
  const SplashVideoScreen({super.key, required this.onFinished});

  @override
  State<SplashVideoScreen> createState() => _SplashVideoScreenState();
}

class _SplashVideoScreenState extends State<SplashVideoScreen>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  late AnimationController _logoController;
  bool _videoReady = false;
  bool _videoError = false;

  // ── Video Configuration ────────────────────────────────────────────────────────
  // TODO: To switch to a local asset video:
  // 1. Place your video in the assets folder (e.g., 'assets/splash_video.mp4') and define it in pubspec.yaml.
  // 2. Uncomment `_videoAssetPath` below and comment out `_videoUrl`.
  // 3. In `_initVideo()`, change `VideoPlayerController.networkUrl(...)` to `VideoPlayerController.asset(_videoAssetPath)`.
  static const String _videoUrl = 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4';
  // static const String _videoAssetPath = 'assets/splash_video.mp4';

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _initVideo();

    // Safety fallback — always advance after 6 seconds
    Future.delayed(const Duration(seconds: 6), _finish);
  }

  Future<void> _initVideo() async {
    try {
      _videoController =
          VideoPlayerController.networkUrl(Uri.parse(_videoUrl));
      await _videoController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        showControls: false,
        aspectRatio: _videoController!.value.aspectRatio,
      );

      _videoController!.addListener(() {
        if (_videoController!.value.position >=
            _videoController!.value.duration) {
          _finish();
        }
      });

      if (mounted) setState(() => _videoReady = true);
    } catch (_) {
      if (mounted) setState(() => _videoError = true);
    }
  }

  Future<void> _finish() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('splash_shown', true);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    widget.onFinished();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F12),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background: video or animated gradient ───────────────────────
          if (_videoReady && !_videoError)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoController!.value.size.width,
                height: _videoController!.value.size.height,
                child: Chewie(controller: _chewieController!),
              ),
            )
          else
            _buildAnimatedBackground(),

          // ── Dark overlay ─────────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xCC0F0F12),
                  Color(0x880F0F12),
                  Color(0xCC0F0F12),
                ],
              ),
            ),
          ),

          // ── Logo + branding ──────────────────────────────────────────────
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (_, __) => Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withValues(
                              alpha: 0.3 + _logoController.value * 0.4),
                          blurRadius: 40 + _logoController.value * 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/app_icon.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'CODY',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Code. Compete. Conquer.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF94A3B8),
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),

          // ── Skip button ──────────────────────────────────────────────────
          Positioned(
            top: 52,
            right: 24,
            child: TextButton(
              onPressed: _finish,
              child: Text(
                'SKIP',
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2 + _logoController.value * 0.3,
            colors: const [
              Color(0xFF1E1B4B),
              Color(0xFF0F0F12),
            ],
          ),
        ),
      ),
    );
  }
}
