import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robot_control_app/controllers/command_controller.dart';
import 'package:robot_control_app/pages/command_page.dart';
import 'package:robot_control_app/services/gamepad_service.dart';
import 'pages/home_page.dart';
import 'services/mqtt_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final mqttService = MqttService('192.168.0.119'); // your MQTT broker IP
  final commandController = CommandController(mqttService);
  final gamepadService = GamepadService(commandController);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => commandController),
        ChangeNotifierProvider(create: (_) => gamepadService),
      ],

      child: MyApp(),
    ),
  );

  await mqttService.connect();
  await gamepadService.start();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Robot Control App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple.shade800,
          brightness: Brightness.dark,
        ),
        brightness: Brightness.dark,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/control': (context) => CommandPage(),
      },
    );
  }
}
