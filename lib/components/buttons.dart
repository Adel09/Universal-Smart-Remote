
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/light.dart';
import 'styles.dart';
import 'texts.dart';

enum IconPosition {left, right}

class GenericButton extends StatelessWidget {
  const GenericButton({
    super.key,
    this.onPressed,
    this.backgroundColor = UIThemeLight.primary,
    this.label = "Continue",
    this.borderColor = Colors.transparent,
    this.labelColor = Colors.white,
    this.loading = false,
    this.icon,
    this.enabled = true,
    this.rounded = false,
    this.iconPosition = IconPosition.left
  });

  const GenericButton.outlined({
    super.key,
    this.onPressed,
    this.backgroundColor = Colors.transparent,
    this.label = "Continue",
    this.loading = false,
    this.borderColor = UIThemeLight.primary,
    this.labelColor = Colors.black,
    this.icon,
    this.enabled = true,
    this.rounded = false,
    this.iconPosition = IconPosition.left
  });

  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color borderColor;
  final Color labelColor;
  final bool loading;
  final String label;
  final Widget? icon;
  final bool enabled;
  final bool rounded;
  final IconPosition iconPosition;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? (){} : onPressed,
      child: Container(
        height: 40,
        width: Get.width,
        decoration: BoxDecoration(
          color: enabled ? backgroundColor : UIThemeLight.slategray400,
          borderRadius: rounded ? BorderRadius.circular(30) : BorderRadius.circular(9),
          border: Border.all(color: enabled ? borderColor : UIThemeLight.slategray400)
        ),
        child: loading ? Padding(
          padding: const EdgeInsets.all(5.0),
          child: Center(
            child: CircularProgressIndicator(color: backgroundColor == Colors.transparent ? UIThemeLight.primary : Colors.white,),
          ),
        ) : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Visibility(
              visible: iconPosition == IconPosition.left,
              child: icon != null ? Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: icon!,
              ) : const SizedBox.shrink(),
            ),
            UIText.medium(text: label, color: labelColor, style: medium.copyWith(fontWeight: FontWeight.w500,),),
            Visibility(
              visible: iconPosition == IconPosition.right,
              child: icon != null ? Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: icon!,
              ) : const SizedBox.shrink(),
            ),
          ],
        )
      ),
    );
  }
}


class SmallButton extends StatelessWidget {
  const SmallButton({
    Key? key,
    this.label = "continue",
    this.labelColor = UIThemeLight.white,
    this.backgroundColor = UIThemeLight.black,
    this.borderColor = UIThemeLight.black,
    this.onPressed,
    this.icon,
    this.iconPosition = IconPosition.left,
    this.loading = false

  }) : super(key: key);

  const SmallButton.outlined({
    Key? key,
    this.label = "continue",
    this.labelColor = UIThemeLight.black,
    this.backgroundColor = Colors.transparent,
    this.borderColor = UIThemeLight.black,
    this.onPressed,
    this.icon,
    this.iconPosition = IconPosition.left,
    this.loading = false
  }) : super(key: key);

  final String label;
  final Color labelColor;
  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback? onPressed;
  final Widget? icon;
  final IconPosition iconPosition;
  final bool loading;


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 52,
        width: 147,
        decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(12),
            color: backgroundColor
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Visibility(
              visible: iconPosition == IconPosition.left,
              child: icon != null ? Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: icon!,
              ) : const SizedBox.shrink(),
            ),
            UIText.mediumBold(text: label, color: labelColor,),
          Visibility(
            visible: iconPosition == IconPosition.right,
            child: icon != null ? Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: icon ?? SizedBox(),
            ) : const SizedBox.shrink(),)

          ],
        )
      ),
    );
  }
}