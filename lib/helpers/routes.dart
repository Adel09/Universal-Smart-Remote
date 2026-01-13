import 'package:get/get.dart';
import 'package:universal_remote/screens/discovery/device_discovery_screen.dart';
import 'package:universal_remote/screens/discovery/platform_selection_screen.dart';
import 'package:universal_remote/screens/intro/intro_screen.dart';
import 'package:universal_remote/screens/remotes/firetv_remote_screen.dart';
import 'package:universal_remote/screens/remotes/lg_remote_screen.dart';
import 'package:universal_remote/screens/remotes/roku_remote_screen.dart';

import '../screens/splash_screen.dart';

class Routes {
  static String introscreen = "/";
  static String splash = "/splash";
  static String login = "/login";
  static String forgotPassword = "/forgot-password";
  static String platformSelection = "/platform-selection";
  static String deviceDiscovery = "/device-discovery";
  static String fireTvRemote  = "/fire-tv-remote";
  static String rokuRemote  = "/roku-remote";
  static String lgRemote  = "/lg-remote";
}

final getPages = [
  GetPage(
    name: Routes.splash,
    page: () => const SplashScreen(),
  ),
  GetPage(
    name: Routes.introscreen,
    page: () => const IntroScreen(),
  ),
  GetPage(
    name: Routes.platformSelection,
    page: () => const PlatformSelectionScreen(),
  ),
  GetPage(
    name: Routes.deviceDiscovery,
    page: () => const DeviceDiscoveryScreen(),
  ),
  GetPage(
    name: Routes.fireTvRemote,
    page: () => const FireTVRemoteScreen(),
  ),
  GetPage(
    name: Routes.rokuRemote,
    page: () => const RokuRemoteScreen(),
  ),
  GetPage(
    name: Routes.lgRemote,
    page: () => const LGRemoteScreen(),
  ),
];
