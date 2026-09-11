class Song {
  final int id;
  final String title;
  final String artist;
  final String file;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.file,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      file: json['file'],
    );
  }
}
