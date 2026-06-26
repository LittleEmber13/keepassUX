import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:keepassux/ui/theme/theme.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final TextEditingController searchBarController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    searchBarController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(116),
        child: Container(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.only(
              top: 52,
              bottom: 6,
              left: 24,
              right: 24,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: cardDecoration(context),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        child: Icon(
                          FeatherIcons.logOut,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Hola,',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Bienvenido',
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
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
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
                Icon(FontAwesomeIcons.star),
                Icon(
                  FontAwesomeIcons.folder,
                  color: context.appColors.secondaryText,
                ),
                Container(
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
                Icon(
                  FontAwesomeIcons.user,
                  color: context.appColors.secondaryText,
                ),
                Icon(
                  FeatherIcons.settings,
                  color: context.appColors.secondaryText,
                  size: 26,
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              decoration: cardDecoration(context),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchBarController,
                        decoration: InputDecoration(
                          hintText: "Search for an entry",
                          contentPadding: EdgeInsets.all(0),
                          isDense: true,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Icon(Icons.search),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 24),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: 8,
                          decoration: BoxDecoration(
                            color: context.appColors.secondaryText.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                    ],
                  ),
                  RawScrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    thickness: 8.0,
                    trackVisibility: false,
                    trackColor: Theme.of(context).colorScheme.onSurface,
                    thumbColor: context.appColors.cardBackground,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(99)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 24),
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                  ),
                                  child: Container(
                                    height: 32,
                                    decoration: cardDecoration(context),
                                    child: Row(),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 8,
                                    top: 8,
                                  ),
                                  child: Container(
                                    decoration: cardDecoration(context),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text("Title"),
                                              Icon(Icons.close),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            "dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam",
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            ...List.generate(
                              30,
                              (index) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Container(
                                  decoration: cardDecoration(context),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Icon(
                                          FontAwesomeIcons.twitter,
                                          color: Colors.lightBlueAccent,
                                        ),
                                        SizedBox(width: 16),
                                        Text('Item $index'),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
