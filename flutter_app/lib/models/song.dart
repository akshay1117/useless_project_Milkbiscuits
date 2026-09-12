class Song {
  final int id;
  final String title;
  final String artist;
  final String file;
  final String image;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.file,
    required this.image,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      file: json['file'],
      image: json['image'] ?? 'https://lh3.googleusercontent.com/aida-public/AB6AXuB6Y92-6B6mUuYHPR-DUPPfL7WNO5KBWduGeK7PMhI7pWMK9GRqZRq39dqiC--01Q0ik03y0WWVmz5SGba9h8mRDFz7uFu9hx0qMbyDETVMQ9IiY_etcCH1VQAvfT_ym1SOA0HgI5Lp1VgWqY7MZN8Vr970NBKuQqwkg3y5VhDVZyJzdOV4R7sJxWsqNTIZju8vzQoVTVpoPBhVbgcyhlOXmdUobGzTt3tvG_BKIfdYS6kVMISeVBlOkdlULPCoPTdZdrmp4sz4nyQ',
    );
  }
}
