import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/light.dart';

class Handle extends StatelessWidget {
  const Handle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 3,
      decoration: BoxDecoration(
        color: const Color(0xFF888888),
        borderRadius: BorderRadius.circular(1)
      ),
    );
  }
}

class CloseIt extends StatelessWidget {
  const CloseIt({
    super.key,
    this.onTap
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        if(onTap == null){
          Get.back();
        }else{
          onTap!();
        }
      },
      child: CircleAvatar(
        radius: 14,
        backgroundColor: UIThemeLight.primaryLight.withOpacity(0.5),
        child: const Center(
          child: Icon(Icons.close, size: 25, color: Colors.black,),
        ),
      ),
    );
  }
}

