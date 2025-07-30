import 'package:flutter/material.dart';
import 'package:robot_control_app/models/camera_model.dart';
import 'package:robot_control_app/services/config_service.dart';
import 'package:robot_control_app/widgets/video_player_widget.dart';

class CamerasWidget extends StatefulWidget {
  final String robotName;
  const CamerasWidget({super.key, required this.robotName});

  @override
  State<CamerasWidget> createState() => _CamerasWidgetState();
}

class _CamerasWidgetState extends State<CamerasWidget> {
  final ConfigService _configService = ConfigService();
  List<CameraModel> _cameras = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCameraConfig();
  }

  Future<void> _loadCameraConfig() async {
    final cameras = await _configService.loadCameras();
    if (mounted) {
      setState(() {
        _cameras = cameras;
        _isLoading = false;
      });
    }
  }

  CameraModel _getCamera(String type) {
    return _cameras.firstWhere(
      (cam) => cam.type == type,
      orElse: () => CameraModel(type: type, url: ''),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final front = _getCamera('front');
    final rear = _getCamera('rear');
    final top = _getCamera('top');

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2, // Takes up 2/3 of the space
            child: Column(
              children: [
                Expanded(child: _buildCameraView(front, 'Front View')),
                const SizedBox(height: 8),
                Expanded(child: _buildCameraView(rear, 'Rear View')),
              ],
            ),
          ),
          Expanded(
            flex: 1, // Takes up 1/3 of the space
            child: _buildCameraView(top, 'Top Down View'),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildCameraView(CameraModel camera, String title) {
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
          Expanded(child: VideoPlayerWidget(streamUrl: camera.url)),
        ],
      ),
    );
  }
}
