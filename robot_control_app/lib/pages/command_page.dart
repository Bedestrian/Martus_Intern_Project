import 'package:flutter/material.dart';
import '../widgets/cameras_widget.dart';
import '../widgets/command_widget.dart';

class CommandPage extends StatelessWidget {
  const CommandPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String robotName =
        ModalRoute.of(context)?.settings.arguments as String;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Control: $robotName',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.deepPurple.shade900,
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.gamepad)),
              Tab(icon: Icon(Icons.videocam_outlined)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            CommandWidget(robotName: robotName),
            CamerasWidget(robotName: robotName),
          ],
        ),
      ),
    );
  }
}
