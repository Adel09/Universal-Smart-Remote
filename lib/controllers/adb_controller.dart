import 'package:get/get.dart';
import 'package:adb/adb.dart';

class AdbController extends GetxController {

  final Adb adb = Adb();

  void init(){
    adb.init();
    Future.delayed(Duration(seconds: 5), (){
      print("List of devices -> ${adb.devices()}");
    });
  }

}