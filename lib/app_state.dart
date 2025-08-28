import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'models/device.dart';

class AppState extends ChangeNotifier {
  String? role; // 'parent' or 'child'
  String? pairingCode;
  DateTime? codeExpiry;
  Timer? _codeTimer;
  final List<Device> devices = [];

  void setRole(String? newRole) {
    role = newRole;
    notifyListeners();
  }

  void generateCode() {
    final rnd = Random();
    pairingCode = List.generate(6, (_) => rnd.nextInt(10)).join();
    codeExpiry = DateTime.now().add(const Duration(minutes: 5));
    _codeTimer?.cancel();
    _codeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (DateTime.now().isAfter(codeExpiry!)) {
        pairingCode = null;
        timer.cancel();
        notifyListeners();
      } else {
        notifyListeners();
      }
    });
    notifyListeners();
  }

  Duration? get remaining =>
      codeExpiry != null ? codeExpiry!.difference(DateTime.now()) : null;

  bool verifyCode(String code) {
    return pairingCode == code && remaining! > Duration.zero;
  }

  void addDevice(Device device) {
    devices.add(device);
    notifyListeners();
  }
}
