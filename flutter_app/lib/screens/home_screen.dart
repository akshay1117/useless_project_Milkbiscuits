import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song.dart';
import '../widgets/song_tile.dart';
import '../controllers/playback_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<PlaybackController>(
        builder: (context, controller, child) {
          final songs = controller.playlist;
          if (songs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
                return SongTile(
                  song: song,
                  onTap: () {
                    controller.playSong(song);
                    Navigator.pushNamed(
                      context, 
                      '/player',
                    );
                  },
                );
              },
            );
        },
      ),
    );
  }
}
