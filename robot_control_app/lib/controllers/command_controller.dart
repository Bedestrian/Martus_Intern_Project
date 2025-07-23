import 'package:flutter/material.dart';
import '../models/commands_model.dart';
import '../services/mqtt_service.dart';
import '../services/config_service.dart';

class CommandController extends ChangeNotifier {
  final List<CommandsModel> _commands = [];

  final MqttService mqttService;
  final ConfigService _configService = ConfigService();

  CommandController(this.mqttService) {
    _loadCommands();
  }

  List<CommandsModel> get commands => _commands;

  void sendCommand(CommandsModel command) {
    mqttService.publish(command.topic, command.payload);
  }

  void addCommand(CommandsModel command) {
    _commands.add(command);
    notifyListeners();
    _saveCommands();
  }

  void removeCommand(CommandsModel command) {
    _commands.remove(command);
    notifyListeners();
    _saveCommands();
  }

  Future<void> _loadCommands() async {
    final loaded = await _configService.loadCommands();
    if (loaded.isNotEmpty) {
      _commands.clear();
      _commands.addAll(loaded);
      notifyListeners();
    } else {
      //pulate with defaults only if file missing/empty
      _commands.addAll([
        CommandsModel(name: '360', topic: 'robot/motion', payload: 'spin'),
        CommandsModel(
          name: 'forward',
          topic: 'robot/motion',
          payload: 'forward',
        ),
        CommandsModel(
          name: 'Wave High',
          topic: 'robot/action',
          payload: 'wave',
        ),
      ]);
      _saveCommands();
    }
  }

  Future<void> _saveCommands() async {
    await _configService.saveCommands(_commands);
  }
}
