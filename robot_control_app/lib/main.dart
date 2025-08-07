import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:robot_control_app/controllers/command_controller.dart';
import 'package:robot_control_app/pages/command_page.dart';
import 'package:robot_control_app/services/gamepad_service.dart';
import 'pages/home_page.dart';
import 'services/mqtt_service.dart';
import 'package:robot_control_app/pages/config_page.dart';

void main() {
  //Makes sure bindings are initialized before using plugins.
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MqttService()),

        ChangeNotifierProxyProvider<MqttService, CommandController>(
          create: (context) => CommandController(context.read<MqttService>()),
          update: (context, mqtt, previous) =>
              previous ?? CommandController(mqtt),
        ),

        ChangeNotifierProxyProvider<CommandController, GamepadService>(
          create: (context) =>
              GamepadService(context.read<CommandController>()),
          update: (context, commands, previous) =>
              previous ?? GamepadService(commands),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final mqttService = context.read<MqttService>();
      final commandController = context.read<CommandController>();
      final gamepadService = context.read<GamepadService>();

      await context.read<MqttService>().initialize();

      if (!mounted) return;

      mqttService.connect();
      commandController.loadCommands();
      gamepadService.start();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Robot Control App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 62, 218, 235),
          brightness: Brightness.light,
        ),
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/control': (context) => const CommandPage(),
        '/config': (context) => const ConfigPage(),
      },
    );
  }
}
