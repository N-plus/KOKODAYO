import 'dart:async';

import 'package:flutter/material.dart';

class ChildAlarmScreen extends StatefulWidget {
  const ChildAlarmScreen({Key? key}) : super(key: key);

  @override
  State<ChildAlarmScreen> createState() => _ChildAlarmScreenState();
}

class _ChildAlarmScreenState extends State<ChildAlarmScreen> {
  late Timer _timer;
  int _seconds = 60;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds <= 1) {
        timer.cancel();
        Navigator.pop(context);
      } else {
        setState(() => _seconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.volume_up, size: 64),
            const SizedBox(height: 16),
            const Text('端末を探しています…'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('停止'),
            ),
            const SizedBox(height: 16),
            Text('自動停止まで $_seconds 秒'),
          ],
        ),
      ),
    );
  }
}
