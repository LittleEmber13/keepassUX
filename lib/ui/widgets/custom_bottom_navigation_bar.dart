import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:keepassux/ui/pages/add_entry.dart';
import 'package:keepassux/ui/pages/add_group.dart';
import 'package:keepassux/ui/pages/main_tabs_page.dart';
import 'package:keepassux/ui/theme/theme.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({
    this.selectedIndex,
    this.uuidGroup,
    this.onTabSelected,
    super.key,
  });

  final String? uuidGroup;
  final int? selectedIndex;

  final ValueChanged<int>? onTabSelected;

  void _goToTab(BuildContext context, int index) {
    if (onTabSelected != null) {
      onTabSelected!(index);
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainTabsPage(initialIndex: index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: 24,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Container(
          decoration: cardDecoration(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => _goToTab(context, 0),
                  child: Icon(
                    FontAwesomeIcons.folder,
                    color:
                        selectedIndex == 0
                            ? Theme.of(context).colorScheme.onSurface
                            : context.appColors.secondaryText,
                  ),
                ),
                InkWell(
                  onTap: () => _goToTab(context, 1),
                  child: Icon(
                    FontAwesomeIcons.magnifyingGlass,
                    color:
                        selectedIndex == 1
                            ? Theme.of(context).colorScheme.onSurface
                            : context.appColors.secondaryText,
                  ),
                ),
                InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (BuildContext ctx) {
                        return SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 24,
                                  bottom: 16,
                                  left: 24,
                                  right: 24,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      tr("nav_bar.add"),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () => Navigator.pop(ctx),
                                      child: const Icon(Icons.close),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(Icons.vpn_key),
                                title: Text(tr("nav_bar.add_entry")),
                                onTap: () {
                                  Navigator.pop(ctx);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => AddEntryPage(
                                            uuidGroup: uuidGroup,
                                          ),
                                    ),
                                  );
                                },
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(Icons.folder),
                                title: Text(tr("nav_bar.add_group")),
                                onTap: () {
                                  Navigator.pop(ctx);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => AddGroupPage(
                                            uuidGroup: uuidGroup,
                                          ),
                                    ),
                                  );
                                },
                              ),
                              const Divider(height: 1),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        Icons.add,
                        color: Theme.of(context).colorScheme.surface,
                        size: 39,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => _goToTab(context, 2),
                  child: Icon(
                    Icons.info_outline,
                    size: 30,
                    color:
                        selectedIndex == 2
                            ? Theme.of(context).colorScheme.onSurface
                            : context.appColors.secondaryText,
                  ),
                ),
                InkWell(
                  onTap: () => _goToTab(context, 3),
                  child: Icon(
                    FeatherIcons.settings,
                    color:
                        selectedIndex == 3
                            ? Theme.of(context).colorScheme.onSurface
                            : context.appColors.secondaryText,
                    size: 26,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
