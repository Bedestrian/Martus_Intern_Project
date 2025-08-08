import 'package:flutter/material.dart';
import 'package:robot_control_app/widgets/video_player_widget.dart';
import '../models/camera_model.dart';

class CamerasWidget extends StatefulWidget {
  final String frontCameraUrl;
  final String rearCameraUrl;
  final String topCameraUrl;

  const CamerasWidget({
    super.key,
    required this.frontCameraUrl,
    required this.rearCameraUrl,
    required this.topCameraUrl,
  });

  @override
  State<CamerasWidget> createState() => _CamerasWidgetState();
}

class _CamerasWidgetState extends State<CamerasWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Expanded(
                  child: _buildCameraView(widget.frontCameraUrl, 'Front View'),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _buildCameraView(widget.rearCameraUrl, 'Rear View'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: _buildCameraView(widget.topCameraUrl, 'Top Down View'),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraView(String url, String title) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade700),
        borderRadius: BorderRadius.circular(8),
        color: Colors.black26,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: VideoPlayerWidget(streamUrl: url)),
        ],
      ),
    );
  }
}
