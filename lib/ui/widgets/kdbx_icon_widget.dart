import 'package:flutter/material.dart';
import 'package:kdbx/kdbx.dart';
import 'package:keepassux/ui/utils/kdbx_icons.dart';

class KDBXIconWidget extends StatelessWidget {
  const KDBXIconWidget({
    required this.object,
    this.size = 24,
    this.color,
    super.key,
  });

  final KdbxObject object;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final customData = object.customIcon?.data;
    if (customData != null) {
      return Image.memory(
        customData,
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
    }
    return Icon(kdbxIconToFlutter(object.icon.get()), size: size, color: color);
  }
}
