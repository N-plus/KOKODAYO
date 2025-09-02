class Device {
  Device({
    String? id,
    required this.name,
    this.online = true,
    required this.lastSeen,
    this.isRinging = false,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  final String id;
  String name;
  bool online;
  DateTime lastSeen;
  bool isRinging;
}
