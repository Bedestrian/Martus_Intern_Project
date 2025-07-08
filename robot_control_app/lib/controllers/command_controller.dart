import 'package:flutter/material.dart';
import '../models/commands_model.dart';

class CommandController extends ChangeNotifier {
  final List<CommandsModel> _commands = [
    CommandsModel(name: '360', command: () => print("Refreshed")),
    CommandsModel(name: 'forward', command: () => print("Refreshed")),
    CommandsModel(name: 'Wave High', command: () => print("Refreshed")),
  ];

  List<CommandsModel> get commands => _commands;

  void addCommand(CommandsModel command) {
    _commands.add(command);
    notifyListeners(); // tells UI to rebuild
  }

  void removeCommand(CommandsModel command) {
    _commands.remove(command);
    notifyListeners();
  }
}
