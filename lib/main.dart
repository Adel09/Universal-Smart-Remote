import 'package:flutter/material.dart';
import 'package:flutter_adb/adb_crypto.dart';
import 'package:get/get.dart';
import 'package:universal_remote/controllers/adb_controller.dart';
import 'package:universal_remote/controllers/fire_tv_controller.dart';
import 'package:universal_remote/controllers/roku_controller.dart';
import 'package:universal_remote/theme/light.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'helpers/routes.dart';
import 'controllers/lg_controller.dart';

void main() async {
  Get.put(FireTVController());
  Get.put(RokuController());
  Get.put(LGController());
  Get.put(AdbController());
  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://7cdfc5b086fae9255e763a85eb3a54db@o4510642891259904.ingest.us.sentry.io/4510642895257600';
    },
    // Init your App.
    appRunner: () => runApp(MyApp()),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Rambini",
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.splash,
      getPages: getPages,
      theme: UIThemeLight().theme,
      //darkTheme: UIThemeDark().theme,
    );
  }
}
