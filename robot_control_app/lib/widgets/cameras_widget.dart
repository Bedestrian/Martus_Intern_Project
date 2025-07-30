import 'package:flutter/material.dart';
import 'package:robot_control_app/models/camera_model.dart';
import 'package:robot_control_app/services/config_service.dart';
import 'package:robot_control_app/widgets/video_player_widget.dart'; // Use the revised player

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

  // Helper to safely get a camera by type
  CameraModel _getCamera(String type) {
    return _cameras.firstWhere(
      (cam) => cam.type == type,
      // Return an empty model if not found to prevent crashes
      orElse: () => CameraModel(type: type, url: ''),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Get cameras safely
    final front = _getCamera('front');
    final rear = _getCamera('rear');
    final top = _getCamera('top');
    final other = _getCamera('other');

    return GridView.count(
      padding: const EdgeInsets.all(8),
      crossAxisCount: 2, // 2 cameras per row
      childAspectRatio: 16 / 9,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: [
        _buildCameraView(front, 'Front'),
        _buildCameraView(rear, 'Rear'),
        _buildCameraView(top, 'Top Down'),
        _buildCameraView(other, 'Other'),
      ],
    );
  }

  // Helper widget to build each camera cell
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
