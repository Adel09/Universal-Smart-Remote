import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:universal_remote/components/spacer.dart';
import 'package:universal_remote/components/texts.dart';
import 'package:universal_remote/helpers/routes.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Get.toNamed(Routes.introscreen);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings_remote, color: Colors.white,),
          Space.ten(),
          UIText.xxLarge(text: "LastRemote"),
          Row()
        ],
      ),
    );
  }
}

