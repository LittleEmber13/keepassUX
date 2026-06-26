import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:keepassux/ui/theme/theme.dart';

class RootAppBar extends StatelessWidget {
  const RootAppBar({
    super.key,
    required this.onTapExit,
    required this.isExit,
    this.onTapDelete,
  });

  final Function() onTapExit;
  final bool isExit;
  final Function()? onTapDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: onTapExit,
              child: Container(
                decoration: cardDecoration(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  tr("app_bar.hello"),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 18,
                  ),
                ),
                Text(
                  tr("app_bar.welcome"),
                  style: TextStyle(
                    color: context.appColors.secondaryText,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}
