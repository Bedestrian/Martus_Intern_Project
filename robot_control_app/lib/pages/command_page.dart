import 'package:flutter/material.dart';
import '../widgets/CamerasWidget.dart';
import '../widgets/CommandWidget.dart';

class CommandPage extends StatelessWidget {
  const CommandPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String robotName =
        ModalRoute.of(context)?.settings.arguments as String ?? 'Unknown Robot';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Control: $robotName'),
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
