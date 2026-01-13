import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../components/texts.dart';

class DialogService {
  void showLoadingDialog(BuildContext context) {
    // Show the loading dialog using GetX
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false, // Prevent users from dismissing the dialog
    );
  }

  void showSnackbar(String title, String body) {
    // Show the snackbar using GetX
    Get.snackbar(
        title, // Snackbar title
        body, // Snackbar message
        snackPosition: SnackPosition.BOTTOM, // Position of the snackbar
        duration: const Duration(seconds: 3));
  }

  void showSuccessSnackbar(String title, String body) {
    // Show the snackbar using GetX
    Get.snackbar(
        title, // Snackbar title
        body, // Snackbar message
        snackPosition: SnackPosition.TOP, // Position of the snackbar
        duration: const Duration(seconds: 3),
      backgroundColor: Colors.green,
      icon: Icon(Icons.check_circle_outline, color: Colors.white,),
      colorText: Colors.white
    );
  }

  void showInfoSnackbar(String title, String body) {
    // Show the snackbar using GetX
    Get.snackbar(
        title, // Snackbar title
        body, // Snackbar message
        snackPosition: SnackPosition.TOP, // Position of the snackbar
        duration: const Duration(seconds: 3),
        backgroundColor: const Color(0xFFA07E03),
        icon: Icon(Icons.info_outline_rounded, color: Colors.white,),
        colorText: Colors.white
    );
  }

  void showErrorSnackbar(String title, String body) {
    // Show the snackbar using GetX
    Get.snackbar(
        title, // Snackbar title
        body, // Snackbar message
        snackPosition: SnackPosition.TOP, // Position of the snackbar
        duration: const Duration(seconds: 3),
        backgroundColor:Colors.red,
        icon: Icon(Icons.info_outline_rounded, color: Colors.white,),
        colorText: Colors.white
    );
  }

  void showSuccessMessage(String message) {
    Get.showSnackbar(GetSnackBar(
      borderRadius: 20,
      margin: const EdgeInsets.all(15),
      duration: const Duration(seconds: 7),
      forwardAnimationCurve: Curves.easeOutBack,
      icon: const Icon(
        Icons.check,
        color: Colors.white,
      ),
      backgroundColor: Colors.green,
      message: message,
    ));
  }

  void showErrorMessage(String message) {
    Get.showSnackbar(GetSnackBar(
      borderRadius: 20,
      margin: const EdgeInsets.all(15),
      duration: const Duration(seconds: 7),
      forwardAnimationCurve: Curves.easeOutBack,
      icon: const Icon(
        Icons.error_outline,
        color: Colors.white,
      ),
      backgroundColor: Colors.red,
      message: message,
    ));
  }

  void showDialog(
      BuildContext context, {
        VoidCallback? onOK,
        VoidCallback? onCancel,
        String message = "This is a dialog",
      }) {
    // Create a Dialog object with the desired content
    Dialog dialog = Dialog(
      child: Container(
        height: 200,
        width: 200,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Center(
              child: UIText(text: message),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: onCancel,
                  child: const UIText(text: "Cancel"),
                ),
                TextButton(
                  onPressed: onOK,
                  child: const UIText(text: "OK"),
                ),
              ],
            )
          ],
        ),
      ),
    );

    // Show the dialog using GetX
    Get.dialog(dialog);
  }


}