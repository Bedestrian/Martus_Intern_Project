import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robot_control_app/controllers/command_controller.dart';
import 'package:robot_control_app/models/camera_model.dart';
import 'package:robot_control_app/models/commands_model.dart';
import 'package:robot_control_app/services/config_service.dart';
import 'package:robot_control_app/services/gamepad_service.dart';
import 'package:robot_control_app/widgets/video_player_widget.dart';

class CommandWidget extends StatefulWidget {
  final String robotName;
  const CommandWidget({super.key, required this.robotName});

  @override
  State<CommandWidget> createState() => _CommandWidgetState();
}

class _CommandWidgetState extends State<CommandWidget>
    with AutomaticKeepAliveClientMixin {
  late final TextEditingController _ttsController;
  final ConfigService _configService = ConfigService();
  String _frontCameraUrl = '';
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _ttsController = TextEditingController();
    _loadCameraConfig();
  }

  @override
  void dispose() {
    _ttsController.dispose();
    super.dispose();
  }

  Future<void> _loadCameraConfig() async {
    final cameras = await _configService.loadCameras();
    final frontCamera = cameras.firstWhere(
      (cam) => cam.type == 'front',
      orElse: () => CameraModel(type: 'front', url: ''),
    );
    if (mounted) {
      setState(() {
        _frontCameraUrl = frontCamera.url;
        _isLoading = false;
      });
    }
  }

  void _sendTtsMessage() {
    if (_ttsController.text.isNotEmpty) {
      final commandController = context.read<CommandController>();
      commandController.sendCommand(
        CommandsModel(
          name: 'TTS',
          topic: 'robot/tts',
          payload: _ttsController.text,
        ),
      );
      _ttsController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    // You must call super.build(context) when using the mixin.
    super.build(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final commandController = context.watch<CommandController>();
    final gamepadService = context.watch<GamepadService>();

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade700),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: VideoPlayerWidget(streamUrl: _frontCameraUrl),
                ),
              ),
              Expanded(
                flex: 2,
                child: GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: commandController.commands.length,
                  itemBuilder: (context, index) {
                    final command = commandController.commands[index];
                    return ElevatedButton(
                      onPressed: () => commandController.sendCommand(command),
                      child: Text(command.name, textAlign: TextAlign.center),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: gamepadService.isConnected ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  gamepadService.isConnected ? 'GAMEPAD' : 'NO GAMEPAD',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _ttsController,
                  decoration: const InputDecoration(
                    hintText: 'Type message for robot to speak...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onSubmitted: (_) => _sendTtsMessage(),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                icon: const Icon(Icons.send),
                onPressed: _sendTtsMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
