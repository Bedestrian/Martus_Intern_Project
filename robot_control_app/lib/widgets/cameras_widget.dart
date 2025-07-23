import 'package:flutter/material.dart';
import 'package:robot_control_app/widgets/video_player.dart';

class CamerasWidget extends StatefulWidget {
  final String robotName;

  const CamerasWidget({super.key, required this.robotName});

  @override
  State<CamerasWidget> createState() => _CamerasWidgetState();
}

class _CamerasWidgetState extends State<CamerasWidget> {
  final String url = 'rtsp://192.168.0.119:8554/live/test';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(8),
      children: [
        VideoPlayer(
          key: ValueKey('video-player-${widget.robotName}'),
          streamUrl: url,
        ),
      ],
    );
  }
}
