import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class VideoPlayer extends StatefulWidget {
  final String streamUrl;
  final double aspectRatio;

  const VideoPlayer({
    super.key,
    required this.streamUrl,
    this.aspectRatio = 16 / 9,
  });

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  late VlcPlayerController vlcPlayerController;

  @override
  void initState() {
    super.initState();

    vlcPlayerController = VlcPlayerController.network(
      widget.streamUrl,
      autoPlay: true,
      options: VlcPlayerOptions(),
    );
  }

  @override
  void dispose() {
    vlcPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromARGB(255, 1, 144, 176),
      child: VlcPlayer(
        controller: vlcPlayerController,
        aspectRatio: widget.aspectRatio,
        placeholder: Container(color: Colors.black),
      ),
    );
  }
}
