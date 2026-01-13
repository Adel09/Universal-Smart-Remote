import 'package:flutter/material.dart';
import 'package:universal_remote/components/texts.dart';
import 'package:universal_remote/theme/light.dart';

class DiscoveredListItem extends StatelessWidget {
  const DiscoveredListItem({
    super.key,
    required this.logo,
    required this.deviceName,
    required this.deviceIp,
    this.onConnect,
  });

  final Widget logo;
  final String deviceName;
  final String deviceIp;
  final VoidCallback? onConnect;

  @override
  Widget build(BuildContext context) {
    return Container(
      //margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UIThemeLight.globalBackgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Logo container
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: UIThemeLight.gray700,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: logo),
          ),
          const SizedBox(width: 16),
          // Device info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                UIText.mediumBold(
                  text: deviceName,
                  color: UIThemeLight.white,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                UIText.small(
                  text: deviceIp,
                  color: UIThemeLight.gray400,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Connect button
          ElevatedButton(
            onPressed: onConnect,
            style: ElevatedButton.styleFrom(
              backgroundColor: UIThemeLight.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: UIText.mediumBold(
              text: "Connect",
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
