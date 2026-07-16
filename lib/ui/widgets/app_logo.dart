import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white : Colors.black,
        borderRadius: const BorderRadius.all(Radius.circular(32)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 42),
        child: SvgPicture.asset(
          'assets/images/logo.svg',
          width: MediaQuery.of(context).size.width / 4,
          fit: BoxFit.contain,
          colorFilter: ColorFilter.mode(
            isDark ? Colors.black : Colors.white,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
