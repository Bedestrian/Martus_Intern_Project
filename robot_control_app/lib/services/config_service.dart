import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/robot_model.dart';
import '../models/settings_model.dart';

class ConfigService {
  static const _settingsFileName = 'settings.json';

  Future<File> get _settingsFile async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_settingsFileName');
  }

  Future<SettingsModel> loadSettings() async {
    try {
      final file = await _settingsFile;
      if (!await file.exists()) {
        // Return a default settings model with one default robot
        return SettingsModel(
          robots: [RobotModel.newDefault(name: 'Default Robot')],
        );
      }
      final contents = await file.readAsString();
      if (contents.isEmpty) {
        return SettingsModel(
          robots: [RobotModel.newDefault(name: 'Default Robot')],
        );
      }
      final jsonData = jsonDecode(contents);
      return SettingsModel.fromJson(jsonData);
    } catch (e) {
      print('Failed to load settings, returning default: $e');
      return SettingsModel(
        robots: [RobotModel.newDefault(name: 'Default Robot')],
      );
    }
  }

  Future<void> saveSettings(SettingsModel settings) async {
    final file = await _settingsFile;
    await file.writeAsString(jsonEncode(settings.toJson()));
  }
}
