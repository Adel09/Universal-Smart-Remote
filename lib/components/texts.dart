import 'styles.dart';import 'package:flutter/material.dart';

import '../theme/light.dart';


class UIText extends StatelessWidget {
  const UIText(
      {super.key,
      required this.text,
      this.color = Colors.black,
      this.style = base,
      this.overflow = TextOverflow.visible,
      this.alignment});

  const UIText.light(
      {super.key,
        required this.text,
        this.color = UIThemeLight.gray800,
        this.style = light,
        this.overflow = TextOverflow.visible,
        this.alignment});

  const UIText.centered(
      {super.key,
      required this.text,
      this.color = Colors.black,
      this.style = base,
      this.overflow = TextOverflow.visible,
      this.alignment = TextAlign.center});

  const UIText.bold(
      {super.key,
      required this.text,
      this.color = Colors.white,
      this.style = baseBold,
      this.overflow = TextOverflow.visible,
      this.alignment});

  const UIText.xxSmall(
      {super.key,
      required this.text,
      this.color = UIThemeLight.gray700,
      this.style = xxSmall,
      this.overflow = TextOverflow.visible,
      this.alignment});

  const UIText.xSmall(
      {super.key,
      required this.text,
      this.color = UIThemeLight.gray700,
      this.style = xSmall,
      this.overflow = TextOverflow.visible,
      this.alignment});

  const UIText.xSmallSimiBold(
      {super.key,
      required this.text,
      this.color = UIThemeLight.gray100,
      this.style = xSmallSemiBold,
      this.overflow = TextOverflow.visible,
      this.alignment});
  const UIText.small(
      {super.key,
      required this.text,
      this.color = UIThemeLight.gray100,
      this.overflow = TextOverflow.visible,
      this.style = small,
      this.alignment});
  const UIText.smallBold(
      {super.key,
        required this.text,
        this.color = UIThemeLight.gray100,
        this.overflow = TextOverflow.visible,
        this.style = smallBold,
        this.alignment});
  const UIText.medium(
      {super.key,
      required this.text,
      this.color = UIThemeLight.gray200,
      this.overflow = TextOverflow.visible,
      this.style = medium,
      this.alignment});
  const UIText.mediumBold(
      {super.key,
      required this.text,
      this.color = UIThemeLight.gray100,
      this.overflow = TextOverflow.visible,
      this.style = mediumBold,
      this.alignment});
  const UIText.large(
      {super.key,
      this.overflow = TextOverflow.visible,
      required this.text,
      this.color = UIThemeLight.white,
      this.style = large,
      this.alignment});

  const UIText.largeBold(
      {super.key,
      this.overflow = TextOverflow.visible,
      required this.text,
      this.color = UIThemeLight.white,
      this.style = largeBold,
      this.alignment});

  const UIText.xLarge(
      {super.key,
      required this.text,
      this.color = UIThemeLight.white,
      this.overflow = TextOverflow.visible,
      this.style = xLarge,
      this.alignment});

  const UIText.xxLarge(
      {super.key,
      required this.text,
      this.color = UIThemeLight.white,
      this.overflow = TextOverflow.visible,
      this.style = xxLarge,
      this.alignment});

  const UIText.xxxLarge(
      {super.key,
        required this.text,
        this.color = UIThemeLight.white,
        this.overflow = TextOverflow.visible,
        this.style = xxxLarge,
        this.alignment});

  final String text;
  final Color color;
  final TextStyle style;
  final TextAlign? alignment;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        overflow: overflow,
        style: style.copyWith(color: color),
        textAlign: alignment);
  }
}
