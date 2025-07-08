import 'package:flutter/material.dart';

class CommandsModel {
  String name;
  VoidCallback command;

  CommandsModel({
    required this.name,
    required this.command, //place holder text when I have real commands to send to the robot
  });
}
