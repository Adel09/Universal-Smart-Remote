class RokuDevice {
  final String name;
  final String ip;
  final int port; // Default is 8060 for Roku

  RokuDevice({
    required this.name,
    required this.ip,
    this.port = 8060,
  });
}