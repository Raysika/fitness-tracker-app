import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../common/color_extension.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String? videoUrl;
  final double? height;

  const VideoPlayerWidget({
    Key? key,
    required this.videoUrl,
    this.height = 220,
  }) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  YoutubePlayerController? _controller;
  bool _isError = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _initializePlayer() {
    try {
      if (widget.videoUrl != null) {
        final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl!);
        if (videoId != null) {
          _controller = YoutubePlayerController(
            initialVideoId: videoId,
            flags: const YoutubePlayerFlags(
              autoPlay: false,
              mute: false,
              disableDragSeek: false,
              loop: false,
              enableCaption: true,
              hideControls: false,
            ),
          );
        } else {
          _isError = true;
        }
      } else {
        _isError = true;
      }
    } catch (e) {
      print('Error initializing video player: $e');
      _isError = true;
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: widget.height,
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    if (_isError || _controller == null) {
      return Container(
        height: widget.height,
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 40,
              ),
              const SizedBox(height: 8),
              Text(
                'Error loading video',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _isError = false;
                  });
                  _initializePlayer();
                },
                child: Text(
                  'Retry',
                  style: TextStyle(
                    color: TColor.primaryColor1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return YoutubePlayer(
      controller: _controller!,
      showVideoProgressIndicator: true,
      progressIndicatorColor: TColor.primaryColor1,
      progressColors: ProgressBarColors(
        playedColor: TColor.primaryColor1,
        handleColor: TColor.primaryColor2,
      ),
      onReady: () {
        print('Player is ready.');
      },
      thumbnail: Container(
        color: Colors.black,
        child: Center(
          child: Icon(
            Icons.play_circle_fill,
            color: TColor.primaryColor1,
            size: 50,
          ),
        ),
      ),
      onEnded: (_) {
        // Auto-replay or handle video end
      },
    );
  }
}
