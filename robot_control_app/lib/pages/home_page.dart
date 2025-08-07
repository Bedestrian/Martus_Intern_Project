import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  final String title = "Select a Robot";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color.fromARGB(255, 62, 218, 235),
      ),
      body: Row(
        children: [
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: const Text('Robot 1'),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/control',
                      arguments: 'Robot 1',
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ElevatedButton(
                    child: const Text('Open Config'),
                    onPressed: () => Navigator.pushNamed(context, '/config'),
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
