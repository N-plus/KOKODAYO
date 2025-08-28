class Device {
  Device({required this.name, this.online = true, required this.lastSeen});

  final String name;
  bool online;
  DateTime lastSeen;
}
