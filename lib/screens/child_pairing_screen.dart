import 'package:flutter/material.dart';
import 'package:kokodayo/simple_provider.dart';

import '../app_state.dart';
import '../models/device.dart';

class ChildPairingScreen extends StatefulWidget {
  const ChildPairingScreen({Key? key}) : super(key: key);

  @override
  State<ChildPairingScreen> createState() => _ChildPairingScreenState();
}

class _ChildPairingScreenState extends State<ChildPairingScreen> {
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  bool _verified = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('ペアリング')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: !_verified ? _buildCodeInput(state) : _buildNickname(state),
      ),
    );
  }

  Widget _buildCodeInput(AppState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('親の画面に表示された6桁コードを入力してください'),
        TextField(
          controller: _codeController,
          maxLength: 6,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(errorText: _error),
        ),
        const Spacer(),
        Center(
          child: ElevatedButton(
            onPressed: () {
              if (state.verifyCode(_codeController.text)) {
                setState(() {
                  _verified = true;
                  _error = null;
                });
              } else {
                setState(() {
                  _error = 'コードが無効です';
                });
              }
            },
            child: const Text('次へ'),
          ),
        )
      ],
    );
  }

  Widget _buildNickname(AppState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('この端末の名前'),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(hintText: '娘のスマホ'),
        ),
        const Spacer(),
        Center(
          child: ElevatedButton(
            onPressed: () {
              state.addDevice(Device(
                  name: _nameController.text.isEmpty
                      ? '未設定'
                      : _nameController.text,
                  lastSeen: DateTime.now()));
              Navigator.pushReplacementNamed(context, '/childAlarm');
            },
            child: const Text('完了'),
          ),
        )
      ],
    );
  }
}
