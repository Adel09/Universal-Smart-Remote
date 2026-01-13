
class FireTVDevice {
  final String id;
  final String name;
  final String ip;
  final int port;

  FireTVDevice({
    required this.id, 
    required this.name, 
    required this.ip, 
    required this.port
  });
}

/// Supported Remote Keys mapped to ADB Keycodes
enum FireKey {
  power(26),
  home(3),
  back(4),
  up(19),
  down(20),
  left(21),
  right(22),
  select(23),
  menu(82),
  playPause(85),
  volumeUp(24),
  volumeDown(25);

  final int keyCode;
  const FireKey(this.keyCode);
}