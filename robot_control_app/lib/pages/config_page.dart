import 'package:flutter/material.dart';
import 'package:robot_control_app/models/commands_model.dart';
import 'package:robot_control_app/models/camera_model.dart';
import 'package:robot_control_app/services/config_service.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  List<CommandsModel> commands = [];
  List<CameraModel> cameras = [];
  final configService = ConfigService();

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController topicCtrl = TextEditingController();
  final TextEditingController payloadCtrl = TextEditingController();

  final TextEditingController camNameCtrl = TextEditingController();
  final TextEditingController camUrlCtrl = TextEditingController();
  final TextEditingController camTypeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final cmds = await configService.loadCommands();
    final cams = await configService.loadCameras();
    setState(() {
      commands = cmds;
      cameras = cams;
    });
  }

  Future<void> addCommand() async {
    final cmd = CommandsModel(
      name: nameCtrl.text,
      topic: topicCtrl.text,
      payload: payloadCtrl.text,
    );
    setState(() {
      commands.add(cmd);
    });
    await configService.saveCommands(commands);
    nameCtrl.clear();
    topicCtrl.clear();
    payloadCtrl.clear();
  }

  Future<void> deleteCommand(int index) async {
    setState(() {
      commands.removeAt(index);
    });
    await configService.saveCommands(commands);
  }

  Future<void> addCamera() async {
    final cam = CameraModel(
      name: camNameCtrl.text,
      url: camUrlCtrl.text,
      type: camTypeCtrl.text,
    );
    setState(() {
      cameras.add(cam);
    });
    await configService.saveCameras(cameras);
    camNameCtrl.clear();
    camUrlCtrl.clear();
    camTypeCtrl.clear();
  }

  Future<void> deleteCamera(int index) async {
    setState(() {
      cameras.removeAt(index);
    });
    await configService.saveCameras(cameras);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Config Manager')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Command:', style: Theme.of(context).textTheme.titleLarge),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: topicCtrl,
              decoration: InputDecoration(labelText: 'Topic'),
            ),
            TextField(
              controller: payloadCtrl,
              decoration: InputDecoration(labelText: 'Payload'),
            ),
            ElevatedButton(onPressed: addCommand, child: Text('Add Command')),

            const SizedBox(height: 20),
            Text('Commands:', style: Theme.of(context).textTheme.titleLarge),
            ...commands.asMap().entries.map((entry) {
              final i = entry.key;
              final cmd = entry.value;
              return ListTile(
                title: Text(cmd.name),
                subtitle: Text('${cmd.topic} | ${cmd.payload}'),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => deleteCommand(i),
                ),
              );
            }),

            const Divider(),
            Text('Add Camera:', style: Theme.of(context).textTheme.titleLarge),
            TextField(
              controller: camNameCtrl,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: camUrlCtrl,
              decoration: InputDecoration(labelText: 'Stream URL'),
            ),
            TextField(
              controller: camTypeCtrl,
              decoration: InputDecoration(labelText: 'Type (front/rear/top)'),
            ),
            ElevatedButton(onPressed: addCamera, child: Text('Add Camera')),

            const SizedBox(height: 20),
            Text('Cameras:', style: Theme.of(context).textTheme.titleLarge),
            ...cameras.asMap().entries.map((entry) {
              final i = entry.key;
              final cam = entry.value;
              return ListTile(
                title: Text(cam.name),
                subtitle: Text('${cam.type} | ${cam.url}'),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => deleteCamera(i),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
