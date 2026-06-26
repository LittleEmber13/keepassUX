import 'package:flutter/material.dart';
import 'package:keepassux/ui/theme/theme.dart';

class GroupAppBar extends StatelessWidget {
  const GroupAppBar({
    super.key,
    required this.onTapExit,
    required this.title,
    this.onTapEdit,
    this.onTapDelete,
  });

  final Function() onTapExit;
  final String title;
  final Function()? onTapEdit;
  final Function()? onTapDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          InkWell(
            onTap: onTapExit,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: context.appColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: context.appColors.cardShadow,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: Theme.of(context).colorScheme.onSurface,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onTapEdit != null) ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: onTapEdit,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.appColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: context.appColors.cardShadow,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.edit,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 20,
                ),
              ),
            ),
          ],
          if (onTapDelete != null) ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: onTapDelete,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.appColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: context.appColors.cardShadow,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 20,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
