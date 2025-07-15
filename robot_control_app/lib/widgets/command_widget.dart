import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robot_control_app/controllers/command_controller.dart';
import 'package:robot_control_app/models/commands_model.dart';

class CommandWidget extends StatelessWidget {
  final String robotName;
  final TextEditingController ttsController = TextEditingController();
  CommandWidget({super.key, required this.robotName});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<CommandController>(context);

    return ListView(
      children: [
        Column(children: [commandText(), commandButtons(controller)]),
        ttsField(controller),
      ],
    );
  }

  Padding commandText() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        'Commads',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Container commandButtons(CommandController controller) {
    return Container(
      height: 200,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView.builder(
        itemCount: controller.commands.length,
        itemBuilder: (BuildContext context, int index) {
          final command = controller.commands[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: ElevatedButton(
              onPressed: () => controller.sendCommand(command),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                elevation: 4,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
              ),

              child: Text(command.name),
            ),
          );
        },
      ),
    );
  }

  //text field for send tts messages to the robot
  Padding ttsField(CommandController controller) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: ttsController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(9.0)),
                ),
                hintText: 'Type Here to make the robot speak... ',
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              final message = ttsController.text;
              CommandsModel command = CommandsModel(
                name: 'TTS',
                topic: 'robot/tts',
                payload: message,
              );
              controller.sendCommand(command);
              ttsController.clear();
            },
          ),
        ],
      ),
    );
  }
}
