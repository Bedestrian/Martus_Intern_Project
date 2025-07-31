import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String streamUrl;
  final double aspectRatio;

  const VideoPlayerWidget({
    super.key,
    required this.streamUrl,
    this.aspectRatio = 16 / 9,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late final VlcPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Only initialize if the URL is valid.
    if (widget.streamUrl.isNotEmpty &&
        (widget.streamUrl.startsWith('rtsp://') ||
            widget.streamUrl.startsWith('http'))) {
      _controller = VlcPlayerController.network(
        widget.streamUrl,
        hwAcc: HwAcc.full,
        autoPlay: true,
        options: VlcPlayerOptions(
          advanced: VlcAdvancedOptions([
            '--network-caching=300', // Reduce network caching
            '--drop-late-frames', // Drop frames that are too late
            '--skip-frames', // Skip frames to catch up
          ]),
        ),
      );
      _isInitialized = true;
    }
  }

  // The dispose method MUST be async to await the controller's disposal.
  @override
  Future<void> dispose() async {
    // First, call the parent's dispose.
    super.dispose();
    // Then, if the controller was initialized, properly dispose of it.
    if (_isInitialized) {
      await _controller.stop();
      await _controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    // If the controller was never initialized (e.g., empty URL), show a placeholder.
    if (!_isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Text('Stream Offline', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return VlcPlayer(
      controller: _controller,
      aspectRatio: widget.aspectRatio,
      placeholder: const Center(child: CircularProgressIndicator()),
    );
  }
}
