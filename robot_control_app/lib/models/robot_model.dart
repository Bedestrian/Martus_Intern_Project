import 'camera_model.dart';
import 'commands_model.dart';

class RobotModel {
  String name;
  String mqttIp;
  int mqttPort;
  List<CommandsModel> commands;
  List<CameraModel> cameras;

  RobotModel({
    required this.name,
    required this.mqttIp,
    required this.mqttPort,
    required this.commands,
    required this.cameras,
  });

  // Factory to create a new robot with default empty settings
  factory RobotModel.newDefault({
    String name = 'New Robot',
    String ip = '192.168.1.100',
    int port = 1883,
  }) {
    return RobotModel(
      name: name,
      mqttIp: ip,
      mqttPort: port,
      commands: [
        // Default commands for a new robot
        CommandsModel(name: '360 Spin', topic: 'robot/motion', payload: 'spin'),
        CommandsModel(name: 'Wave', topic: 'robot/action', payload: 'wave'),
      ],
      cameras: [
        // Default cameras for a new robot
        CameraModel(type: 'front', url: ''),
        CameraModel(type: 'rear', url: ''),
        CameraModel(type: 'top', url: ''),
      ],
    );
  }

  factory RobotModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> commandList = json['commands'] as List<dynamic>? ?? [];
    final List<dynamic> cameraList = json['cameras'] as List<dynamic>? ?? [];

    return RobotModel(
      name: json['name'] ?? 'Robot',
      mqttIp: json['mqttIp'] ?? '192.168.1.100',
      mqttPort: json['mqttPort'] ?? 1883,
      commands: commandList
          .map((c) => CommandsModel.fromJson(c as Map<String, dynamic>))
          .toList(),
      cameras: cameraList
          .map((c) => CameraModel.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'mqttIp': mqttIp,
    'mqttPort': mqttPort,
    'commands': commands.map((c) => c.toJson()).toList(),
    'cameras': cameras.map((c) => c.toJson()).toList(),
  };
}
