import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../common/color_extension.dart';
import 'dart:math' as math;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String? videoUrl;
  final double? height;
  final Function(String)? onError;

  const VideoPlayerWidget({
    Key? key,
    required this.videoUrl,
    this.height = 220,
    this.onError,
  }) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  YoutubePlayerController? _controller;
  bool _isError = false;
  bool _isLoading = true;
  String? _videoId;
  bool _playerReady = false;
  bool _isPlaying = false;
  PlayerState? _lastPlayerState;

  // Check if running on Windows or Web
  bool get _isWindowsOrWeb {
    try {
      return kIsWeb || Platform.isWindows;
    } catch (e) {
      // If Platform is not available, assume true to be safe
      return true;
    }
  }

  @override
  void initState() {
    super.initState();
    print('VideoPlayerWidget initializing with URL: ${widget.videoUrl}');
    _extractVideoId();
  }

  @override
  void dispose() {
    print('VideoPlayerWidget disposing');
    _controller?.dispose();
    super.dispose();
  }

  void _extractVideoId() {
    if (widget.videoUrl == null || widget.videoUrl!.isEmpty) {
      print('No video URL provided');
      _handleError('No video URL provided');
      return;
    }

    try {
      print('Attempting to extract video ID from: ${widget.videoUrl}');
      _videoId = YoutubePlayer.convertUrlToId(widget.videoUrl!);
      print('Extracted video ID: $_videoId');

      if (_videoId == null) {
        _handleError('Invalid YouTube URL format');
        return;
      }

      // Don't try to initialize the player on Windows
      if (!_isWindowsOrWeb) {
        setState(() {
          _isLoading = false;
        });
      } else {
        print('Running on Windows/Web - will use thumbnail only mode');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error extracting video ID: $e');
      _handleError('Video ID extraction error: $e');
    }
  }

  void _initializePlayer() {
    // On Windows, just open in browser instead
    if (_isWindowsOrWeb) {
      _openInBrowser();
      return;
    }

    if (_videoId == null) {
      _handleError('No video ID available');
      return;
    }

    try {
      print('Creating YouTube player controller for video ID: $_videoId');

      setState(() {
        _isPlaying = true; // Immediately show loading state
      });

      // Use a more performant player configuration
          _controller = YoutubePlayerController(
        initialVideoId: _videoId!,
            flags: const YoutubePlayerFlags(
          autoPlay: true,
              mute: false,
              disableDragSeek: false,
              loop: false,
          enableCaption: false, // Disable captions for faster loading
          hideThumbnail: true, // Hide YouTube's thumbnail to use our custom one
              hideControls: false,
          forceHD: false, // Don't force HD to load faster
          controlsVisibleAtStart: false,
        ),
      );

      // Add listener to track player state
      _controller!.addListener(() {
        // Only log once when state changes to avoid excessive logging
        final playerState = _controller!.value.playerState;
        if (_lastPlayerState != playerState) {
          _lastPlayerState = playerState;

          if (playerState == PlayerState.buffering) {
            print('YouTube player is buffering');
          } else if (playerState == PlayerState.playing) {
            print('YouTube player is playing');
            if (mounted) {
              setState(() {
                _isPlaying = true;
              });
            }
          } else if (playerState == PlayerState.paused) {
            print('YouTube player is paused');
          } else if (playerState == PlayerState.ended) {
            print('YouTube player has ended');
          } else if (playerState == PlayerState.unknown) {
            print('YouTube player state is unknown');
          }
        }

        if (_controller!.value.isReady && !_playerReady) {
          print('YouTube player is now ready');
          if (mounted) {
            setState(() {
              _playerReady = true;
            });
          }
        }
      });
    } catch (e) {
      print('Error initializing YouTube player: $e');
      _handleError('Player initialization error: $e');
    }
  }

  Future<void> _openInBrowser() async {
    if (widget.videoUrl != null) {
      try {
        final Uri url = Uri.parse(widget.videoUrl!);
        print('Opening video in browser: $url');
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } catch (e) {
        print('Could not launch URL: $e');
        _handleError('Could not open video in browser: $e');
      }
    }
  }

  void _handleError(String message) {
    print('Video player error: $message');

    // Call the error callback if provided
    if (widget.onError != null) {
      widget.onError!(message);
    }

    if (mounted) {
    setState(() {
        _isError = true;
      _isLoading = false;
    });
    }
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

    if (_isError || _videoId == null) {
      return _buildErrorWidget();
    }

    // On Windows, always use thumbnail view with a clear message
    if (_isWindowsOrWeb) {
      return _buildWindowsThumbnailWidget();
    }

    // If not yet playing, show thumbnail with play button
    if (!_isPlaying) {
      return _buildThumbnailWidget();
    }

    // Show YouTube player if controller is initialized
    if (_controller != null) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: YoutubePlayer(
          controller: _controller!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: TColor.primaryColor1,
          progressColors: ProgressBarColors(
            playedColor: TColor.primaryColor1,
            handleColor: TColor.primaryColor2,
          ),
          onReady: () {
            print('YouTube Player onReady callback fired');
            if (mounted) {
              setState(() {
                _playerReady = true;
              });
            }
          },
        ),
      );
    } else {
      return _buildThumbnailWidget();
    }
  }

  Widget _buildWindowsThumbnailWidget() {
    return GestureDetector(
      onTap: _openInBrowser,
      child: Container(
        height: widget.height,
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // YouTube thumbnail - using a lower quality image for faster loading
            if (_videoId != null)
              Image.network(
                'https://img.youtube.com/vi/$_videoId/mqdefault.jpg',
                width: double.infinity,
                height: widget.height,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: double.infinity,
                    height: widget.height,
                    color: Colors.black,
                    child: const Center(
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white54,
                        size: 70,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading thumbnail: $error');
                  return Container(
                    width: double.infinity,
                    height: widget.height,
                    color: Colors.black,
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.white54,
                        size: 50,
                      ),
                    ),
                  );
                },
              ),
            // Info overlay explaining Windows limitations
            Container(
              width: double.infinity,
              height: widget.height,
              color: Colors.black.withOpacity(0.6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: TColor.primaryColor1.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.open_in_browser,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'YouTube Player not supported on Windows',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to open in your browser',
                    style: TextStyle(
                      color: TColor.primaryColor1,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnailWidget() {
    return GestureDetector(
      onTap: () {
        _initializePlayer();
      },
      child: Container(
        height: widget.height,
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // YouTube thumbnail - using a lower quality image for faster loading
            if (_videoId != null)
              Image.network(
                'https://img.youtube.com/vi/$_videoId/mqdefault.jpg', // Medium quality thumbnail loads faster
                width: double.infinity,
                height: widget.height,
                fit: BoxFit.cover,
                // Add a placeholder while the image loads
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: double.infinity,
                    height: widget.height,
                    color: Colors.black,
                    child: const Center(
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white54,
                        size: 70,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading thumbnail: $error');
                  return Container(
                    width: double.infinity,
                    height: widget.height,
                    color: Colors.black,
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.white54,
                        size: 50,
                      ),
                    ),
                  );
                },
              ),
            // Play button overlay
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: TColor.primaryColor1.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 50,
              ),
            ),
            // Video title overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: Colors.black.withOpacity(0.7),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.touch_app,
                      color: Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Tap to play video',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
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
            const Text(
                'Error loading video',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              'URL: ${widget.videoUrl?.substring(0, math.min(30, widget.videoUrl?.length ?? 0))}${widget.videoUrl != null && widget.videoUrl!.length > 30 ? '...' : ''}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _isError = false;
                  });
                _extractVideoId();
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
}
