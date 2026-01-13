import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:universal_remote/components/bottom_sheet.dart';
import 'package:universal_remote/components/bottomsheet_handle.dart';
import 'package:universal_remote/components/buttons.dart';
import 'package:universal_remote/components/inputs.dart';
import 'package:universal_remote/components/spacer.dart';


class ManualIpBottomsheet extends StatefulWidget {
  const ManualIpBottomsheet({super.key});

  @override
  State<ManualIpBottomsheet> createState() => _ManualIpBottomsheetState();
}

class _ManualIpBottomsheetState extends State<ManualIpBottomsheet> {

  TextEditingController ipController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return UiBottomSheet(
      height: Get.height * 0.22,
        child: Column(
          children: [
            Handle(),
            Space.generic(),
            GenericInput(
              controller: ipController,
              labelText: "Device IP Address",
              hintText: "Ex 192.168.1.180",
            ),
            Space.generic(),
            GenericButton(
              label: "Connect",
              onPressed: (){
                HapticFeedback.lightImpact();
                Get.back(result: ipController.text);
              },
            )
          ],
        ),
    );
  }
}


