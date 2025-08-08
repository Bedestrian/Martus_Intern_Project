import 'package:flutter/material.dart';
import '../models/commands_model.dart';
import '../services/mqtt_service.dart';

class CommandController extends ChangeNotifier {
  final MqttService _mqttService;
  final List<CommandsModel> _commands = [];

  List<CommandsModel> get commands => _commands;

  CommandController(this._mqttService);

  // Set the commands for the current robot session.
  void setCommands(List<CommandsModel> commands) {
    _commands.clear();
    _commands.addAll(commands);
    notifyListeners();
  }

  void sendCommand(CommandsModel command) {
    _mqttService.publish(command.topic, command.payload);
  }
}
