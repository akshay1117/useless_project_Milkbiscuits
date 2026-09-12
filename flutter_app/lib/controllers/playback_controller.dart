import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';
import '../services/song_service.dart';

class PlaybackController extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final SongService _songService = SongService();

  List<Song> playlist = [];
  int _currentIndex = -1;
  String? errorMessage;

  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;
  bool isPlaying = false;

  Timer? _sabotageTimer;
  final Random _random = Random();

  int seekAttempts = 0;
  
  int get annoyanceLevel => (seekAttempts * 10).clamp(0, 100);
  
  String get annoyanceLabel {
    if (annoyanceLevel < 20) return 'Calm';
    if (annoyanceLevel < 50) return 'Getting annoying';
    if (annoyanceLevel < 80) return 'Annoying';
    if (annoyanceLevel < 100) return 'Very annoying';
    return 'WHY ARE YOU STILL TRYING?';
  }

  Color get annoyanceColor {
    if (annoyanceLevel < 20) return Colors.green;
    if (annoyanceLevel < 50) return Colors.yellow;
    if (annoyanceLevel < 80) return Colors.orange;
    return Colors.red;
  }

  Song? get currentSong => _currentIndex >= 0 && _currentIndex < playlist.length ? playlist[_currentIndex] : null;

  Timer? _decayTimer;

  PlaybackController() {
    _initListeners();
    _startDecayTimer();
  }

  void _startDecayTimer() {
    _decayTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (seekAttempts > 0) {
        seekAttempts--;
        notifyListeners();
      }
    });
  }

  void _initListeners() {
    _audioPlayer.positionStream.listen((position) {
      currentPosition = position;
      notifyListeners();
    });

    _audioPlayer.durationStream.listen((duration) {
      totalDuration = duration ?? Duration.zero;
      notifyListeners();
    });

    _audioPlayer.playingStream.listen((playing) {
      isPlaying = playing;
      if (playing) {
        _scheduleNextSabotage();
      } else {
        _stopSabotageTimer();
      }
      notifyListeners();
    });

    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        playNext();
      }
    });
  }

  Future<void> loadPlaylist() async {
    try {
      playlist = await _songService.loadSongs();
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('Error loading playlist: $errorMessage');
    }
    notifyListeners();
  }

  Future<void> playSong(Song song) async {
    final index = playlist.indexWhere((s) => s.id == song.id);
    if (index != -1) {
      _currentIndex = index;
      await _audioPlayer.setAsset(song.file);
      play();
      notifyListeners();
    }
  }

  Future<void> play() async {
    await _audioPlayer.play();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  void _scheduleNextSabotage() {
    _stopSabotageTimer();
    if (!isPlaying) return;

    // Randomize WHEN the next sabotage happens (between 3 to 12 seconds)
    final nextSabotageDelay = _random.nextInt(10) + 3;

    _sabotageTimer = Timer(Duration(seconds: nextSabotageDelay), () {
      if (totalDuration.inSeconds > 0) {
        // Randomize WHAT the sabotage is
        final action = _random.nextInt(10);
        
        if (action < 3) {
          // 30% chance: Skip to the next song completely randomly
          playNext();
        } else {
          // 70% chance: Skip to a completely random second in the current song
          final randomSeconds = _random.nextInt(totalDuration.inSeconds);
          _audioPlayer.seek(Duration(seconds: randomSeconds));
        }
      }
      // Schedule the next sabotage recursively
      _scheduleNextSabotage();
    });
  }

  void _stopSabotageTimer() {
    _sabotageTimer?.cancel();
    _sabotageTimer = null;
  }

  Future<void> onUserSeekAttempt() async {
    seekAttempts++;
    notifyListeners();
    await playNext();
  }

  Future<void> seek(Duration position) async {
    // Normal seeking is disabled in Phase 4. It routes to punishment.
    onUserSeekAttempt();
  }

  Future<void> playNext() async {
    if (playlist.isEmpty) return;
    if (playlist.length == 1) {
      await playSong(playlist[0]);
      return;
    }
    int nextIndex;
    do {
      nextIndex = _random.nextInt(playlist.length);
    } while (nextIndex == _currentIndex);
    _currentIndex = nextIndex;
    await playSong(playlist[_currentIndex]);
  }

  Future<void> playPrevious() async {
    if (playlist.isEmpty) return;
    if (playlist.length == 1) {
      await playSong(playlist[0]);
      return;
    }
    int nextIndex;
    do {
      nextIndex = _random.nextInt(playlist.length);
    } while (nextIndex == _currentIndex);
    _currentIndex = nextIndex;
    await playSong(playlist[_currentIndex]);
  }

  @override
  void dispose() {
    _decayTimer?.cancel();
    _stopSabotageTimer();
    _audioPlayer.dispose();
    super.dispose();
  }
}
