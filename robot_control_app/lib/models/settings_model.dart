import '/models/robot_model.dart';

class SettingsModel {
  List<RobotModel> robots;

  SettingsModel({required this.robots});

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> robotList = json['robots'] as List<dynamic>? ?? [];
    return SettingsModel(
      robots: robotList
          .map((e) => RobotModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'robots': robots.map((e) => e.toJson()).toList(),
  };
}
