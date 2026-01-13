import 'package:flutter/material.dart';


class Leading extends StatelessWidget {
  const Leading({
    super.key,
    this.child
  });
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: 30,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: const Color(0xFFEFEFEF),
          borderRadius: BorderRadius.circular(4)
      ),
      child: Center(
       // child: SvgPicture.asset(svg, color: Colors.black,),
        child: child,
      ),
    );
  }
}
