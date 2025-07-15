import 'package:flutter/material.dart';
import '../models/commands_model.dart';
import '../services/mqtt_service.dart';

class CommandController extends ChangeNotifier {
  final List<CommandsModel> _commands = [
    CommandsModel(name: '360', topic: 'robot/motion', payload: 'spin'),
    CommandsModel(name: 'forward', topic: 'robot/motion', payload: 'forward'),
    CommandsModel(name: 'Wave High', topic: 'robot/action', payload: 'wave'),
  ];

  final MqttService mqttService;

  CommandController(this.mqttService);

  List<CommandsModel> get commands => _commands;

  void sendCommand(CommandsModel command) {
    mqttService.publish(command.topic, command.payload);
  }

  void addCommand(CommandsModel command) {
    _commands.add(command);
    notifyListeners(); // tells UI to rebuild
  }

  void removeCommand(CommandsModel command) {
    _commands.remove(command);
    notifyListeners();
  }
}
