import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robot_control_app/controllers/command_controller.dart';
import 'package:robot_control_app/pages/command_page.dart';
import 'pages/home_page.dart';
import 'services/mqtt_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final mqttService = MqttService('192.168.0.119'); // your MQTT broker IP
  await mqttService.connect();

  runApp(
    ChangeNotifierProvider(
      create: (_) => CommandController(mqttService),
      child: MyApp(),
    ),
  );
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
