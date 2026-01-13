import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:universal_remote/models/roku_device.dart';
import 'package:universal_remote/services/dialog_service.dart';

import '../helpers/routes.dart';

// Roku ECP Keys
enum RokuKey {
  home,
  rev,
  fwd,
  play,
  select,
  left,
  right,
  down,
  up,
  back,
  instantReplay,
  info,
  backspace,
  search,
  enter,
  volumeDown,
  volumeMute,
  volumeUp,
  powerOff,
  powerOn,
  power // Toggle
}

class RokuController extends GetxController {
  // State Observables
  var currentDevice = Rxn<RokuDevice>();
  var connectionState = 'IDLE'.obs; // IDLE, CONNECTING, CONNECTED, DISCONNECTED, FAILED

  // Services
  final DialogService _dialogService = DialogService();

  /// Key Mapping for ECP
  final Map<RokuKey, String> _keyMap = {
    RokuKey.home: 'Home',
    RokuKey.rev: 'Rev',
    RokuKey.fwd: 'Fwd',
    RokuKey.play: 'Play',
    RokuKey.select: 'Select',
    RokuKey.left: 'Left',
    RokuKey.right: 'Right',
    RokuKey.down: 'Down',
    RokuKey.up: 'Up',
    RokuKey.back: 'Back',
    RokuKey.instantReplay: 'InstantReplay',
    RokuKey.info: 'Info',
    RokuKey.backspace: 'Backspace',
    RokuKey.search: 'Search',
    RokuKey.enter: 'Enter',
    RokuKey.volumeDown: 'VolumeDown',
    RokuKey.volumeMute: 'VolumeMute',
    RokuKey.volumeUp: 'VolumeUp',
    RokuKey.powerOff: 'PowerOff',
    RokuKey.powerOn: 'PowerOn',
    RokuKey.power: 'Power',
  };

  /// Validates connectivity to the Roku device via ECP Handshake
  /// Reference: Spec 4.3 Validation Gate - "Control endpoint responds"
  Future<void> connectToDevice(RokuDevice device) async {
    connectionState.value = 'CONNECTING';
    currentDevice.value = device;

    try {
      final url = Uri.parse('http://${device.ip}:${device.port}/query/device-info');

      // We set a short timeout because local devices should respond instantly
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        // Validation successful
        connectionState.value = 'CONNECTED';
        _dialogService.showSuccessMessage("Roku Connected");
        // Navigate to Remote Screen here if needed, similar to FireTV
        Get.toNamed(Routes.rokuRemote);
      } else {
        _dialogService.showErrorMessage("Device returned status ${response.statusCode}");
        throw Exception("Device returned status ${response.statusCode} | ${response.body}");
      }
    } catch (e) {
      print("Roku Connection Failed: $e");
      connectionState.value = 'FAILED';
      _dialogService.showErrorMessage("Could not connect to Roku. Ensure it is on and on the same network.");
      currentDevice.value = null;
      throw StateError("Roku Connection Failed: $e");
    }
  }

  /// Sends a key press command via HTTP POST
  /// Reference: Spec 6.2 Supported Commands
  Future<void> sendKey(RokuKey key) async {
    if (currentDevice.value == null || connectionState.value != 'CONNECTED') {
      _dialogService.showErrorMessage("Not connected to device");
      return;
    }

    final commandString = _keyMap[key];
    if (commandString == null) return;

    try {
      final url = Uri.parse('http://${currentDevice.value!.ip}:${currentDevice.value!.port}/keypress/$commandString');

      // Roku commands are Fire-and-Forget, but we await the send to ensure network delivery
      final response = await http.post(url);

      if (response.statusCode != 200) {
        print("Command failed with status: ${response.statusCode} ");
        _dialogService.showErrorSnackbar("Command Failed", response.body);
        throw StateError("Command failed with status: ${response.statusCode} | ${response.body}");
        // Optional: Retry logic as per Spec 7.2
      }
    } catch (e) {
      print("Roku Command Failed: $e");
      throw StateError("Roku Command Failed: $e");
      // If the command fails due to network, we might want to update state
      // connectionState.value = 'DISCONNECTED';
    }
  }

  void disconnect() {
    connectionState.value = 'IDLE';
    currentDevice.value = null;
  }
}