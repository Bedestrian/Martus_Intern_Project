import 'package:flutter/material.dart';

class CamerasWidget extends StatelessWidget {
  final String robotName;

  const CamerasWidget({super.key, required this.robotName});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Camera feed for $robotName'));
  }
}
