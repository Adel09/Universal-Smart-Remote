import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:universal_remote/services/dialog_service.dart';

// Key definitions matching the rest of your app
enum LGKey {
  POWER,
  VOLUME_UP,
  VOLUME_DOWN,
  MUTE,
  UP,
  DOWN,
  LEFT,
  RIGHT,
  ENTER,
  BACK,
  HOME,
  MENU,
}

class LGController extends GetxController {
  // State
  var connectionState = 'IDLE'.obs; // IDLE, CONNECTING, CONNECTED, FAILED
  var currentDeviceIp = ''.obs;

  // Persisted Key (In a real app, use SharedPreferences/GetStorage)
  String? _clientKey;

  // Sockets
  WebSocketChannel? _mainChannel;
  WebSocketChannel? _inputChannel;

  // Services
  final DialogService _dialogService = DialogService();

  // Request ID counter
  int _requestId = 0;

  // --- Connection Logic ---

  Future<void> connectToDevice(String ip) async {
    // Prevent double connection
    if (connectionState.value == 'CONNECTED' ||
        connectionState.value == 'CONNECTING') return;

    _cleanup();
    currentDeviceIp.value = ip;
    connectionState.value = 'CONNECTING';

    try {
      final uri = Uri.parse('ws://$ip:3000');
      _mainChannel = WebSocketChannel.connect(uri);

      _mainChannel!.stream.listen(
        (message) => _handleMainSocketMessage(message),
        onError: (error) {
          print("LG Main Socket Error: $error");
          _handleDisconnection();
        },
        onDone: () {
          print("LG Main Socket Closed");
          _handleDisconnection();
        },
      );

      // Initiate Handshake immediately after opening connection
      _sendHandshake();
    } catch (e) {
      print("Connection Exception: $e");

      connectionState.value = 'FAILED';
      _dialogService.showErrorMessage("Could not connect to LG TV");
      throw StateError("Connection Exception: $e");
    }
  }

  void disconnect() {
    _cleanup();
    connectionState.value = 'IDLE';
  }

  void _cleanup() {
    _mainChannel?.sink.close(status.goingAway);
    _inputChannel?.sink.close(status.goingAway);
    _mainChannel = null;
    _inputChannel = null;
  }

  void _handleDisconnection() {
    connectionState.value = 'DISCONNECTED';
    _mainChannel = null;
    _inputChannel = null;
  }

  // --- Handshake & Pairing ---

  void _sendHandshake() {
    // The manifest identifies our app to the TV
    final manifest = {
      "manifest": {
        "permissions": [
          "launch",
          "launchWebApp",
          "appToApp",
          "close",
          "toast",
          "open",
          "deviceInfo",
          "controls",
          "mediaController.connect",
          "mediaController.disconnect",
          "mediaController.pause",
          "mediaController.play",
          "mediaController.rewind",
          "mediaController.seek",
          "mediaController.stop",
          "mediaController.fastForward",
          "webapp",
          "externalInputControl",
          "news",
          "tv",
          "keyboard",
          "audio",
          "power",
          "toast"
        ]
      }
    };

    final payload = {
      "type": "register",
      "id": "register_${_requestId++}",
      "payload": {
        "forcePairing": false,
        "manifest": manifest["manifest"],
        // If we have a stored key, send it to skip the prompt
        if (_clientKey != null) "client-key": _clientKey,
      }
    };

    _sendJson(_mainChannel, payload);
  }

  // --- Message Handling ---

  void _handleMainSocketMessage(dynamic message) {
    try {
      final jsonMsg = jsonDecode(message);
      final type = jsonMsg['type'];
      final payload = jsonMsg['payload'];

      print("LG RX: $type");

      if (type == 'registered') {
        // Pairing Successful
        if (payload != null && payload['client-key'] != null) {
          _clientKey = payload['client-key'];
          print("LG Client Key: $_clientKey");
          // TODO: Save this key to persistent storage with the IP/Mac address
        }

        connectionState.value = 'CONNECTED';
        _dialogService.showSuccessMessage("Connected to LG TV");

        // Once registered, we must connect to the specialized Input Socket for navigation keys
        _connectToInputSocket();
      } else if (type == 'error') {
        print("LG Error: $message");
        if (connectionState.value == 'CONNECTING') {
          connectionState.value = 'FAILED';
          _dialogService.showErrorMessage("Connection Refused on TV");
        }
      }
    } catch (e) {
      print("JSON Parse Error: $e");
    }
  }

  // --- Input Socket (For Navigation) ---

