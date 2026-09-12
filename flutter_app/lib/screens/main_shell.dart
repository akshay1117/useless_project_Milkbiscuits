import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import 'player_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 1; // Default to Now Playing to match requested screen

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(
        onNavigateToPlayer: () {
          setState(() {
            _currentIndex = 1;
          });
        },
      ),
      const PlayerScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        height: 64,
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E), // pure-surface
          border: Border(
            top: BorderSide(
              color: Color.fromRGBO(255, 255, 255, 0.1), // whisper-border
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, 'Library', Icons.queue_music, Icons.queue_music),
            _buildNavItem(1, 'Playing', Icons.play_circle_outline, Icons.play_circle),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData inactiveIcon, IconData activeIcon) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? const Color(0xFFFFFFFF) : const Color(0xFF71717A); // titanium-white vs muted-steel
    final icon = isSelected ? activeIcon : inactiveIcon;

    return InkWell(
      onTap: () {
        setState(() => _currentIndex = index);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: GoogleFonts.geistMono(
                color: color,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
