import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gamepads/gamepads.dart';
import '../widgets/cameras_widget.dart';
import '../widgets/command_widget.dart';

class CommandPage extends StatefulWidget {
  const CommandPage({super.key});

  @override
  State<CommandPage> createState() => _CommandPageState();
}

class _CommandPageState extends State<CommandPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  StreamSubscription? _gamepadSub;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _listenToGamepadEvents();
  }

  void _listenToGamepadEvents() {
    _gamepadSub = Gamepads.events.listen((event) {
      double value = event.value;
      //print(_tabController.index);
      if (event.key == 'AXIS_HAT_X') {
        //print(event.value);
        if (value == -1.0) {
          //print('here');
          if (_tabController.index > 0) {
            _tabController.animateTo(0);
          }
        } else if (value == 1.0) {
          if (_tabController.index < _tabController.length - 1) {
            _tabController.animateTo(1);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _gamepadSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String robotName =
        ModalRoute.of(context)?.settings.arguments as String;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'Control: $robotName',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple.shade900,
        bottom: TabBar(
          controller: _tabController, // ✅ Use your controller here
          tabs: const [
            Tab(icon: Icon(Icons.gamepad)),
            Tab(icon: Icon(Icons.videocam_outlined)),
          ],
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: TabBarView(
          controller: _tabController, // ✅ And here too
          children: [
            CommandWidget(robotName: robotName),
            CamerasWidget(robotName: robotName),
          ],
        ),
      ),
    );
  }
}