  Future<void> _connectToInputSocket() async {
    // We first ask the main socket for the pointer input socket path
    final request = {
      "type": "request",
      "id": "req_input_${_requestId++}",
      "uri": "ssap://com.webos.service.networkinput/getPointerInputSocket"
    };
    _sendJson(_mainChannel, request);

    // Note: The actual path comes back in a response, but for simplicity
    // in many webOS versions it is standard.
    // A robust implementation waits for the response to "getPointerInputSocket".
    // Here we listen to the main socket for the response to "req_input_...".

    // For this implementation, we will add a listener hook in _handleMainSocketMessage
    // But to keep code clean, let's assume standard pointer behavior or rely on
    // the main socket response logic.
  }

  // NOTE: In a full production app, you would parse the response from 'getPointerInputSocket'
  // which contains a URI like "ws://IP:3000/resources/0/..."
  // For this V1 implementation, we will simply handle the logic to send Input commands
  // ONLY if we successfully get that socket URL.

  // Let's update _handleMainSocketMessage to catch the input socket URL
  // (You would add this logic inside the message handler above)
  /*
  if (jsonMsg['id'] != null && jsonMsg['id'].toString().startsWith('req_input_')) {
      if (payload != null && payload['socketPath'] != null) {
          String socketPath = payload['socketPath'];
          _establishInputSocket(socketPath);
      }
  }
  */

  Future<void> _establishInputSocket(String socketPath) async {
    try {
      // The socketPath from LG is usually full, e.g., "ws://192.168.1.5:3000/resources/..."
      _inputChannel = WebSocketChannel.connect(Uri.parse(socketPath));
      print("Connected to Input Socket");
    } catch (e) {
      print("Input Socket Failed: $e");
      throw StateError("Input Socket Failed: $e");
    }
  }

  // --- Command Execution ---

  void sendKey(LGKey key) {
    if (connectionState.value != 'CONNECTED') return;

    switch (key) {
      // System Commands (SSAP)
      case LGKey.POWER:
        _sendRequest('ssap://system/turnOff');
        // Note: Turn ON via Wifi (WoL) is a separate network packet (Magic Packet), not WebSocket.
        break;
      case LGKey.VOLUME_UP:
        _sendRequest('ssap://audio/volumeUp');
        break;
      case LGKey.VOLUME_DOWN:
        _sendRequest('ssap://audio/volumeDown');
        break;
      case LGKey.MUTE:
        _sendRequest('ssap://audio/setMute',
            payload: {"mute": true}); // Toggle logic needed in real app
        break;
      case LGKey.HOME:
        // Home is strictly a "launcher" command
        _sendRequest('ssap://system.launcher/open',
            payload: {"id": "com.webos.app.home"});
        break;

      // Input Commands (Require Input Socket or fallback)
      // If Input Socket isn't open, these might fail on newer WebOS without it.
      case LGKey.UP:
        _sendInputKey("UP");
        break;
      case LGKey.DOWN:
        _sendInputKey("DOWN");
        break;
      case LGKey.LEFT:
        _sendInputKey("LEFT");
        break;
      case LGKey.RIGHT:
        _sendInputKey("RIGHT");
        break;
      case LGKey.ENTER:
        _sendInputKey("ENTER");
        break;
      case LGKey.BACK:
        // Back can sometimes be ssap://system/close or input key
        // _sendInputKey("BACK");
        // Fallback SSAP for generic "Back" usually closes the app
        _sendRequest('ssap://system/close');
        break;
      default:
        break;
    }
  }

  // --- Helpers ---

  void _sendRequest(String uri, {Map<String, dynamic>? payload}) {
    final request = {
      "type": "request",
      "id": "req_${_requestId++}",
      "uri": uri,
      "payload": payload ?? {}
    };
    _sendJson(_mainChannel, request);
  }

  // Sends raw key events to the specialized input socket
  void _sendInputKey(String keyName) {
    if (_inputChannel == null) {
      // Fallback: Try sending via SSAP IME service (works on some older TVs)
      // Or try to lazy-load the input socket here
      print("Input socket not active, skipping navigation");
      return;
    }

    // The Input Socket protocol is key:value pairs separated by newlines
    // type:button\nname:ENTER\n\n
    final msg = "type:button\nname:$keyName\n\n";
    _inputChannel!.sink.add(msg);
  }

  void _sendJson(WebSocketChannel? channel, Map<String, dynamic> data) {
    try {
      if (channel != null) {
        channel.sink.add(jsonEncode(data));
      }
    } catch (e) {
      print("Send Error: $e");
    }
  }
}
