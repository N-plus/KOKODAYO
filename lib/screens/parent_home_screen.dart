import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kokodayo/simple_provider.dart';

import '../app_state.dart';
import '../models/device.dart';

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({Key? key}) : super(key: key);

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen>
    with TickerProviderStateMixin {
  Device? ringingDevice;
  Timer? ringingTimer;
  int ringingSeconds = 0;

  late AnimationController _pulseController;
  late AnimationController _bounceController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController =
        AnimationController(duration: const Duration(milliseconds: 1000), vsync: this)
          ..repeat(reverse: true);

    _bounceController =
        AnimationController(duration: const Duration(milliseconds: 200), vsync: this);

    _pulseAnimation =
        Tween<double>(begin: 1.0, end: 1.02).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _bounceAnimation =
        Tween<double>(begin: 1.0, end: 0.95).animate(CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    ringingTimer?.cancel();
    _pulseController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatRingingTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final devices = state.devices;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
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
      body: Column(
        children: [
          _buildHeader(),
          if (ringingDevice != null) _buildRingingInfoBar(),
          Expanded(
            child: devices.isEmpty
                ? _buildEmptyState()
                : _buildDeviceList(devices),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Builder(builder: (context) {
      return Container(
        padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 16, 24, 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade400,
              Colors.purple.shade400,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.menu,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.search,
                size: 20,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                '迷子スマホ探索',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 2),
                      blurRadius: 4,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: _addDevice,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '追加',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildRingingInfoBar() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange.shade400,
                  Colors.red.shade400,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.volume_up,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${ringingDevice!.name}を鳴らし中… ${_formatRingingTime(ringingSeconds)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _stopRinging,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '停止',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeviceList(List<Device> devices) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Text(
            'デバイス一覧',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: devices.length,
            itemBuilder: (context, index) => _buildDeviceCard(devices[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceCard(Device device) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: device.online ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: device.online
                        ? [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.4),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: device.online
                        ? Colors.blue.shade50
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: device.online
                          ? Colors.blue.shade200
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.smartphone,
                    size: 20,
                    color: device.online ? Colors.blue : Colors.grey,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            device.online ? 'オンライン' : 'オフライン',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: device.online ? Colors.green : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '最終: ${_formatTime(device.lastSeen)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildRingButton(device),
              ],
            ),
          ),
          _buildDeviceMenu(device),
        ],
      ),
    );
  }

  Widget _buildRingButton(Device device) {
    final bool canRing = device.online && ringingDevice == null;
    final bool isCurrentlyRinging = device.isRinging;

    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isCurrentlyRinging ? _pulseAnimation.value : 1.0,
          child: GestureDetector(
            onTapDown: (_) => _bounceController.forward(),
            onTapUp: (_) => _bounceController.reverse(),
            onTapCancel: () => _bounceController.reverse(),
            onTap: canRing ? () => _startRinging(device) : null,
            child: Transform.scale(
              scale: _bounceAnimation.value,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: canRing
                      ? LinearGradient(
                          colors: [
                            Colors.orange.shade400,
                            Colors.red.shade400,
                          ],
                        )
                      : null,
                  color: canRing ? null : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: canRing
                      ? [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.notifications_active,
                      size: 16,
                      color: canRing ? Colors.white : Colors.grey.shade500,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      canRing ? '鳴らす' : '鳴らす不可',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: canRing ? Colors.white : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeviceMenu(Device device) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      leading: Icon(
        Icons.more_vert,
        color: Colors.grey.shade400,
        size: 16,
      ),
      title: Text(
        '名前変更 / 削除',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showRenameDialog(device),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('名前変更'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showDeleteDialog(device),
                icon: const Icon(Icons.delete, size: 16),
                label: const Text('削除'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(60),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                Icons.devices,
                size: 60,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'まだデバイスがありません',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '右上の＋ボタンから追加してください',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _addDevice,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('デバイスを追加'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4C51BF),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startRinging(Device device) {
    HapticFeedback.heavyImpact();

    setState(() {
      ringingDevice = device;
      device.isRinging = true;
      ringingSeconds = 0;
    });

    ringingTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          ringingSeconds++;
        });
      }
    });

    _showSnackBar('${device.name}に鳴動指示を送信しました', Colors.orange);
  }

  void _stopRinging() {
    HapticFeedback.mediumImpact();

    if (ringingDevice != null) {
      setState(() {
        ringingDevice!.isRinging = false;
        ringingDevice = null;
        ringingSeconds = 0;
      });
      ringingTimer?.cancel();
      _showSnackBar('鳴動を停止しました', Colors.blue);
    }
  }

  void _addDevice() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/parentCode');
  }

  void _showRenameDialog(Device device) {
    final TextEditingController controller =
        TextEditingController(text: device.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('名前変更'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'デバイス名',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AppState>().renameDevice(device.id, controller.text.trim());
              Navigator.pop(context);
              _showSnackBar('名前を変更しました', Colors.green);
            },
            child: const Text('変更'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void _showDeleteDialog(Device device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('デバイス削除'),
        content: Text('「${device.name}」を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AppState>().removeDevice(device.id);
              if (ringingDevice?.id == device.id) {
                _stopRinging();
              }
              Navigator.pop(context);
              _showSnackBar('デバイスを削除しました', Colors.red);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

