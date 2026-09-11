import 'package:flutter/material.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Anti-Music Player Error: ${details.exception}');
  };
  runApp(const AntiMusicPlayerApp());
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
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const PlaceholderScreen(title: 'Home Screen'),
        '/player': (context) => const PlaceholderScreen(title: 'Player Screen'),
      },
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            if (title == 'Home Screen') {
              Navigator.pushNamed(context, '/player');
            } else {
              Navigator.pop(context);
            }
          },
          child: Text(title == 'Home Screen' ? 'Go to Player' : 'Go Back'),
        ),
      ),
    );
  }
}
