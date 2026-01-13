import 'package:flutter/material.dart';

class Space extends StatelessWidget {

  const Space.zero({super.key, this.height = 0});

  const Space.vTight({super.key, this.height = 4});

  const Space.vNormal({super.key, this.height = 6});

  const Space.v8({super.key, this.height = 8});

  const Space.ten({super.key, this.height = 10});

  const Space.vLoose({super.key, this.height = 12});

  const Space.compact({super.key, this.height = 14});

  const Space.normal({super.key, this.height = 16});

  const Space.generic({super.key, this.height = 20});

  const Space.vRelaxed({super.key, this.height = 24});

  const Space.loose({super.key, this.height = 28});

  const Space.vWide({super.key, this.height = 32});

  const Space.forty({super.key, this.height = 40});

  const Space.fifty({super.key, this.height = 50});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
    );
  }
}