import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:universal_remote/components/buttons.dart';
import 'package:universal_remote/components/intro_list_item.dart';
import 'package:universal_remote/components/spacer.dart';
import 'package:universal_remote/components/styles.dart';
import 'package:universal_remote/components/texts.dart';
import 'package:universal_remote/helpers/routes.dart';
import 'package:universal_remote/theme/light.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  Widget _buildLeadingIcon(IconData icon) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: UIThemeLight.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 28,
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
        //scrollable
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Space.generic(),
              Row(
                children: [
                  Icon(
                    Icons.settings_remote,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  UIText.bold(text: "LastRemote"),
                ],
              ),
              Space.generic(),
              Container(
                width: Get.width,
                height: 180,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/images/onb.png"),
                        fit: BoxFit.cover),
                    borderRadius: BorderRadius.circular(20)),
              ),
              Space.generic(),
              RichText(
                text: TextSpan(
                    text: "Your Phone is \nthe",
                    style: xxxLarge,
                    children: [
                      TextSpan(
                          text: " Remote",
                          style: xxxLarge.copyWith(color: UIThemeLight.primary))
                    ]),
                textAlign: TextAlign.center,
              ),
              Space.normal(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: UIText.small(
                  text:
                      "Connect instantly via WiFi. Control Samsung, LG, Roku, and more with zero latency and complete freedom.",
                  alignment: TextAlign.center,
                ),
              ),
              Space.vRelaxed(),
              IntroListItem(
                leading: _buildLeadingIcon(Icons.tv),
                title: "Universal Control",
                subtitle: "Works with all major TV brands",
              ),
              Space.normal(),
              IntroListItem(
                leading: _buildLeadingIcon(Icons.flash_on),
                title: "Zero Latency",
                subtitle: "Instant response time",
              ),
              Space.normal(),
              IntroListItem(
                leading: _buildLeadingIcon(Icons.wifi),
                title: "Persistent Connection",
                subtitle: "No need to reconnect",
              ),
              Space.generic(),
              GenericButton(
                label: "Scan for Devices",
                icon: Icon(
                  Icons.search,
                  color: Colors.white,
                  size: 16,
                ),
                onPressed: () {
                  Get.toNamed(Routes.platformSelection);
                },
              ),
              Space.v8(),
              UIText.small(
                text:
                    "We need access to your local network to discover nearby TVs.",
                alignment: TextAlign.center,
              )
            ],
          ),
        ),
      ),
    ));
  }
}
