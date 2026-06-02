import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kdbx/kdbx.dart';
import 'package:keepassux/ui/bloc/entries/keepass_bloc.dart';
import 'package:keepassux/ui/bloc/entries/keepass_events.dart';
import 'package:keepassux/ui/bloc/entries/keepass_states.dart';
import 'package:keepassux/ui/pages/start_page.dart';
import 'package:keepassux/ui/widgets/custom_app_bar.dart';
import 'package:keepassux/ui/widgets/custom_app_scroll.dart';
import 'package:keepassux/ui/widgets/custom_bottom_navigation_bar.dart';
import 'package:collection/collection.dart';
import 'package:keepassux/ui/widgets/entry_data.dart';
import 'package:keepassux/ui/widgets/kdbx_icon_widget.dart';

class EntriesPage extends StatefulWidget {
  const EntriesPage({this.uuidGroup, super.key});

  final String? uuidGroup;

  @override
  State<EntriesPage> createState() => _EntriesPageState();
}

class _EntriesPageState extends State<EntriesPage> {
  final TextEditingController searchBarController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  KdbxGroup? group;

  @override
  void dispose() {
    searchBarController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KeePassBloc>().add(GetRootGroup());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<KeePassBloc, KeePassState>(
      listener: (context, state) {
        if (state is KeePassRootGroup) {
          if (widget.uuidGroup == null) {
            setState(() {
              group = state.group;
            });
          } else {
            List<KdbxGroup> allGroups = state.group?.getAllGroups() ?? [];
            setState(() {
              group = allGroups.firstWhereOrNull(
                (g) => g.uuid.uuid == widget.uuidGroup,
              );
            });
          }
        }
        if (state is KeePassError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      builder: (context, state) {
        return Stack(
          fit: StackFit.expand,
          children: [
            _page(),
            if (state is KeePassLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      },
    );
  }

  Widget _page() {
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
            child: CustomAppBar(
              isExit: widget.uuidGroup == null,
              onTapExit: () {
                if (widget.uuidGroup != null) {
                  Navigator.pop(context);
                } else {
                  // TODO unload database
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => StartPage()),
                    (Route<dynamic> route) => false,
                  );
                }
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        uuidGroup: widget.uuidGroup,
        selectedIndex: 0,
      ),
      body: SafeArea(
        child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
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
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchBarController,
                        decoration: InputDecoration(
                          hintText: tr("entries_page.search"),
                          contentPadding: EdgeInsets.all(0),
                          isDense: true,
                          filled: false,
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
          CustomAppScroll(
            children: [
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Container(
                      height: 32,
                      decoration: BoxDecoration(
                        color: Color(0xFFEEFDFF),
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
                      child: Row(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, top: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFEEFDFF),
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
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [Text("Title"), Icon(Icons.close)],
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
                group?.groups.length ?? 0,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(FontAwesomeIcons.folder),
                      SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => EntriesPage(
                                      uuidGroup: group!.groups[index].uuid.uuid,
                                    ),
                              ),
                            );
                          },
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
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                group!.groups[index].name.get() ?? "-",
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ...List.generate(
                group?.entries.length ?? 0,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (BuildContext ctx) {
                          return Padding(
                            padding: const EdgeInsets.all(24),
                            child: EntryData(entry: group!.entries[index]),
                          );
                        },
                      );
                    },
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
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            KDBXIconWidget(
                              object: group!.entries[index],
                              size: 24,
                              color: Colors.lightBlueAccent,
                            ),
                            SizedBox(width: 16),
                            Text(group!.entries[index].label ?? ""),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}
