import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gamepads/gamepads.dart';
import 'package:provider/provider.dart';
import 'package:robot_control_app/controllers/command_controller.dart';
import 'package:robot_control_app/models/camera_model.dart';
import '../models/robot_model.dart';
import '../services/gamepad_service.dart';
import '../services/mqtt_service.dart';
import '../widgets/cameras_widget.dart';
import '../widgets/command_widget.dart';

class CommandPage extends StatefulWidget {
  const CommandPage({super.key});

  @override
  State<CommandPage> createState() => _CommandPageState();
}

class _CommandPageState extends State<CommandPage>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  StreamSubscription? _gamepadSub;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _listenToGamepadEvents();
  }

  void _listenToGamepadEvents() {
    _gamepadSub = Gamepads.events.listen((event) {
      if (!mounted) return;
      double value = event.value;
      if (event.key == 'AXIS_HAT_X') {
        if (value == -1.0) {
          if (_tabController.index > 0) _tabController.animateTo(0);
        } else if (value == 1.0) {
          if (_tabController.index < _tabController.length - 1) {
            _tabController.animateTo(1);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _gamepadSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final robot = ModalRoute.of(context)?.settings.arguments;

    if (robot is! RobotModel) {
      return const Scaffold(
        body: Center(
          child: Text('Error: No robot selected or invalid argument.'),
        ),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MqttService(robot: robot)),
        ChangeNotifierProxyProvider<MqttService, CommandController>(
          create: (context) => CommandController(context.read<MqttService>()),
          update: (_, mqtt, previous) => previous ?? CommandController(mqtt),
        ),
        ChangeNotifierProxyProvider<CommandController, GamepadService>(
          create: (context) =>
              GamepadService(context.read<CommandController>()),
          update: (_, commands, previous) =>
              previous ?? GamepadService(commands),
        ),
      ],
      child: CommandPageContent(robot: robot, tabController: _tabController),
    );
  }
}

class CommandPageContent extends StatefulWidget {
  final RobotModel robot;
  final TabController tabController;

  const CommandPageContent({
    super.key,
    required this.robot,
    required this.tabController,
  });

  @override
  State<CommandPageContent> createState() => _CommandPageContentState();
}

class _CommandPageContentState extends State<CommandPageContent> {
  // Hold references to services to use them safely in dispose().
  GamepadService? _gamepadService;
  MqttService? _mqttService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _gamepadService = context.read<GamepadService>();
      _mqttService = context.read<MqttService>();
      final commandController = context.read<CommandController>();

      commandController.setCommands(widget.robot.commands);

      _mqttService?.initialize().then((_) {
        if (mounted) {
          _mqttService?.connect();
          _gamepadService?.start();
        }
      });
    });
  }

  @override
  void dispose() {
    _gamepadService?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String getCameraUrl(String type) {
      return widget.robot.cameras
          .firstWhere(
            (cam) => cam.type == type,
            orElse: () => CameraModel(type: type, url: ''),
          )
          .url;
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'Control: ${widget.robot.name}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 62, 218, 235),
        bottom: TabBar(
          controller: widget.tabController,
          tabs: const [
            Tab(icon: Icon(Icons.gamepad)),
            Tab(icon: Icon(Icons.videocam_outlined)),
          ],
        ),
      ),
      body: TabBarView(
        controller: widget.tabController,
        children: [
          CommandWidget(frontCameraUrl: getCameraUrl('front')),
          CamerasWidget(
            frontCameraUrl: getCameraUrl('front'),
            rearCameraUrl: getCameraUrl('rear'),
            topCameraUrl: getCameraUrl('top'),
          ),
        ],
      ),
    );
  }
}
