import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:universal_remote/components/spacer.dart'; // Assumed from context
import 'package:universal_remote/components/texts.dart';  // Assumed from context
import 'package:universal_remote/theme/light.dart';       // Assumed from context
import 'package:universal_remote/controllers/lg_controller.dart'; // The controller we built

class LGRemoteScreen extends StatefulWidget {
  const LGRemoteScreen({super.key});

  @override
  State<LGRemoteScreen> createState() => _LGRemoteScreenState();
}

class _LGRemoteScreenState extends State<LGRemoteScreen> {
  // Find the controller that was initialized in the previous step
  final LGController controller = Get.find<LGController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIThemeLight.gray700, // Matching your dark theme
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            controller.disconnect();
            Get.back();
          },
        ),
        title: Column(
          children: [
            const UIText.bold(text: "LG WebOS TV", color: Colors.white),
            // Reactively show connection status
            Obx(() {
              Color statusColor;
              switch (controller.connectionState.value) {
                case 'CONNECTED':
                  statusColor = Colors.greenAccent;
                  break;
                case 'CONNECTING':
                  statusColor = Colors.orangeAccent;
                  break;
                default:
                  statusColor = Colors.redAccent;
              }
              return Text(
                controller.connectionState.value,
                style: TextStyle(color: statusColor, fontSize: 12),
              );
            }),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.keyboard, color: Colors.white),
            onPressed: () {
              // TODO: Implement keyboard input if needed
            },
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // --- Section 1: Power & Menu ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _RoundButton(
                    icon: Icons.power_settings_new,
                    color: Colors.redAccent,
                    onTap: () => _handleKey(LGKey.POWER),
                  ),
                  _RoundButton(
                    icon: Icons.input,
                    onTap: () => _handleKey(LGKey.MENU), // Usually triggers input source
                  ),
                ],
              ),

              const Spacer(),

              // --- Section 2: Navigation (D-Pad) ---
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  children: [
                    // UP
                    Align(
                      alignment: Alignment.topCenter,
                      child: _DPadButton(
                        icon: Icons.keyboard_arrow_up,
                        onTap: () => _handleKey(LGKey.UP),
                      ),
                    ),
                    // DOWN
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: _DPadButton(
                        icon: Icons.keyboard_arrow_down,
                        onTap: () => _handleKey(LGKey.DOWN),
                      ),
                    ),
                    // LEFT
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _DPadButton(
                        icon: Icons.keyboard_arrow_left,
                        onTap: () => _handleKey(LGKey.LEFT),
                      ),
                    ),
                    // RIGHT
                    Align(
                      alignment: Alignment.centerRight,
                      child: _DPadButton(
                        icon: Icons.keyboard_arrow_right,
                        onTap: () => _handleKey(LGKey.RIGHT),
                      ),
                    ),
                    // OK / ENTER (Center)
                    Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () => _handleKey(LGKey.ENTER),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: UIThemeLight.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: UIThemeLight.primary.withOpacity(0.4),
                                blurRadius: 10,
                                spreadRadius: 2,
                              )
                            ],
                          ),
                          child: const Icon(Icons.circle, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // --- Section 3: Actions (Back, Home) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _LabelButton(
                    icon: Icons.arrow_back,
                    label: "Back",
                    onTap: () => _handleKey(LGKey.BACK),
                  ),
                  _LabelButton(
                    icon: Icons.home,
                    label: "Home",
                    onTap: () => _handleKey(LGKey.HOME),
                  ),
                ],
              ),

              const Spacer(),

              // --- Section 4: Volume & Mute ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _RoundButton(
                      icon: Icons.remove,
                      size: 40,
                      onTap: () => _handleKey(LGKey.VOLUME_DOWN),
                    ),
                    Column(
                      children: [
                        const Icon(Icons.volume_up, color: Colors.white54),
                        const SizedBox(height: 4),
                        const UIText.small(text: "VOL", color: Colors.white54),
                      ],
                    ),
                    _RoundButton(
                      icon: Icons.add,
                      size: 40,
                      onTap: () => _handleKey(LGKey.VOLUME_UP),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Mute Button
               _RoundButton(
                  icon: Icons.volume_off,
                  color: Colors.white10,
                  iconColor: Colors.white70,
                  onTap: () => _handleKey(LGKey.MUTE),
                ),
                
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper to centralize send logic ---
  void _handleKey(LGKey key) {
    HapticFeedback.lightImpact(); // Provides physical feel
    controller.sendKey(key);
  }
}

// --- Local Widgets for Remote Buttons ---

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final Color? iconColor;
  final double size;

  const _RoundButton({
    required this.icon,
    required this.onTap,
    this.color,
    this.iconColor,
    this.size = 50,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color ?? Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor ?? Colors.white, size: size * 0.5),
      ),
    );
  }
}

class _DPadButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _DPadButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: Colors.white, size: 32),
      onPressed: onTap,
      padding: const EdgeInsets.all(12),
    );
  }
}

class _LabelButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _LabelButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 8),
          UIText.small(text: label, color: Colors.white70),
        ],
      ),
    );
  }
}