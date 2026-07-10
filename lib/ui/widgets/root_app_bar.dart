import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:keepassux/ui/theme/theme.dart';

class RootAppBar extends StatelessWidget {
  const RootAppBar({
    super.key,
    required this.onTapExit,
    required this.isExit,
    required this.title,
    this.onTapDelete,
  });

  final Function() onTapExit;
  final bool isExit;
  final String title;
  final Function()? onTapDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTapExit,
          child: Container(
            decoration: cardDecoration(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Icon(
                isExit ? FeatherIcons.logOut : Icons.arrow_back,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
        SizedBox(width: 16),
        if (onTapDelete != null) ...[
          InkWell(
            onTap: onTapDelete,
            child: Container(
              decoration: cardDecoration(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
        ],
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            title,
            key: ValueKey(title),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
