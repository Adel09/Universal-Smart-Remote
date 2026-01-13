import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:universal_remote/controllers/roku_controller.dart';
import 'package:universal_remote/theme/light.dart';
import 'package:universal_remote/components/texts.dart'; // Assuming this exists based on your files
import 'package:universal_remote/components/spacer.dart'; // Assuming this exists

class RokuRemoteScreen extends StatefulWidget {
  const RokuRemoteScreen({super.key});

  @override
  State<RokuRemoteScreen> createState() => _RokuRemoteScreenState();
}

class _RokuRemoteScreenState extends State<RokuRemoteScreen> {
  // Retrieve the controller instance we injected during discovery
  RokuController controller = Get.find<RokuController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIThemeLight.globalBackgroundColor, // or UIThemeLight.gray700
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            controller.disconnect();
            Get.back();
          },
        ),
        title: Obx(() {
          final deviceName = controller.currentDevice.value?.name ?? "Roku";
          final status = controller.connectionState.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UIText.mediumBold(text: deviceName, color: Colors.white),
              Text(
                status,
                style: TextStyle(
                  color: status == 'CONNECTED' ? Colors.greenAccent : Colors.redAccent,
                  fontSize: 12,
                ),
              ),
            ],
          );
        }),
        actions: [
          IconButton(
            icon: Icon(Icons.keyboard, color: Colors.white),
            onPressed: () {
              // TODO: Implement keyboard text entry dialog
              // Roku supports literal text sending via /keypress/Lit_<char>
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // --- ROW 1: Power & Header Options ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildRemoteBtn(Icons.arrow_back, RokuKey.back, label: "Back"),
                  _buildRemoteBtn(Icons.power_settings_new, RokuKey.power, color: Colors.redAccent),
                  _buildRemoteBtn(Icons.home, RokuKey.home, label: "Home"),
                ],
              ),

              const SizedBox(height: 20),

              // --- ROW 2: D-PAD Navigation ---
              // This container mimics the circular navigation pad
              Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  color: UIThemeLight.gray700, // Darker circle background
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    )
                  ],
                ),
                child: Stack(
                  children: [
                    // UP
                    Align(
                      alignment: Alignment.topCenter,
                      child: _buildDPadBtn(Icons.keyboard_arrow_up, RokuKey.up),
                    ),
                    // DOWN
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: _buildDPadBtn(Icons.keyboard_arrow_down, RokuKey.down),
                    ),
                    // LEFT
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _buildDPadBtn(Icons.keyboard_arrow_left, RokuKey.left),
                    ),
                    // RIGHT
                    Align(
                      alignment: Alignment.centerRight,
                      child: _buildDPadBtn(Icons.keyboard_arrow_right, RokuKey.right),
                    ),
                    // OK / SELECT (Center)
                    Align(
                      alignment: Alignment.center,
                      child: InkWell(
                        onTap: () => _send(RokuKey.select),
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: UIThemeLight.primary.withOpacity(0.8),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: UIText.mediumBold(text: "OK", color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --- ROW 3: Options / Replay ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildRemoteBtn(Icons.replay_10, RokuKey.instantReplay),
                  _buildRemoteBtn(Icons.info_outline, RokuKey.info, label: "Options"),
                ],
              ),

              // --- ROW 4: Playback Controls ---
              Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                decoration: BoxDecoration(
                  color: UIThemeLight.gray700.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildRemoteBtn(Icons.fast_rewind, RokuKey.rev),
                    _buildRemoteBtn(Icons.play_arrow, RokuKey.play, size: 32),
                    _buildRemoteBtn(Icons.fast_forward, RokuKey.fwd),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // --- ROW 5: Volume Controls ---
              // Usually on the side, but easier to use at bottom for mobile apps
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildRemoteBtn(Icons.volume_off, RokuKey.volumeMute),
                  SizedBox(width: 20),
                  Container(
                    width: 60,
                    height: 120,
                    decoration: BoxDecoration(
                      color: UIThemeLight.gray700,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildVolumeBtn(Icons.add, RokuKey.volumeUp),
                        Divider(color: Colors.white24, indent: 10, endIndent: 10),
                        _buildVolumeBtn(Icons.remove, RokuKey.volumeDown),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Methods ---

  /// Handles the actual sending of the command via controller
  void _send(RokuKey key) {
    HapticFeedback.lightImpact(); // Add tactile feel
    controller.sendKey(key);
  }

  Widget _buildRemoteBtn(IconData icon, RokuKey key, {String? label, Color color = Colors.white, double size = 24}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => _send(key),
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
            child: Icon(icon, color: color, size: size),
          ),
        ),
        if (label != null) ...[
          SizedBox(height: 4),
          UIText.small(text: label, color: Colors.white70),
        ]
      ],
    );
  }

  Widget _buildDPadBtn(IconData icon, RokuKey key) {
    return IconButton(
      icon: Icon(icon, color: Colors.white, size: 36),
      padding: EdgeInsets.all(16),
      onPressed: () => _send(key),
    );
  }

  Widget _buildVolumeBtn(IconData icon, RokuKey key) {
    return InkWell(
      onTap: () => _send(key),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}