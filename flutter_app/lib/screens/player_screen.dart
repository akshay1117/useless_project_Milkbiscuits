import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/playback_controller.dart';
import 'dart:math';
import 'dart:ui';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> with TickerProviderStateMixin {
  bool _showPunishmentToast = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(_pulseController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _triggerPunishment(PlaybackController controller) {
    setState(() {
      _showPunishmentToast = true;
    });
    controller.onUserSeekAttempt();
    
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() {
          _showPunishmentToast = false;
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141313), // canvas-dark
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color.fromRGBO(255, 255, 255, 0.1), // whisper-border
                width: 1,
              ),
            ),
          ),
          child: AppBar(
            backgroundColor: const Color(0xFF141313),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.expand_more, color: Color(0xFF71717A), size: 28),
              onPressed: () {},
            ),
            title: Text(
              'Now Playing',
              style: GoogleFonts.geist(
                color: const Color(0xFFFFFFFF),
                fontSize: 24,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.24,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert, color: Color(0xFF71717A), size: 28),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
      body: Consumer<PlaybackController>(
        builder: (context, controller, child) {
          final song = controller.currentSong;
          final currentPos = controller.currentPosition.inSeconds.toDouble();
          final totalDur = controller.totalDuration.inSeconds.toDouble();
          final maxDur = totalDur > 0 ? totalDur : 1.0;
          final progressPercent = (currentPos / maxDur).clamp(0.0, 1.0);

          final annoyanceColor = controller.annoyanceColor == Colors.red 
              ? const Color(0xFFCF6679) // punishment-red
              : const Color(0xFF71717A); // muted-steel

          final isHighAnnoyance = controller.annoyanceLevel > 50;

          return Stack(
            fit: StackFit.expand,
            children: [
              // Blurred Background
              if (song != null)
                Positioned.fill(
                  child: (song.image.startsWith('http'))
                      ? Image.network(song.image, fit: BoxFit.cover)
                      : Image.asset(song.image, fit: BoxFit.cover),
                ),
              if (song != null)
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 60.0, sigmaY: 60.0),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.6), // Dark overlay
                    ),
                  ),
                ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      // Annoyance Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E).withAlpha(153),
                          borderRadius: BorderRadius.circular(9999),
                          border: Border.all(
                            color: isHighAnnoyance 
                              ? const Color(0xFFCF6679).withAlpha(102)
                              : const Color.fromRGBO(255, 255, 255, 0.1),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FadeTransition(
                              opacity: _pulseAnimation,
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: annoyanceColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'LEVEL: ${controller.annoyanceLabel.toUpperCase()} (${controller.annoyanceLevel}%)',
                              style: GoogleFonts.geistMono(
                                color: annoyanceColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: AspectRatio(
                              aspectRatio: 1.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF282828), // Spotify placeholder gray
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black54,
                                      blurRadius: 24,
                                      offset: Offset(0, 12),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: (song?.image ?? 'http').startsWith('http')
                                      ? Image.network(
                                          song?.image ?? 'https://lh3.googleusercontent.com/aida-public/AB6AXuB6Y92-6B6mUuYHPR-DUPPfL7WNO5KBWduGeK7PMhI7pWMK9GRqZRq39dqiC--01Q0ik03y0WWVmz5SGba9h8mRDFz7uFu9hx0qMbyDETVMQ9IiY_etcCH1VQAvfT_ym1SOA0HgI5Lp1VgWqY7MZN8Vr970NBKuQqwkg3y5VhDVZyJzdOV4R7sJxWsqNTIZju8vzQoVTVpoPBhVbgcyhlOXmdUobGzTt3tvG_BKIfdYS6kVMISeVBlOkdlULPCoPTdZdrmp4sz4nyQ',
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return const Icon(Icons.music_note, color: Color(0xFF71717A), size: 64);
                                          },
                                        )
                                      : Image.asset(
                                          song!.image,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return const Icon(Icons.music_note, color: Color(0xFF71717A), size: 64);
                                          },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      ),

                      // Track Info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  song?.title ?? 'Midnight City',
                                  style: GoogleFonts.geist(
                                    color: const Color(0xFFFFFFFF),
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.24,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  song?.artist ?? 'M83',
                                  style: GoogleFonts.geist(
                                    color: const Color(0xFFB3B3B3),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          StatefulBuilder(
                            builder: (context, setFavState) {
                              return IconButton(
                                icon: const Icon(Icons.favorite_border),
                                color: const Color(0xFF71717A),
                                iconSize: 28,
                                onPressed: () {
                                  // toggle favorite visually (mocked)
                                },
                              );
                            }
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Progress Bar
                      GestureDetector(
                        onTapDown: (_) => _triggerPunishment(controller),
                        onHorizontalDragStart: (_) => _triggerPunishment(controller),
                        child: Container(
                          height: 24,
                          color: Colors.transparent, // expanded hit area
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              Container(
                                height: 6,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF353434), // surface-container-highest
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: progressPercent,
                                child: Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: _showPunishmentToast ? const Color(0xFFCF6679) : const Color(0xFFFFFFFF),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: max(0, (MediaQuery.of(context).size.width - 48) * progressPercent - 8),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 100),
                                  width: _showPunishmentToast ? 20 : 16,
                                  height: _showPunishmentToast ? 20 : 16,
                                  decoration: BoxDecoration(
                                    color: _showPunishmentToast ? const Color(0xFFCF6679) : const Color(0xFFFFFFFF),
                                    shape: BoxShape.circle,
                                    boxShadow: const [
                                      BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDuration(controller.currentPosition), style: GoogleFonts.geistMono(fontSize: 12, color: const Color(0xFF71717A))),
                          Text(_formatDuration(controller.totalDuration), style: GoogleFonts.geistMono(fontSize: 12, color: const Color(0xFF71717A))),
                        ],
                      ),
                      
                      // Punishment Toast Placeholder area (invisible if not triggered)
                      AnimatedOpacity(
                        opacity: _showPunishmentToast ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          transform: Matrix4.translationValues(0, _showPunishmentToast ? 0 : 8, 0),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color.fromRGBO(207, 102, 121, 0.3)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(50),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            'ACTION BLOCKED: USER SEEKING PROHIBITED',
                            style: GoogleFonts.geistMono(
                              color: const Color(0xFFCF6679),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      if (!_showPunishmentToast) const SizedBox(height: 40),

                      // Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.shuffle),
                            color: const Color(0xFF71717A),
                            iconSize: 24,
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.skip_previous),
                            color: const Color(0xFFFFFFFF),
                            iconSize: 32,
                            onPressed: () => controller.playPrevious(),
                          ),
                          Container(
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(
                              color: Color(0xFF1DB954), // Spotify Green
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(controller.isPlaying ? Icons.pause : Icons.play_arrow),
                              color: const Color(0xFF000000), // Black icon
                              iconSize: 36,
                              onPressed: () {
                                if (controller.isPlaying) {
                                  controller.pause();
                                } else {
                                  controller.play();
                                }
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.skip_next),
                            color: const Color(0xFFFFFFFF),
                            iconSize: 32,
                            onPressed: () => controller.playNext(),
                          ),
                          IconButton(
                            icon: const Icon(Icons.repeat),
                            color: const Color(0xFF71717A),
                            iconSize: 24,
                            onPressed: () {},
                          ),
                        ],
                      ),

                      // Audio Output
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.airplay, color: Color(0xFF71717A), size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'HEADPHONES (PRECISION DAC)',
                              style: GoogleFonts.geistMono(
                                color: const Color(0xFF71717A),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
