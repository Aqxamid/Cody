import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  static const List<_TeamMember> _team = [
    _TeamMember(
      name: 'Allen Ronn Parado',
      role: 'Lead Developer',
      initials: 'AP',
      accent: Color(0xFF6366F1),
      githubUrl: 'https://github.com/Aqxamid',
      assetPath: 'assets/Allen.JPG', 
    ),
    const _TeamMember(
      name: 'Jeffrey Balmedina',
      role: 'UI/UX Designer & MVP Developer',
      initials: 'JB',
      accent: Color(0xFF10B981),
      assetPath: 'assets/Jeffrey.jpg',
    ),
    const _TeamMember(
      name: 'Mark Gozado',
      role: 'Quality Assurance',
      initials: 'MG',
      accent: Color(0xFFF59E0B),
      assetPath: 'assets/Mark.jpg',
    ),
    const _TeamMember(
      name: 'Ayala Hermoso',
      role: 'Quality Assurance',
      initials: 'AH',
      accent: Color(0xFFEF4444),
      assetPath: 'assets/Ayela.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text('About Us',
            style: GoogleFonts.spaceGrotesk(
                color: cs.primary, fontSize: 20, fontWeight: FontWeight.w900)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: cs.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Header ───────────────────────────────────────────────────────
          Center(
            child: Column(children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: cs.primary.withValues(alpha: 0.3), blurRadius: 24)],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset('assets/app_icon.png', fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 16),
              Text('Cody',
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 28, fontWeight: FontWeight.w900, color: cs.onSurface)),
              const SizedBox(height: 6),
              Text('Version 1.4.0',
                  style: GoogleFonts.inter(fontSize: 12, color: cs.outline)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Built with ❤️ by our team',
                  style: GoogleFonts.inter(fontSize: 14, color: cs.primary, fontWeight: FontWeight.w600),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 40),

          // ── Team section ─────────────────────────────────────────────────
          Text('OUR TEAM',
              style: GoogleFonts.inter(
                  fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w700, color: cs.outline)),
          const SizedBox(height: 16),

          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.88,
            children: _team.map((m) => _MemberCard(member: m)).toList(),
          ),

          const SizedBox(height: 40),

          // ── Mission ──────────────────────────────────────────────────────
          Text('OUR MISSION',
              style: GoogleFonts.inter(
                  fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w700, color: cs.outline)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Cody was built to make competitive programming accessible, fun, and social. '
              'We believe every developer deserves a place to sharpen their skills, '
              'compete, and grow together — right from their pocket.',
              style: GoogleFonts.inter(fontSize: 14, color: cs.onSurfaceVariant, height: 1.7),
            ),
          ),

          const SizedBox(height: 24),

          // ── Tech stack ───────────────────────────────────────────────────
          Text('POWERED BY',
              style: GoogleFonts.inter(
                  fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w700, color: cs.outline)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Flutter', 'Supabase', 'Codapi', 'Brevo', 'Riverpod']
                .map((t) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
                      ),
                      child: Text(t,
                          style: GoogleFonts.inter(
                              fontSize: 12, color: cs.primary, fontWeight: FontWeight.w600)),
                    ))
                .toList(),
          ),
        ]),
      ),
    );
  }
}

class _TeamMember {
  final String name;
  final String role;
  final String initials;
  final Color accent;
  final String? githubUrl;
  final String? assetPath;
  const _TeamMember({
    required this.name,
    required this.role,
    required this.initials,
    required this.accent,
    this.githubUrl,
    this.assetPath,
  });
}

class _MemberCard extends StatelessWidget {
  final _TeamMember member;
  const _MemberCard({required this.member});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: member.githubUrl != null ? () async {
        final uri = Uri.parse(member.githubUrl!);
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (e) {
          debugPrint('Could not launch ${member.githubUrl}: $e');
        }
      } : null,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: member.accent.withValues(alpha: 0.2)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          // Avatar with placeholder initials or Image
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: member.assetPath == null ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [member.accent, member.accent.withValues(alpha: 0.6)],
              ) : null,
              image: member.assetPath != null ? DecorationImage(
                image: AssetImage(member.assetPath!),
                fit: BoxFit.cover,
              ) : null,
              boxShadow: [BoxShadow(color: member.accent.withValues(alpha: 0.3), blurRadius: 16)],
            ),
            alignment: Alignment.center,
            child: member.assetPath == null ? Text(
              member.initials,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
            ) : null,
          ),
          const SizedBox(height: 12),
          Text(
            member.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: GoogleFonts.spaceGrotesk(
                fontSize: 13, fontWeight: FontWeight.w700, color: cs.onSurface),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: member.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              member.role,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 10, color: member.accent, fontWeight: FontWeight.w600),
            ),
          ),
          if (member.githubUrl != null) ...[
             const SizedBox(height: 8),
             Icon(Icons.link, size: 14, color: member.accent.withValues(alpha: 0.7)),
          ],
        ]),
      ),
    );
  }
}
