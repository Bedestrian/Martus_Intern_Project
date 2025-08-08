import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robot_control_app/controllers/command_controller.dart';
import 'package:robot_control_app/models/commands_model.dart';
import 'package:robot_control_app/services/gamepad_service.dart';
import 'package:robot_control_app/widgets/video_player_widget.dart';

class CommandWidget extends StatefulWidget {
  final String frontCameraUrl;
  const CommandWidget({super.key, required this.frontCameraUrl});

  @override
  State<CommandWidget> createState() => _CommandWidgetState();
}

class _CommandWidgetState extends State<CommandWidget>
    with AutomaticKeepAliveClientMixin {
  late final TextEditingController _ttsController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _ttsController = TextEditingController();
  }

  @override
  void dispose() {
    _ttsController.dispose();
    super.dispose();
  }

  void _sendTtsMessage() {
    if (_ttsController.text.isNotEmpty) {
      context.read<CommandController>().sendCommand(
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
    super.build(context);
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
                  // Use the URL passed from the constructor
                  child: VideoPlayerWidget(streamUrl: widget.frontCameraUrl),
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
