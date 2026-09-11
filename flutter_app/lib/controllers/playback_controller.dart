import 'package:flutter/material.dart';
import 'package:just_audio/flutter_audio_platform_interface.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';
import '../services/song_service.dart';

class PlaybackController extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final SongService _songService = SongService();

  List<Song> playlist = [];
  int _currentIndex = -1;

  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;
  bool isPlaying = false;

  Song? get currentSong => _currentIndex >= 0 && _currentIndex < playlist.length ? playlist[_currentIndex] : null;

  PlaybackController() {
    _initListeners();
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
      notifyListeners();
    });

    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        playNext();
      }
    });
  }

  Future<void> loadPlaylist() async {
    playlist = await _songService.loadSongs();
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

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> playNext() async {
    if (playlist.isEmpty) return;
    _currentIndex = (_currentIndex + 1) % playlist.length;
    await playSong(playlist[_currentIndex]);
  }

  Future<void> playPrevious() async {
    if (playlist.isEmpty) return;
    _currentIndex = (_currentIndex - 1) < 0 ? playlist.length - 1 : _currentIndex - 1;
    await playSong(playlist[_currentIndex]);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
