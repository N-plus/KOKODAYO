import 'package:flutter/material.dart';
import 'package:kokodayo/simple_provider.dart';

import '../app_state.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _role;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('迷子スマホ探索')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('この端末の役割を選んでください'),
            RadioListTile<String>(
              title: const Text('親（探す側）'),
              value: 'parent',
              groupValue: _role,
              onChanged: (v) => setState(() => _role = v),
            ),
            RadioListTile<String>(
              title: const Text('子（鳴らされる側）'),
              value: 'child',
              groupValue: _role,
              onChanged: (v) => setState(() => _role = v),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: _role == null
                    ? null
                    : () {
                        state.setRole(_role);
                        if (_role == 'parent') {
                          Navigator.pushReplacementNamed(
                              context, '/parentCode');
                        } else {
                          Navigator.pushReplacementNamed(
                              context, '/childPair');
                        }
                      },
                child: const Text('はじめる'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
