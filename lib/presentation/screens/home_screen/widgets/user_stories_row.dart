import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/presentation/screens/home_screen/home_controller.dart';

class UserStoriesRow extends StatelessWidget {
  final HomeController controller;

  const UserStoriesRow({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final stories = controller.userStories;
    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: stories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final story = stories[index];
          if (story.isVideo) {
            return _VideoStoryCard(
              videoPath: story.mediaPath,
              title: story.title,
            );
          }
          return _ImageStoryCard(
            imagePath: story.mediaPath,
            title: story.title,
          );
        },
      ),
    );
  }
}

// ─── Image card (unchanged look) ─────────────────────────────────────────────

class _ImageStoryCard extends StatelessWidget {
  final String imagePath;
  final String title;

  const _ImageStoryCard({required this.imagePath, required this.title});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 150,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(imagePath, fit: BoxFit.cover),
            _GradientOverlay(),
            _TitleLabel(title: title),
          ],
        ),
      ),
    );
  }
}

// ─── Video card ───────────────────────────────────────────────────────────────

class _VideoStoryCard extends StatefulWidget {
  final String videoPath;
  final String title;

  const _VideoStoryCard({required this.videoPath, required this.title});

  @override
  State<_VideoStoryCard> createState() => _VideoStoryCardState();
}

class _VideoStoryCardState extends State<_VideoStoryCard> {
  late final VideoPlayerController _controller;
  bool _initialized = false;
  bool _muted = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _initialized = true);
          _controller.setLooping(true);
          _controller.play();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _controller.value.isPlaying
          ? _controller.pause()
          : _controller.play();
    });
  }

  void _toggleMute() {
    setState(() {
      _muted = !_muted;
      _controller.setVolume(_muted ? 0 : 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 150,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Video or loading placeholder ──────────────────────────────
            if (_initialized)
              FittedBox(
                fit: BoxFit.cover,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              )
            else
              Container(color: Colors.black),

            // ── Gradient overlay ──────────────────────────────────────────
            _GradientOverlay(),

            // ── Centre tap — play / pause ─────────────────────────────────
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _togglePlayPause,
              child: Center(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity:
                      (_initialized && _controller.value.isPlaying) ? 0 : 1,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _initialized && _controller.value.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),

            // ── Mute / unmute button — top-right ──────────────────────────
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: _toggleMute,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),

            // ── Title label ───────────────────────────────────────────────
            _TitleLabel(title: widget.title),
          ],
        ),
      ),
    );
  }
}

// ─── Shared sub-widgets ───────────────────────────────────────────────────────

class _GradientOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.65),
          ],
        ),
      ),
    );
  }
}

class _TitleLabel extends StatelessWidget {
  final String title;

  const _TitleLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 10,
      right: 10,
      bottom: 12,
      child: Text(
        title,
        maxLines: 2,
        style: AppTextStyle.bodySmallMedium.copyWith(
          color: Colors.white,
          height: 1.3,
        ),
      ),
    );
  }
}
