import 'package:flutter/material.dart';
import 'package:robot_control_app/models/settings_model.dart';
import 'package:robot_control_app/services/config_service.dart';

class SettingsEditor extends StatefulWidget {
  const SettingsEditor({super.key});

  @override
  State<SettingsEditor> createState() => _SettingsEditorState();
}

class _SettingsEditorState extends State<SettingsEditor> {
  late TextEditingController ipController;
  late TextEditingController portController;
  late SettingsModel settings;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    settings = await ConfigService().loadSettings();
    ipController = TextEditingController(text: settings.mqttIp);
    portController = TextEditingController(text: settings.mqttPort.toString());
    setState(() => _loading = false);
  }

  void _save() {
    final newSettings = SettingsModel(
      mqttIp: ipController.text.trim(),
      mqttPort: int.tryParse(portController.text.trim()) ?? 1883,
    );
    ConfigService().saveSettings(newSettings);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Settings saved')));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return CircularProgressIndicator();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('MQTT Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        TextField(
          controller: ipController,
          decoration: InputDecoration(labelText: 'MQTT Server IP'),
        ),
        TextField(
          controller: portController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'MQTT Port'),
        ),
        SizedBox(height: 10),
        ElevatedButton(onPressed: _save, child: Text('Save Settings')),
      ],
    );
  }
}
