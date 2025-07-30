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
  late VlcPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // If the URL is empty, don't even try to initialize.
    if (widget.streamUrl.isNotEmpty) {
      _controller = VlcPlayerController.network(
        widget.streamUrl,
        hwAcc: HwAcc.full,
        autoPlay: true,
        options: VlcPlayerOptions(
          video: VlcVideoOptions([
            VlcVideoOptions.dropLateFrames(true),
            VlcVideoOptions.skipFrames(true),
          ]),
        ),
      );
      _controller.addListener(_listen);
      _isInitialized = true;
    }
  }

  // Listener to update the UI based on player state.
  void _listen() {
    if (!mounted) return;
    // This will trigger a rebuild if the playing state changes.
    setState(() {});
  }

  @override
  void dispose() async {
    // Only dispose if the controller was actually initialized.
    if (_isInitialized) {
      _controller.removeListener(_listen);
      await _controller.stop();
      await _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show a placeholder if the URL is invalid or empty.
    if (!_isInitialized || widget.streamUrl.isEmpty) {
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
