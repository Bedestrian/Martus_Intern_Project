import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/commands_model.dart';
import '../models/camera_model.dart';

class ConfigService {
  static const _buttonFileName = 'commands_config.json';
  static const _cameraFileName = 'camera_config.json';

  Future<String> get _localPath async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<File> get _buttonFile async {
    final path = await _localPath;
    return File('$path/$_buttonFileName');
  }

  Future<File> get _cameraFile async {
    final path = await _localPath;
    return File('$path/$_cameraFileName');
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

  Future<void> saveCameras(List<CameraModel> cameras) async {
    final file = await _cameraFile;
    final jsonList = cameras.map((e) => e.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }

  Future<List<CameraModel>> loadCameras() async {
    try {
      final file = await _cameraFile;
      if (!await file.exists()) return [];
      final contents = await file.readAsString();
      final json = jsonDecode(contents) as List;
      return json.map((e) => CameraModel.fromJson(e)).toList();
    } catch (e) {
      print('Error loading cameras: $e');
      return [];
    }
  }
}
