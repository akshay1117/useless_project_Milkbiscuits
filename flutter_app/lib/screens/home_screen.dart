import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/playback_controller.dart';
import '../widgets/song_tile.dart';


class HomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToPlayer;

  const HomeScreen({super.key, this.onNavigateToPlayer});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
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

  void _triggerSatiricalWarning(BuildContext context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.warning, color: Color(0xFFCF6679), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SYSTEM REFUSAL',
                    style: GoogleFonts.geistMono(
                      color: const Color(0xFFCF6679),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Seek denied. File system deliberately locked to prevent enjoyment.',
                    style: GoogleFonts.geist(
                      color: const Color(0xFF71717A),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E1E1E), // pure-surface
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16), // above bottom nav
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFFCF6679), width: 1),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // canvas-dark
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
            backgroundColor: const Color(0xFF121212),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.graphic_eq, color: Color(0xFFFFFFFF)),
              onPressed: () {},
            ),
            title: Text(
              'Your Library',
              style: GoogleFonts.geist(
                color: const Color(0xFFFFFFFF),
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings, color: Color(0xFF71717A)), // muted-steel
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
      body: Consumer<PlaybackController>(
        builder: (context, controller, child) {
          if (controller.playlist.isEmpty) {
            return _buildEmptyState(context);
          }
          return _buildSongList(context, controller);
        },
      ),
    );
  }

  Widget _buildSongList(BuildContext context, PlaybackController controller) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildAnnoyanceMeter(controller),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            itemCount: controller.playlist.length,
            itemBuilder: (context, index) {
              final song = controller.playlist[index];
              return SongTile(
                song: song,
                onTap: () {
                  controller.playSong(song);
                  if (widget.onNavigateToPlayer != null) {
                    widget.onNavigateToPlayer!();
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final controller = context.read<PlaybackController>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Annoyance Badge
          Container(
            margin: const EdgeInsets.only(bottom: 32),
            child: _buildAnnoyanceMeter(controller),
          ),

          // Hero Graphic
          Container(
            width: 128,
            height: 128,
            margin: const EdgeInsets.only(bottom: 24),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Inner pure-surface box
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ColorFiltered(
                      colorFilter: const ColorFilter.matrix([
                        0.33, 0.33, 0.33, 0, 0,
                        0.33, 0.33, 0.33, 0, 0,
                        0.33, 0.33, 0.33, 0, 0,
                        0,    0,    0,    1, 0,
                      ]),
                      child: Image.network(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuB6Y92-6B6mUuYHPR-DUPPfL7WNO5KBWduGeK7PMhI7pWMK9GRqZRq39dqiC--01Q0ik03y0WWVmz5SGba9h8mRDFz7uFu9hx0qMbyDETVMQ9IiY_etcCH1VQAvfT_ym1SOA0HgI5Lp1VgWqY7MZN8Vr970NBKuQqwkg3y5VhDVZyJzdOV4R7sJxWsqNTIZju8vzQoVTVpoPBhVbgcyhlOXmdUobGzTt3tvG_BKIfdYS6kVMISeVBlOkdlULPCoPTdZdrmp4sz4nyQ',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.music_off, color: Color(0xFF71717A), size: 32),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                // Corner brackets
                Positioned(top: 0, left: 0, child: _buildCorner(top: true, left: true)),
                Positioned(top: 0, right: 0, child: _buildCorner(top: true, left: false)),
                Positioned(bottom: 0, left: 0, child: _buildCorner(top: false, left: true)),
                Positioned(bottom: 0, right: 0, child: _buildCorner(top: false, left: false)),
                // Border
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.1)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Text
          Text(
            'No songs found.',
            style: GoogleFonts.geist(
              color: const Color(0xFFFFFFFF),
              fontSize: 24,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.01,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.errorMessage ?? 'Add some .mp3 files to start.',
            style: GoogleFonts.geist(
              color: controller.errorMessage != null ? const Color(0xFFCF6679) : const Color(0xFF71717A),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Action Group
          InkWell(
            onTap: () => _triggerSatiricalWarning(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 48,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.1)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.folder_open, color: Color(0xFF71717A), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'IMPORT AUDIO',
                    style: GoogleFonts.geistMono(
                      color: const Color(0xFFFFFFFF),
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => _triggerSatiricalWarning(context),
            icon: const Icon(Icons.sync, color: Color(0xFF71717A), size: 16),
            label: Text(
              'Scan Local Storage',
              style: GoogleFonts.geistMono(
                color: const Color(0xFF71717A),
                fontSize: 12,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
          
          const Spacer(),

          // Diagnostic Footer
          Text(
            'FS_DISPATCH: 0 BYTES INDEXED',
            style: GoogleFonts.geistMono(
              color: const Color(0xFF71717A).withAlpha(153),
              fontSize: 10,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner({required bool top, required bool left}) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        border: Border(
          top: top ? const BorderSide(color: Color(0x6671717A)) : BorderSide.none,
          bottom: !top ? const BorderSide(color: Color(0x6671717A)) : BorderSide.none,
          left: left ? const BorderSide(color: Color(0x6671717A)) : BorderSide.none,
          right: !left ? const BorderSide(color: Color(0x6671717A)) : BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildAnnoyanceMeter(PlaybackController controller) {
    final annoyanceColor = controller.annoyanceColor == Colors.red 
        ? const Color(0xFFCF6679) // punishment-red
        : const Color(0xFF71717A); // muted-steel

    final isHighAnnoyance = controller.annoyanceLevel > 50;

    return Container(
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
    );
  }

}
