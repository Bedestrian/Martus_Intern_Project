import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robot_control_app/controllers/command_controller.dart';
import 'package:robot_control_app/models/camera_model.dart';
import 'package:robot_control_app/models/commands_model.dart';
import 'package:robot_control_app/services/config_service.dart';
import 'package:robot_control_app/widgets/settings_editor.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  List<CommandsModel> _commands = [];
  bool _isLoading = true;

  final ConfigService _configService = ConfigService();

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _topicCtrl = TextEditingController();
  final TextEditingController _payloadCtrl = TextEditingController();

  late final TextEditingController _frontCamCtrl;
  late final TextEditingController _rearCamCtrl;
  late final TextEditingController _topCamCtrl;

  @override
  void initState() {
    super.initState();
    _frontCamCtrl = TextEditingController();
    _rearCamCtrl = TextEditingController();
    _topCamCtrl = TextEditingController();
    _loadData();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _topicCtrl.dispose();
    _payloadCtrl.dispose();
    _frontCamCtrl.dispose();
    _rearCamCtrl.dispose();
    _topCamCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final cmds = await _configService.loadCommands();
    final cams = await _configService.loadCameras();
    if (mounted) {
      setState(() {
        _commands = cmds;
        _frontCamCtrl.text = cams.firstWhere((c) => c.type == 'front').url;
        _rearCamCtrl.text = cams.firstWhere((c) => c.type == 'rear').url;
        _topCamCtrl.text = cams.firstWhere((c) => c.type == 'top').url;
        _isLoading = false;
      });
    }
  }

  Future<void> _addCommand() async {
    if (_nameCtrl.text.isEmpty) return;

    final newCommand = CommandsModel(
      name: _nameCtrl.text,
      topic: _topicCtrl.text,
      payload: _payloadCtrl.text,
    );

    final updatedCommands = List<CommandsModel>.from(_commands)
      ..add(newCommand);
    await _saveAndReloadCommands(updatedCommands);

    _nameCtrl.clear();
    _topicCtrl.clear();
    _payloadCtrl.clear();
  }

  Future<void> _deleteCommand(int index) async {
    final updatedCommands = List<CommandsModel>.from(_commands)
      ..removeAt(index);
    await _saveAndReloadCommands(updatedCommands);
  }

  Future<void> _saveAndReloadCommands(
    List<CommandsModel> commandsToSave,
  ) async {
    await _configService.saveCommands(commandsToSave);

    if (mounted) {
      await context.read<CommandController>().loadCommands();
    }

    setState(() {
      _commands = commandsToSave;
    });
  }

  Future<void> _saveCameras() async {
    final updatedCameras = [
      CameraModel(type: 'front', url: _frontCamCtrl.text.trim()),
      CameraModel(type: 'rear', url: _rearCamCtrl.text.trim()),
      CameraModel(type: 'top', url: _topCamCtrl.text.trim()),
    ];
    await _configService.saveCameras(updatedCameras);

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Camera settings saved!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Config Manager')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SettingsEditor(),
                  const Divider(height: 40),

                  // Command Editor Section
                  Text(
                    'Manage Commands',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _topicCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Topic',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _payloadCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Payload',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add Command'),
                      onPressed: _addCommand,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ..._commands.asMap().entries.map((entry) {
                    final i = entry.key;
                    final cmd = entry.value;
                    return Card(
                      child: ListTile(
                        title: Text(cmd.name),
                        subtitle: Text(
                          'Topic: ${cmd.topic} | Payload: ${cmd.payload}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                          ),
                          onPressed: () => _deleteCommand(i),
                        ),
                      ),
                    );
                  }),

                  const Divider(height: 40),
                  // Camera Editor Section
                  Text(
                    'Manage Cameras',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _frontCamCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Front Camera URL',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _rearCamCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Rear Camera URL',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _topCamCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Top Down Camera URL',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Save Camera Settings'),
                    onPressed: _saveCameras,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
