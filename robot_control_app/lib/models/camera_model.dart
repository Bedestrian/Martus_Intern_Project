class CameraModel {
  String type; // values: 'front', 'rear', 'top', 'other'
  String url;

  CameraModel({required this.type, required this.url});

  factory CameraModel.fromJson(Map<String, dynamic> json) {
    return CameraModel(type: json['type'], url: json['url']);
  }

  Map<String, dynamic> toJson() => {'type': type, 'url': url};
}
