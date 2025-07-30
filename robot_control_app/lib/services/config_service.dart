import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/camera_model.dart';
import '../models/commands_model.dart';
import '../models/settings_model.dart';

class ConfigService {
  // ... (file names and paths remain the same)
  static const _buttonFileName = 'commands_config.json';
  static const _cameraFileName = 'camera_config.json';
  static const _settingsFileName = 'settings.json';

  Future<String> get _localPath async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<File> get _cameraFile async {
    final path = await _localPath;
    return File('$path/$_cameraFileName');
  }

  Future<List<CameraModel>> loadCameras() async {
    try {
      final file = await _cameraFile;
      if (!await file.exists()) {
        // If the file doesn't exist, return a clean default list.
        return _defaultCameras();
      }

      final contents = await file.readAsString();
      if (contents.isEmpty) return _defaultCameras();

      final List jsonData = jsonDecode(contents);
      final loaded = jsonData.map((e) => CameraModel.fromJson(e)).toList();

      // Ensure all 3 required camera types exist, using loaded data if available.
      final types = ['front', 'rear', 'top'];
      final map = {for (var cam in loaded) cam.type: cam};

      return types
          .map((type) => map[type] ?? CameraModel(type: type, url: ''))
          .toList();
    } catch (e) {
      print('Error loading cameras, returning defaults: $e');
      return _defaultCameras();
    }
  }

  Future<void> saveCameras(List<CameraModel> cameras) async {
    final file = await _cameraFile;
    await file.writeAsString(
      jsonEncode(cameras.map((c) => c.toJson()).toList()),
    );
  }

  List<CameraModel> _defaultCameras() {
    return [
      CameraModel(type: 'front', url: ''),
      CameraModel(type: 'rear', url: ''),
      CameraModel(type: 'top', url: ''),
    ];
  }

  Future<File> get _buttonFile async {
    final path = await _localPath;
    return File('$path/$_buttonFileName');
  }

  Future<void> saveCommands(List<CommandsModel> commands) async {
    final file = await _buttonFile;
    final jsonList = commands.map((e) => e.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }

  Future<List<CommandsModel>> loadCommands() async {
    try {
      final file = await _buttonFile;
      if (!await file.exists()) return [];
      final contents = await file.readAsString();
      final json = jsonDecode(contents) as List;
      return json.map((e) => CommandsModel.fromJson(e)).toList();
    } catch (e) {
      print('Error loading commands: $e');
      return [];
    }
  }

  Future<File> get _settingsFile async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_settingsFileName');
  }

  Future<SettingsModel> loadSettings() async {
    final file = await _settingsFile;
    if (!await file.exists()) {
      return SettingsModel(mqttIp: '192.168.1.100', mqttPort: 1883); // default
    }

    try {
      final contents = await file.readAsString();
      final jsonData = jsonDecode(contents);
      return SettingsModel.fromJson(jsonData);
    } catch (e) {
      print('Failed to load settings: $e');
      return SettingsModel(mqttIp: '192.168.1.100', mqttPort: 1883);
    }
  }

  Future<void> saveSettings(SettingsModel settings) async {
    final file = await _settingsFile;
    await file.writeAsString(jsonEncode(settings.toJson()));
  }
}
