import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_adb/adb_connection.dart';
import 'package:flutter_adb/adb_crypto.dart';
import 'package:flutter_adb/adb_stream.dart';
import 'package:flutter_adb/flutter_adb.dart';
import 'package:get/get.dart';
import 'package:nsd/nsd.dart';
import 'package:universal_remote/helpers/routes.dart';
import 'package:universal_remote/models/fire_tv_device.dart';
import 'package:universal_remote/services/dialog_service.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pointycastle/pointycastle.dart' as pc; 
import 'package:basic_utils/basic_utils.dart';

class FireTVController extends GetxController {
  var currentDevice = Rxn<FireTVDevice>();
  DialogService dialogService = DialogService();
  AdbConnection? _adbConnection;
  var connectionState =
      'IDLE'.obs; // IDLE, DISCOVERING, CONNECTING, CONNECTED, FAILED
  final crypto = AdbCrypto();
  AdbStream? _persistentShell;

  Future<void> connectToDevice(FireTVDevice device) async {
    connectionState.value = 'CONNECTING';
    currentDevice.value = device;

    try {



      _adbConnection = await AdbConnection(
          device.ip,
          device.port,
          crypto, //await _getOrGenerateAdbCrypto(),
          verbose: true
      );
      bool? connected = await _adbConnection?.connect();
      // If we reach here, the ADB Handshake (CNXN) was successful.
      // If it's the first time, the user had to click "Allow" on TV.
      if (connected == true) {
        connectionState.value = 'CONNECTED';
        // 2. OPEN THE SHELL ONCE HERE
        print("Opening Persistent Shell...");
        //_persistentShell = await _adbConnection!.openShell();


        Get.toNamed(Routes.fireTvRemote);
        _adbConnection!.onConnectionChanged.listen((connected) {
          print('Connected: $connected');
          if (connected == true) {
            dialogService.showSuccessMessage("Fire TV Connected");
            connectionState.value = 'CONNECTED';

          }
          if (!connected) {
            connectionState.value = 'DISCONNECTED';
            dialogService.showErrorMessage("Fire TV Disconnected");
          }
        });
      } else {
        connectionState.value = 'FAILED';
        //dialogService.showErrorMessage("Unable to connect");
        dialogService.showErrorSnackbar("Unable to connect", "${_adbConnection?.ip}");
      }
    } catch (e) {
      print("ADB Connection Failed: $e");
    
      connectionState.value = 'FAILED';
      dialogService.showErrorSnackbar("Connection Failed", "Ensure 'ADB Debugging' is ON in FireTV Settings.");
      _adbConnection = null;
      _persistentShell = null;
      throw StateError("ADB Connection Failed: $e");
    }
  }

  void disconnect() {
    _adbConnection?.disconnect();
    _adbConnection = null;
    connectionState.value = 'IDLE';
    currentDevice.value = null;
    _persistentShell?.close();
    _persistentShell = null;
  }

  Future<void> sendKey(FireKey key) async {
    // 1. Check if we have a valid shell
    if (_persistentShell == null || connectionState.value != 'CONNECTED') {
      print("Shell dead, attempting reconnect...");
      // Optional: Try to reconnect automatically here
      return;
    }

    try {
      // 2. Just write to the existing stream!
      // No 'open', no 'close'. Just send data.
      String command = "input keyevent ${key.keyCode}\n";

      // Note: writeString usually returns a Future<bool> or void depending on package
      await _persistentShell!.writeString(command);

      print("Sent: ${key.keyCode}");

    } catch (e) {
      print("Send Failed: $e");
      // If write fails, the connection is likely dead.
      connectionState.value = 'DISCONNECTED';
      _persistentShell = null;
    }
  }

  Future<void> sendKeyLite(FireKey key) async {
    if (_adbConnection == null || connectionState.value != 'CONNECTED') {
      dialogService.showErrorMessage("Not connected to device");
      return;
    }
    //AdbStream? shell;

    try {
      // Execute ADB Shell Command
      // "input keyevent <KEYCODE>" is the standard Android input injection
      //await _adbConnection!.shell("input keyevent ${key.keyCode}");

      //shell = await _adbConnection!.openShell();
      print("input keyevent ${key.keyCode}");
      if(currentDevice.value == null){
        print("No current device");
        return;
      }


      print("Device IP: ${currentDevice.value!.ip} | Port: ${currentDevice.value!.port}");
      print("Crypto Public Key: ${crypto.getAdbPublicKeyPayload()}");

      final result = await Adb.sendSingleCommand(
          'input keyevent ${key.keyCode}\n',
        ip: currentDevice.value!.ip,
        port: currentDevice.value!.port,
        crypto: crypto
      );
      print('Result: $result');


      // Haptic feedback could be triggered here
    } catch (e) {
      print("Command Failed: $e");
      // Optional: Auto-retry logic or disconnect if broken pipe
    } finally {
      //shell?.close();
    }
  }

// 704 108 4284 onyeka

  Future<AdbCrypto> _getOrGenerateAdbCrypto() async {
    // 1. Get the Safe Document Directory (Critical for iOS Sandboxing)
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String privKeyPath = '${appDocDir.path}/adb_private.pem';
    final String pubKeyPath = '${appDocDir.path}/adb_public.pem';
    
    final File privFile = File(privKeyPath);
    final File pubFile = File(pubKeyPath);

    pc.AsymmetricKeyPair<pc.RSAPublicKey, pc.RSAPrivateKey>? keyPair;

    // 2. Try to Load Existing Keys
    if (await privFile.exists() && await pubFile.exists()) {
      try {
        print("Loading existing ADB keys from storage...");
        String privKeyPem = await privFile.readAsString();
        String pubKeyPem = await pubFile.readAsString();

        // Convert PEM Strings -> PointyCastle Key Objects
        final privKey = CryptoUtils.rsaPrivateKeyFromPem(privKeyPem);
        final pubKey = CryptoUtils.rsaPublicKeyFromPem(pubKeyPem);
        
        // Reconstruct the Pair
        keyPair = pc.AsymmetricKeyPair<pc.RSAPublicKey, pc.RSAPrivateKey>(pubKey, privKey);
      } catch (e) {
        print("Error loading keys (regenerating): $e");
      }
    }

    // 3. If No Keys Found, Generate New Ones
    if (keyPair == null) {
      print("Generating keys...");
      
      // Generate generic pair
      var genericPair = CryptoUtils.generateRSAKeyPair(keySize: 2048);

      // --- THE FIX: Explicitly cast the components ---
      pc.RSAPublicKey pubKey = genericPair.publicKey as pc.RSAPublicKey;
      pc.RSAPrivateKey privKey = genericPair.privateKey as pc.RSAPrivateKey;
      
      // Recreate the pair with strict types
      keyPair = pc.AsymmetricKeyPair<pc.RSAPublicKey, pc.RSAPrivateKey>(pubKey, privKey);

      // Save to file
      await privFile.writeAsString(CryptoUtils.encodeRSAPrivateKeyToPem(privKey));
      await pubFile.writeAsString(CryptoUtils.encodeRSAPublicKeyToPem(pubKey));
    }

    // 4. Return the Crypto Object expected by flutter_adb
    // pass the 'keyPair' explicitly
    return AdbCrypto(keyPair: keyPair);
  }




}
