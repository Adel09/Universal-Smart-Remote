import 'spacer.dart';
import 'styles.dart';
import 'texts.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/light.dart';


class GenericInput extends StatelessWidget {
  const GenericInput({
    super.key,
    this.controller,
    this.labelText,
    this.hintText = "",
    this.errorText,
    this.onDone,
    this.enabled = true,
    this.onTap,
    this.prefix,
    this.suffix,
    this.suffixIcon,
    this.obscure = false,
    this.keyboardType,
    this.subtitle = "",
    this.fillColor = Colors.white,
    this.labelColor = Colors.black,
    this.borderColor = Colors.grey,
    this.onChange,
    this.onChanged,
    this.capitalization = TextCapitalization.sentences,
    this.inputFormatters,
  });

  final TextEditingController? controller;
  final String? labelText;
  final String hintText;
  final String subtitle;
  final String? errorText;
  final Function(String)? onDone;
  final bool enabled;
  final VoidCallback? onTap;
  final Widget? prefix;
  final Widget? suffix;
  final Widget? suffixIcon;
  final bool obscure;
  final TextInputType? keyboardType;
  final Color fillColor;
  final Color labelColor;
  final Color borderColor;
  final Function(String)? onChange;
  final Function(String)? onChanged;
  final TextCapitalization capitalization;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          onFieldSubmitted: onDone,
          style: const TextStyle(
            color: Colors.black
          ),
          onTap: onTap,
          textCapitalization: capitalization,
          obscureText: obscure,
          readOnly: !enabled,
          keyboardType: keyboardType,
          onChanged: onChanged ?? onChange,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hintText,
            labelText: labelText,
            labelStyle: medium,
            contentPadding: prefix == null ? const EdgeInsets.only(left: 18) : EdgeInsets.zero,
            hintStyle: const TextStyle(
              color: Colors.black45
            ),
            filled: true,
            fillColor: fillColor,
            border: InputBorder.none,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor, width: 0.5)
            ),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: UIThemeLight.secondary, width: 0.5)
            ),
            prefixIcon: prefix,
            suffixIcon: suffixIcon ?? suffix,
          ),
        ),
        const Space.vTight(),
        if(subtitle.isNotEmpty)
          UIText.small(text: subtitle, color: UIThemeLight.grayText)
      ],
    );
  }
}

class DisabledInput extends StatelessWidget {
  const DisabledInput({
    super.key,
    this.controller,
    this.labelText = "",
    this.hintText = "",
    this.icon
  });

  final TextEditingController? controller;
  final String labelText;
  final String hintText;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        color: UIThemeLight.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: UIThemeLight.gray100)
      ),
      child: ListTile(
        visualDensity: const VisualDensity(vertical: -4),
        title: UIText.small(text: labelText),
        subtitle: UIText(text: hintText),
        leading: icon != null ? Padding(
          padding: const EdgeInsets.only(top: 7.0),
          child: icon,
        ) : null,
      )
    );
  }
}

class GenericTextArea extends StatelessWidget {
  const GenericTextArea(
      {super.key,
        this.controller,
        this.hintText,
        this.labelText,
        this.onChanged,
        this.errorMessage = "",
        this.minLines,
        this.editable = true});

  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final Function(String)? onChanged;
  final String errorMessage;
  final bool editable;
  final int? minLines;

  @override
  Widget build(BuildContext context) {
    var borderSide = BorderSide(
        color: errorMessage.isNotEmpty ?
        UIThemeLight.red600 :
        UIThemeLight.gray500
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: labelText != null,
          child: UIText.medium(
            text: labelText ?? ""
          ),
        ),
        const Space.vNormal(),
        TextFormField(
          minLines: minLines ?? 1,
          maxLines: 1000,
          enabled: editable,
          controller: controller,
          keyboardType: TextInputType.multiline,
          onChanged: onChanged,
          style: medium,
          decoration:  InputDecoration(
            contentPadding: const EdgeInsets.only(left: 16, top: 16, bottom: 16),
            fillColor: const Color(0xFFF4F5FB),
            hintText: hintText,
            hintStyle: medium,
            filled: false,
            border: InputBorder.none,
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey, width: 0.3)
            ),
          ),
        ),
        if (errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: UIText.small(
              text: errorMessage.toString(),
              color: UIThemeLight.red600,
            ),
          ),
      ],
    );
  }
}