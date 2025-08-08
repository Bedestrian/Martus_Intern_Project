import 'package:flutter/material.dart';
import 'package:robot_control_app/services/config_service.dart';
import '../models/robot_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  final String title = "Select a Robot";

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ConfigService _configService = ConfigService();
  List<RobotModel>? _robots;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRobots();
  }

  Future<void> _loadRobots() async {
    final settings = await _configService.loadSettings();
    if (mounted) {
      setState(() {
        _robots = settings.robots;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color.fromARGB(255, 62, 218, 235),
      ),
      body: _isLoading || _robots == null
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      ..._robots!.map(
                        (robot) => ListTile(
                          title: Text(robot.name),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/control',
                              arguments: robot,
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: ElevatedButton(
                          child: const Text('Open Config'),
                          onPressed: () async {
                            await Navigator.pushNamed(context, '/config');
                            _loadRobots(); // Refresh the list after config changes
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(70.0),
                  child: Image.asset('assets/splash/bedestrian_logo.png'),
                ),
              ],
            ),
    );
  }
}
