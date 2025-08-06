import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gamepads/gamepads.dart';
import '../controllers/command_controller.dart';
import '../models/commands_model.dart';

class GamepadService with ChangeNotifier {
  final CommandController controller;
  StreamSubscription? _gamepadEventSubscription;
  Timer? _joystickPublishTimer;
  Timer? _connectionCheckTimer;

  bool _isConnected = false;

  double _lastLx = 0.0;
  double _lastLy = 0.0;

  bool get isConnected => _isConnected;

  static const double _joystickDeadzone = 0.03;

  GamepadService(this.controller);

  void start() {
    _gamepadEventSubscription = Gamepads.events.listen((event) {
      double value = event.value;

      if (value.abs() < _joystickDeadzone) {
        value = 0.0;
      }

      if (event.key == 'AXIS_X') {
        _lastLx = value;
      } else if (event.key == 'AXIS_Y') {
        _lastLy = value;
      }

      // You can handle button presses here as well, e.g.,
      // if (event.key == 'BUTTON_A' && event.value == 1.0) { ... }
    });

    _joystickPublishTimer = Timer.periodic(const Duration(milliseconds: 50), (
      _,
    ) {
      if (_isConnected) {
        controller.sendCommand(
          CommandsModel(
            name: 'Joystick',
            topic: 'robot/joystick',
            payload: '{"lx": $_lastLx, "ly": $_lastLy}',
          ),
        );
      }
    });

    _connectionCheckTimer = Timer.periodic(const Duration(seconds: 2), (
      _,
    ) async {
      final gamepads = await Gamepads.list();
      final hasGamepad = gamepads.isNotEmpty;
      if (_isConnected != hasGamepad) {
        _isConnected = hasGamepad;
        notifyListeners();
      }
    });
  }

  void stop() {
    _gamepadEventSubscription?.cancel();
    _joystickPublishTimer?.cancel();
    _connectionCheckTimer?.cancel();
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
