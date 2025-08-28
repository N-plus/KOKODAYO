import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../models/device.dart';

class ParentHomeScreen extends StatelessWidget {
  const ParentHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('迷子スマホ探索'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/parentCode');
            },
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text('メニュー')),
            ListTile(
              title: const Text('設定 & ヘルプ'),
              onTap: () => Navigator.pushNamed(context, '/settings'),
            ),
          ],
        ),
      ),
      body: state.devices.isEmpty
          ? const Center(child: Text('まだデバイスがありません'))
          : ListView.builder(
              itemCount: state.devices.length,
              itemBuilder: (context, index) {
                final device = state.devices[index];
                return _DeviceTile(device: device);
              },
            ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  const _DeviceTile({required this.device});
  final Device device;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(device.online ? Icons.circle : Icons.circle_outlined,
          color: device.online ? Colors.green : Colors.grey),
      title: Text(device.name),
      subtitle: Text('最終: ${device.lastSeen.hour.toString().padLeft(2, '0')}:${device.lastSeen.minute.toString().padLeft(2, '0')}'),
      trailing: ElevatedButton(
        onPressed: device.online
            ? () {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${device.name} を鳴らします')));
              }
            : null,
        child: const Text('鳴らす'),
      ),
    );
  }
}
