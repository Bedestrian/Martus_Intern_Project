class SettingsModel {
  String mqttIp;
  int mqttPort;

  SettingsModel({required this.mqttIp, required this.mqttPort});

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      mqttIp: json['mqttIp'] ?? '192.168.1.100',
      mqttPort: json['mqttPort'] ?? 1883,
    );
  }

  Map<String, dynamic> toJson() => {'mqttIp': mqttIp, 'mqttPort': mqttPort};
}
