import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  final String title = "Select a Robot";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.deepPurple.shade800,
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Robot 1'),
            onTap: () {
              Navigator.pushNamed(context, '/control', arguments: 'Robot 1');
            },
          ),
          ElevatedButton(
            child: Text('Open Config'),
            onPressed: () => Navigator.pushNamed(context, '/config'),
          ),
        ],
      ),
    );
  }
}
