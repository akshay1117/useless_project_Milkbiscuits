import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/main_shell.dart';
import 'screens/player_screen.dart';
import 'controllers/playback_controller.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Anti-Music Player Error: ${details.exception}');
  };
  runApp(
    ChangeNotifierProvider(
      create: (context) => PlaybackController()..loadPlaylist(),
      child: const AntiMusicPlayerApp(),
    ),
  );
}

class AntiMusicPlayerApp extends StatelessWidget {
  const AntiMusicPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anti-Music Player',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212), // canvas-dark
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF121212), // canvas-dark
          elevation: 0,
          titleTextStyle: GoogleFonts.geist(
            color: const Color(0xFFFFFFFF), // titanium-white
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: const IconThemeData(color: Color(0xFFFFFFFF)),
        ),
        colorScheme: const ColorScheme.dark(
          surface: Color(0xFF1E1E1E), // pure-surface
          primary: Color(0xFFFFFFFF), // titanium-white
          secondary: Color(0xFF71717A), // muted-steel
          error: Color(0xFFCF6679), // punishment-red
          onSurface: Color(0xFFFFFFFF), // titanium-white
        ),
        textTheme: GoogleFonts.geistTextTheme(
          ThemeData.dark().textTheme,
        ).apply(
          bodyColor: const Color(0xFFFFFFFF),
          displayColor: const Color(0xFFFFFFFF),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MainShell(),
        '/player': (context) => const PlayerScreen(),
      },
    );
  }
}

