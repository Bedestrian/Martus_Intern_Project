import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gamepads/gamepads.dart';

import '../controllers/command_controller.dart';
import '../models/commands_model.dart';

class GamepadService with ChangeNotifier {
  final CommandController controller;
  Timer? _pollTimer;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  GamepadService(this.controller);

  Future<void> start() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final gamepads = await Gamepads.list(); // SAFE here

      _isConnected = gamepads.isNotEmpty;
      notifyListeners();

      _pollTimer = Timer.periodic(Duration(milliseconds: 50), (_) async {
        final gamepads = await Gamepads.list();
        final hasGamepad = gamepads.isNotEmpty;
        double lastLx = 0.0;
        double lastLy = 0.0;

        // Gamepads.events.listen((event) {
        //   print('Event: ${event.key}, Value: ${event.value}');
        // });

        if (_isConnected != hasGamepad) {
          _isConnected = hasGamepad;
          notifyListeners();
        }

        if (!hasGamepad) return;

        Gamepads.events.listen((event) {
          if (event.key == 'AXIS_X' || event.key == 'AXIS_Y') {
            final lx = (event.key == 'AXIS_X') ? event.value : lastLx;
            final ly = (event.key == 'AXIS_Y') ? event.value : lastLy;

            lastLx = lx;
            lastLy = ly;

            controller.sendCommand(
              CommandsModel(
                name: 'Joystick',
                topic: 'robot/joystick',
                payload: '{"lx": $lx, "ly": $ly}',
              ),
            );
          }
        });
      });
    });
  }

  void stop() => _pollTimer?.cancel();
}
