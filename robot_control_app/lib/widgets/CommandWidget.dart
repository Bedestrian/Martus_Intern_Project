import 'package:flutter/material.dart';

class CommandWidget extends StatelessWidget {
  final String robotName;

  const CommandWidget({super.key, required this.robotName});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Commands for $robotName'));
  }
}
