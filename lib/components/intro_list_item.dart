import 'package:flutter/material.dart';
import 'package:universal_remote/components/texts.dart';
import 'package:universal_remote/theme/light.dart';

class IntroListItem extends StatelessWidget {
  const IntroListItem({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
  });

  final Widget leading;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: UIThemeLight.globalBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: leading,
        title: UIText.mediumBold(
          text: title,
          color: UIThemeLight.white,
        ),
        subtitle: UIText.small(
          text: subtitle,
          color: UIThemeLight.white,
        ),
      ),
    );
  }
}
