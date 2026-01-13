import 'package:flutter/material.dart';

import '../theme/light.dart';

class LoadedWidget extends StatelessWidget {
  const LoadedWidget(
      {super.key,
      this.loading = false,
      this.child,
      this.loaderColor = UIThemeLight.primary});

  final bool loading;
  final Widget? child;
  final Color loaderColor;

  @override
  Widget build(BuildContext context) {
    return loading
        ? Center(
            child: CircularProgressIndicator(
              color: loaderColor,
            ),
          )
        : child ?? const SizedBox();
  }
}
