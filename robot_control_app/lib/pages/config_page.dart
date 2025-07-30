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
  List<CameraModel> _cameras = [];
  bool _isLoading = true;

  final ConfigService _configService = ConfigService();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _topicCtrl = TextEditingController();
  final TextEditingController _payloadCtrl = TextEditingController();
  final TextEditingController _camNameCtrl = TextEditingController();
  final TextEditingController _camUrlCtrl = TextEditingController();
  final TextEditingController _camTypeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _topicCtrl.dispose();
    _payloadCtrl.dispose();
    _camUrlCtrl.dispose();
    _camTypeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final cmds = await _configService.loadCommands();
    final cams = await _configService.loadCameras();
    if (mounted) {
      setState(() {
        _commands = cmds;
        _cameras = cams;
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

  Future<void> _addCamera() async {
    final cam = CameraModel(url: _camUrlCtrl.text, type: _camTypeCtrl.text);
    setState(() {
      _cameras.add(cam);
    });
    await _configService.saveCameras(_cameras);
    _camUrlCtrl.clear();
    _camTypeCtrl.clear();
  }

  Future<void> _deleteCamera(int index) async {
    setState(() {
      _cameras.removeAt(index);
    });
    await _configService.saveCameras(_cameras);
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
                  Text(
                    'Add Camera:',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextField(
                    controller: _camNameCtrl,
                    decoration: InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: _camUrlCtrl,
                    decoration: InputDecoration(labelText: 'Stream URL'),
                  ),
                  TextField(
                    controller: _camTypeCtrl,
                    decoration: InputDecoration(
                      labelText: 'Type (front/rear/top)',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _addCamera,
                    child: Text('Add Camera'),
                  ),

                  const SizedBox(height: 20),
                  Text(
                    'Cameras:',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  ..._cameras.asMap().entries.map((entry) {
                    final i = entry.key;
                    final cam = entry.value;
                    return ListTile(
                      subtitle: Text('${cam.type} | ${cam.url}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteCamera(i),
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}
