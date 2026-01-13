import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:universal_remote/components/spacer.dart';
import 'package:universal_remote/components/texts.dart';
import 'package:universal_remote/helpers/routes.dart';
import 'package:universal_remote/theme/light.dart';

class PlatformSelectionScreen extends StatelessWidget {
  const PlatformSelectionScreen({super.key});

  Widget _buildPlatformCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required String platformKey,
  }) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(
          Routes.deviceDiscovery,
          arguments: {'platform': platformKey},
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: UIThemeLight.globalBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: UIThemeLight.gray700,
            width: 1,
          ),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          leading: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 28,
            ),
          ),
          title: UIText.mediumBold(
            text: title,
            color: UIThemeLight.white,
          ),
          subtitle: UIText.small(
            text: subtitle,
            color: UIThemeLight.white.withOpacity(0.7),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: UIThemeLight.white.withOpacity(0.5),
            size: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: Get.height,
          width: Get.width,
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Space.generic(),
              Row(
                children: [
                  GestureDetector(
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    onTap: () {
                      Get.back();
                    },
                  ),
                  SizedBox(width: 16),
                  UIText.bold(text: "Select Platform"),
                ],
              ),
              Space.generic(),
              UIText.xxLarge(
                text: "Choose Your TV Platform",
              ),
              Space.normal(),
              Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: UIText.medium(
                  text:
                      "Select the platform of your TV to begin device discovery.",
                  color: UIThemeLight.white.withOpacity(0.8),
                ),
              ),
              Space.vRelaxed(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildPlatformCard(
                        title: "Android TV / Google TV",
                        subtitle: "Google's smart TV platform",
                        icon: Icons.android,
                        iconColor: Colors.greenAccent,
                        platformKey: "android_tv",
                      ),
                      Space.normal(),
                      _buildPlatformCard(
                        title: "Amazon Fire TV",
                        subtitle: "Amazon's streaming platform",
                        icon: Icons.local_fire_department,
                        iconColor: Colors.orangeAccent,
                        platformKey: "fire_tv",
                      ),
                      Space.normal(),
                      GestureDetector(
                        onLongPress: (){
                          Get.toNamed(Routes.rokuRemote);
                        },
                        child: _buildPlatformCard(
                          title: "Roku OS",
                          subtitle: "Roku streaming devices",
                          icon: Icons.cast,
                          iconColor: Colors.purpleAccent,
                          platformKey: "roku",
                        ),
                      ),
                      Space.normal(),
                      _buildPlatformCard(
                        title: "Samsung Tizen OS",
                        subtitle: "Samsung Smart TVs",
                        icon: Icons.tv,
                        iconColor: Colors.blueAccent,
                        platformKey: "samsung_tizen",
                      ),
                      Space.normal(),
                      _buildPlatformCard(
                        title: "LG webOS",
                        subtitle: "LG Smart TVs",
                        icon: Icons.smart_screen,
                        iconColor: Colors.redAccent,
                        platformKey: "lg_webos",
                      ),
                      Space.generic(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
