import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CodyBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CodyBottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 0.5)),
        ),
        child: Row(
          children: [
            _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'HOME', isActive: currentIndex == 0, onTap: () => onTap(0)),
            _NavItem(icon: Icons.code_outlined, activeIcon: Icons.code, label: 'PROBLEMS', isActive: currentIndex == 1, onTap: () => onTap(1)),
            _NavItem(icon: Icons.leaderboard_outlined, activeIcon: Icons.leaderboard, label: 'RANK', isActive: currentIndex == 2, onTap: () => onTap(2)),
            _NavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'PROFILE', isActive: currentIndex == 3, onTap: () => onTap(3)),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.activeIcon, required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.5,
                color: isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
