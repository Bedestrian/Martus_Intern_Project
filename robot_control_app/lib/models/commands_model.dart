class CommandsModel {
  String name;
  String topic;
  String payload;

  CommandsModel({
    required this.name,
    required this.topic,
    required this.payload,
  });

  factory CommandsModel.fromJson(Map<String, dynamic> json) {
    return CommandsModel(
      name: json['name'],
      topic: json['topic'],
      payload: json['payload'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'topic': topic, 'payload': payload};
  }
}
