import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/song.dart';

class SongService {
  Future<List<Song>> loadSongs() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/songs.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => Song.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load songs: $e');
    }
  }
}
