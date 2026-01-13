import 'package:flutter/material.dart';


class UiBottomSheet extends StatelessWidget {
  const UiBottomSheet(
      {super.key,
        this.height,
        required this.child,
        this.padding = const EdgeInsets.only(
            top: 16,
            right: 24,
            left: 24,
            bottom: 24),
        this.backgroundColor = Colors.white
      });

  final double? height;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
              topRight: Radius.circular(20), topLeft: Radius.circular(20)),
          color: backgroundColor),
      child: child,
    );
  }
}
