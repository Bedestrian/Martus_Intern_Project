import 'package:flutter/material.dart';
import '../models/commands_model.dart';
import '../services/mqtt_service.dart';
import '../services/config_service.dart';

class CommandController extends ChangeNotifier {
  final MqttService _mqttService;
  final ConfigService _configService = ConfigService();
  final List<CommandsModel> _commands = [];

  List<CommandsModel> get commands => _commands;

  // Constructor is now clean and only takes dependencies.
  CommandController(this._mqttService);

  // This method is now called explicitly from main.dart after the app starts.
  Future<void> loadCommands() async {
    final loaded = await _configService.loadCommands();
    if (loaded.isNotEmpty) {
      _commands.clear();
      _commands.addAll(loaded);
    } else {
      // Populate with defaults only if file is missing/empty.
      _commands.addAll([
        CommandsModel(name: '360 Spin', topic: 'robot/motion', payload: 'spin'),
        CommandsModel(
          name: 'Wave High',
          topic: 'robot/action',
          payload: 'wave',
        ),
        CommandsModel(name: 'Nod Yes', topic: 'robot/action', payload: 'nod'),
      ]);
      await _saveCommands(); // Save defaults if they were loaded.
    }
    notifyListeners(); // Notify UI that commands are ready.
  }

  void sendCommand(CommandsModel command) {
    _mqttService.publish(command.topic, command.payload);
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

  Future<void> _saveCommands() async {
    await _configService.saveCommands(_commands);
  }
}
