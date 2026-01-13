import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Haptics
import 'package:flutter_adb/adb_crypto.dart';
import 'package:get/get.dart';
import 'package:universal_remote/controllers/adb_controller.dart';
import 'package:universal_remote/controllers/fire_tv_controller.dart';
import 'package:universal_remote/models/fire_tv_device.dart';
import 'package:flutter_adb/flutter_adb.dart';


class FireTVRemoteScreen extends StatefulWidget {
  const FireTVRemoteScreen({Key? key}) : super(key: key);

  @override
  State<FireTVRemoteScreen> createState() => _FireTVRemoteScreenState();
}

class _FireTVRemoteScreenState extends State<FireTVRemoteScreen> {
  // Inject or Find the controller. 
  // Assuming the controller was initialized in the previous discovery screen.
  FireTVController controller = Get.find();
  

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (popped, val){
        if(popped){
          controller.disconnect();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1E1E1E), // Dark remote background
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Fire TV", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                controller.connectionState.value == 'CONNECTED'
                    ? "Connected"
                    : "Disconnected",
                style: TextStyle(
                  fontSize: 12,
                  color: controller.connectionState.value == 'CONNECTED'
                      ? Colors.greenAccent
                      : Colors.redAccent,
                ),
              ),
            ],
          )),
          actions: [
            // Power Button (Always accessible)
            IconButton(
              icon: const Icon(Icons.power_settings_new, color: Colors.redAccent),
              iconSize: 32,
              onPressed: () => _handlePress(FireKey.power),
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: SafeArea(
          child: Obx(() {
            // Disable UI if not connected
            final isConnected = controller.connectionState.value == 'CONNECTED';

            return IgnorePointer(
              ignoring: !isConnected,
              child: Opacity(
                opacity: isConnected ? 1.0 : 0.5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // --- 1. Navigation Pad ---
                    _buildDPad(),

                    // --- 2. System Actions (Back, Home, Menu) ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildRoundButton(Icons.arrow_back, FireKey.back),
                          _buildRoundButton(Icons.home, FireKey.home, size: 56),
                          _buildRoundButton(Icons.menu, FireKey.menu),
                        ],
                      ),
                    ),

                    const Divider(color: Colors.white24, indent: 20, endIndent: 20),

                    // --- 3. Playback Controls ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Using Volume Up/Down as placeholders or if mapped
                        _buildFlatButton(Icons.remove, FireKey.volumeDown),
                        const SizedBox(width: 20),
                        _buildPlayPauseButton(),
                        const SizedBox(width: 20),
                        _buildFlatButton(Icons.add, FireKey.volumeUp),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildDPad() {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          Expanded(child: _buildPadButton(Icons.keyboard_arrow_up, FireKey.up)),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildPadButton(Icons.keyboard_arrow_left, FireKey.left)),
                // OK / Select Center Button
                Expanded(
                  child: InkWell(
                    onTap: () => _handlePress(FireKey.select),
                    customBorder: const CircleBorder(),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF4A4A4A),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text("OK", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ),
                ),
                Expanded(child: _buildPadButton(Icons.keyboard_arrow_right, FireKey.right)),
              ],
            ),
          ),
          Expanded(child: _buildPadButton(Icons.keyboard_arrow_down, FireKey.down)),
        ],
      ),
    );
  }

  Widget _buildPadButton(IconData icon, FireKey key) {
    return InkWell(
      onTap: () => _handlePress(key),
      // Use transparent to catch taps but show ripple on parent material if needed
      child: Center(child: Icon(icon, color: Colors.white, size: 32)),
    );
  }

  Widget _buildRoundButton(IconData icon, FireKey key, {double size = 48}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3A),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white12),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: () => _handlePress(key),
      ),
    );
  }

  Widget _buildPlayPauseButton() {
    return Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.play_arrow, color: Colors.white, size: 32),
        onPressed: () => _handlePress(FireKey.playPause),
      ),
    );
  }

  Widget _buildFlatButton(IconData icon, FireKey key) {
    return InkWell(
      onTap: () => _handlePress(key),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  // --- Logic ---

  void _handlePress(FireKey key) async {
    HapticFeedback.lightImpact(); // Tactile feedback
    //controller.sendKey(key);
    controller.sendKeyLite(key);
    // final result = await Adb.sendSingleCommand(
    //     'input keyevent ${key.keyCode}\n',
    //     ip: controller.currentDevice.value!.ip,
    //     port: controller.currentDevice.value!.port,
    //     crypto: AdbCrypto()
    // );
    // print('Result: $result');
  }
}