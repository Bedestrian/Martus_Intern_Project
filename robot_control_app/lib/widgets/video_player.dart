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
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    initPlayer();
  }

  void initPlayer() {
    try {
      vlcPlayerController = VlcPlayerController.network(
        widget.streamUrl,
        hwAcc: HwAcc.full,
        autoPlay: true,
        options: VlcPlayerOptions(),
      );
    } catch (e) {
      //print(e);
      hasError = true;
    }
  }

  @override
  void dispose() {
    vlcPlayerController.stop();
    vlcPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return Container(
        height: 200,
        color: Colors.black,
        child: const Center(child: Text('Stream unavailable')),
      );
    }
    return Container(
      color: Color.fromARGB(255, 112, 112, 112),
      child: VlcPlayer(
        controller: vlcPlayerController,
        aspectRatio: widget.aspectRatio,
        placeholder: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
