class CameraModel {
  String name;
  String url;
  String type; // e.g. "front", "rear", "top"

  CameraModel({required this.name, required this.url, required this.type});

  factory CameraModel.fromJson(Map<String, dynamic> json) {
    return CameraModel(
      name: json['name'],
      url: json['url'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'url': url, 'type': type};
  }
}
