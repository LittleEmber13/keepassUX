import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:keepassux/ui/pages/add_entry.dart';
import 'package:keepassux/ui/pages/add_group.dart';
import 'package:keepassux/ui/pages/entries_page.dart';
import 'package:keepassux/ui/pages/search_page.dart';
import 'package:keepassux/ui/pages/settings_page.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({
    this.selectedIndex,
    this.uuidGroup,
    super.key,
  });

  final String? uuidGroup;
  final int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
      padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24, top: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              spreadRadius: 1,
              offset: Offset(1, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EntriesPage(),
                    ),
                  );
                },
                child: Icon(
                  FontAwesomeIcons.folder,
                  color: selectedIndex == 0 ? Colors.black : Colors.grey,
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SearchPage(),
                    ),
                  );
                },
                child: Icon(
                  FontAwesomeIcons.magnifyingGlass,
                  color: selectedIndex == 1 ? Colors.black : Colors.grey,
                ),
              ),
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.white,
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                        (context) =>
                                            AddEntryPage(uuidGroup: uuidGroup),
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
                                        (context) =>
                                            AddGroupPage(uuidGroup: uuidGroup),
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
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(Icons.add, color: Colors.white, size: 39),
                  ),
                ),
              ),
              Icon(FontAwesomeIcons.user, color: Colors.white),
              InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  );
                },
                child: Icon(
                  FeatherIcons.settings,
                  color: selectedIndex == 3 ? Colors.black : Colors.grey,
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
