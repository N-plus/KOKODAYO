import 'package:flutter/material.dart';
import 'package:kokodayo/simple_provider.dart';

import '../app_state.dart';

class SettingsHelpScreen extends StatelessWidget {
  const SettingsHelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('設定 & ヘルプ')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('役割'),
            subtitle: Text(state.role == 'parent' ? '親' : '子'),
          ),
          ListTile(
            title: const Text('通知の状態'),
            subtitle: const Text('許可済'),
          ),
          const Divider(),
          const ListTile(
            title: Text('ヘルプ'),
            subtitle: Text('・オフラインだと鳴らせません\n・iOSはサイレント/集中モード中は鳴りません\n・安全のため音量にご注意ください'),
          ),
        ],
      ),
    );
  }
}
