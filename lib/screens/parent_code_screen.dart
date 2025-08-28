import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';

class ParentCodeScreen extends StatefulWidget {
  const ParentCodeScreen({Key? key}) : super(key: key);

  @override
  State<ParentCodeScreen> createState() => _ParentCodeScreenState();
}

class _ParentCodeScreenState extends State<ParentCodeScreen> {
  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    state.generateCode();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final remaining = state.remaining;
    final minutes = remaining != null ? remaining.inMinutes.remainder(60) : 0;
    final seconds = remaining != null ? remaining.inSeconds.remainder(60) : 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('デバイスを追加'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('子端末に表示/入力してもらう「家族コード」'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black45, width: 2)),
              child: Text(
                state.pairingCode ?? '------',
                style: const TextStyle(fontSize: 32, letterSpacing: 4),
              ),
            ),
            const SizedBox(height: 8),
            Text('残り ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')} で更新'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => state.generateCode(),
              child: const Text('コードを更新'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/parentHome');
              },
              child: const Text('ホームへ'),
            )
          ],
        ),
      ),
    );
  }
}
