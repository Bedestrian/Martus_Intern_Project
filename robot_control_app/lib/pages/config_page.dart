import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:robot_control_app/models/commands_model.dart';
import 'package:robot_control_app/models/robot_model.dart';
import 'package:robot_control_app/models/settings_model.dart';
import 'package:robot_control_app/services/config_service.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  final ConfigService _configService = ConfigService();
  List<RobotModel> _robots = [];
  bool _isLoading = true;

  final Map<RobotModel, bool> _expansionState = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final settings = await _configService.loadSettings();
    if (mounted) {
      setState(() {
        _robots = settings.robots;
        for (var robot in _robots) {
          _expansionState[robot] = false;
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _saveChanges() async {
    await _configService.saveSettings(SettingsModel(robots: _robots));
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('All changes saved!')));
    }
  }

  void _addRobot() {
    setState(() {
      final newRobot = RobotModel.newDefault();
      _robots.add(newRobot);
      _expansionState[newRobot] = true;
    });
  }

  void _deleteRobot(RobotModel robot) {
    setState(() {
      _robots.remove(robot);
      _expansionState.remove(robot);
    });
  }

  Future<void> _importConfiguration() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null && result.files.single.path != null) {
      try {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        await _configService.importSettings(jsonString);
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Configuration imported successfully!'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to import configuration: $e')),
          );
        }
      }
    }
  }

  // --- MODIFIED SECTION ---
  Future<void> _exportConfiguration() async {
    try {
      // First, get the content to be saved.
      final jsonString = await _configService.exportSettings();
      // Convert the string content to bytes (Uint8List).
      final bytes = utf8.encode(jsonString);

      // Call saveFile and provide the bytes directly.
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Your Configuration',
        fileName: 'robot_settings.json',
        bytes: bytes,
      );

      if (outputFile == null) {
        // User canceled the picker.
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Configuration saved successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export configuration: $e')),
        );
      }
    }
  }
  // --- END OF MODIFIED SECTION ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Config Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload),
            tooltip: 'Import Configuration',
            onPressed: _importConfiguration,
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'Export Configuration',
            onPressed: _exportConfiguration,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save All Changes',
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _robots.length,
              itemBuilder: (context, index) {
                return _buildRobotConfigTile(_robots[index]);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addRobot,
        icon: const Icon(Icons.add),
        label: const Text('Add New Robot'),
      ),
    );
  }

  Widget _buildRobotConfigTile(RobotModel robot) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        key: ObjectKey(robot),
        title: Text(
          robot.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        initiallyExpanded: _expansionState[robot] ?? false,
        onExpansionChanged: (isExpanded) {
          setState(() {
            _expansionState[robot] = isExpanded;
          });
        },
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Connection Settings'),
                TextFormField(
                  initialValue: robot.name,
                  decoration: const InputDecoration(labelText: 'Robot Name'),
                  onChanged: (value) => setState(() => robot.name = value),
                ),
                TextFormField(
                  initialValue: robot.mqttIp,
                  decoration: const InputDecoration(labelText: 'MQTT IP'),
                  onChanged: (value) => setState(() => robot.mqttIp = value),
                ),
                TextFormField(
                  initialValue: robot.mqttPort.toString(),
                  decoration: const InputDecoration(labelText: 'MQTT Port'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => setState(
                    () => robot.mqttPort = int.tryParse(value) ?? 1883,
                  ),
                ),
                const Divider(height: 30),
                _buildSectionHeader('Camera Feeds'),
                ...robot.cameras.map(
                  (cam) => TextFormField(
                    initialValue: cam.url,
                    decoration: InputDecoration(
                      labelText: '${cam.type.toUpperCase()} Camera URL',
                    ),
                    onChanged: (value) => setState(() => cam.url = value),
                  ),
                ),
                const Divider(height: 30),
                _buildSectionHeader('Custom Commands'),
                ...robot.commands.asMap().entries.map((entry) {
                  int idx = entry.key;
                  CommandsModel cmd = entry.value;
                  return _buildCommandEditor(robot, cmd, idx);
                }),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Add Command'),
                    onPressed: () => setState(() {
                      robot.commands.add(
                        CommandsModel(
                          name: 'New Command',
                          topic: 'topic',
                          payload: 'payload',
                        ),
                      );
                    }),
                  ),
                ),
                const Divider(height: 30),
                Center(
                  child: TextButton.icon(
                    onPressed: () => _deleteRobot(robot),
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    label: const Text(
                      'Delete This Robot',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  Widget _buildCommandEditor(
    RobotModel robot,
    CommandsModel command,
    int index,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextFormField(
            initialValue: command.name,
            decoration: const InputDecoration(labelText: 'Name'),
            onChanged: (value) => setState(() => command.name = value),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            initialValue: command.topic,
            decoration: const InputDecoration(labelText: 'Topic'),
            onChanged: (value) => setState(() => command.topic = value),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            initialValue: command.payload,
            decoration: const InputDecoration(labelText: 'Payload'),
            onChanged: (value) => setState(() => command.payload = value),
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.remove_circle_outline,
            color: Colors.redAccent,
          ),
          onPressed: () => setState(() => robot.commands.removeAt(index)),
        ),
      ],
    );
  }
}
