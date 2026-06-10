import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:collection/collection.dart';
import 'package:keepassux/ui/bloc/entries/keepass_bloc.dart';
import 'package:keepassux/ui/bloc/entries/keepass_events.dart';
import 'package:keepassux/ui/bloc/entries/keepass_states.dart';
import 'package:keepassux/ui/pages/start_page.dart';
import 'package:keepassux/ui/widgets/custom_app_bar.dart';
import 'package:keepassux/ui/widgets/custom_app_scroll.dart';
import 'package:keepassux/ui/widgets/custom_bottom_navigation_bar.dart';
import 'package:keepassux/ui/model/alert_item.dart';
import 'package:keepassux/ui/widgets/alert_stack.dart';
import 'package:keepassux/ui/widgets/entry_data.dart';
import 'package:keepassux/ui/widgets/kdbx_icon_widget.dart';

import '../model/db_entry.dart';
import '../model/db_group.dart';

enum _DragType { entry, group }

class _DragItem {
  final _DragType type;
  final String uuid;
  final String sourceGroupUuid;

  const _DragItem({
    required this.type,
    required this.uuid,
    required this.sourceGroupUuid,
  });
}

class EntriesPage extends StatefulWidget {
  const EntriesPage({this.uuidGroup, super.key});

  final String? uuidGroup;

  @override
  State<EntriesPage> createState() => _EntriesPageState();
}

class _EntriesPageState extends State<EntriesPage> {
  final TextEditingController searchBarController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  DbGroup? group;
  DbGroup? _rootGroup;

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

  bool _isDescendantOf(String ancestorUuid, String descendantUuid) {
    if (ancestorUuid == descendantUuid) return true;
    final ancestor = _findGroupByUuid(group!, ancestorUuid);
    if (ancestor == null) return false;
    final descendants = ancestor.getAllGroups().map((g) => g.uuid).toList();
    return descendants.contains(descendantUuid);
  }

  DbGroup? _findGroupByUuid(DbGroup root, String uuid) {
    if (root.uuid == uuid) return root;
    for (final child in root.groups) {
      final found = _findGroupByUuid(child, uuid);
      if (found != null) return found;
    }
    return null;
  }

  DbGroup? _findParentGroup() {
    if (widget.uuidGroup == null || _rootGroup == null) return null;
    if (_rootGroup!.uuid == widget.uuidGroup) return null;
    return _findParentRecursive(_rootGroup!, widget.uuidGroup!);
  }

  DbGroup? _findParentRecursive(DbGroup current, String targetUuid) {
    for (final child in current.groups) {
      if (child.uuid == targetUuid) return current;
      final found = _findParentRecursive(child, targetUuid);
      if (found != null) return found;
    }
    return null;
  }

  void _moveEntry(String entryUuid, String fromUuid, String toUuid) {
    context.read<KeePassBloc>().add(
      MoveEntry(
        entryUuid: entryUuid,
        fromGroupUuid: fromUuid,
        toGroupUuid: toUuid,
      ),
    );
  }

  void _moveGroup(String groupUuid, String fromUuid, String toUuid) {
    context.read<KeePassBloc>().add(
      MoveGroup(
        groupUuid: groupUuid,
        fromGroupUuid: fromUuid,
        toGroupUuid: toUuid,
      ),
    );
  }

  Widget _buildDragFeedback({required Widget child}) {
    return Material(
      color: Colors.transparent,
      child: Opacity(
        opacity: 0.85,
        child: Transform.scale(
          scale: 1.05,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildEntryItem(DbEntry entry) {
    return Container(
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
              icon: entry.icon,
              customIconData: entry.customIconData,
              size: 24,
              color: Colors.lightBlueAccent,
            ),
            SizedBox(width: 16),
            Text(entry.label ?? ""),
          ],
        ),
      ),
    );
  }

  Widget _buildParentGroupItem() {
    final parentGroup = _findParentGroup();
    if (parentGroup == null) return SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DragTarget<_DragItem>(
        onWillAccept: (draggedItem) {
          if (draggedItem == null) return false;
          if (draggedItem.type == _DragType.group &&
              draggedItem.uuid == parentGroup.uuid) {
            return false;
          }
          return true;
        },
        onAccept: (draggedItem) {
          if (draggedItem.type == _DragType.entry) {
            _moveEntry(
              draggedItem.uuid,
              draggedItem.sourceGroupUuid,
              parentGroup.uuid,
            );
          } else {
            _moveGroup(
              draggedItem.uuid,
              draggedItem.sourceGroupUuid,
              parentGroup.uuid,
            );
          }
        },
        builder: (context, candidateData, rejectedData) {
          final isHovering = candidateData.isNotEmpty;
          return Row(
            children: [
              Icon(FontAwesomeIcons.folder),
              SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: isHovering
                          ? Border.all(
                              color: Colors.lightBlueAccent,
                              width: 2,
                            )
                          : null,
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
                      child: Text("..."),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<KeePassBloc, KeePassState>(
      listener: (context, state) {
        if (state is KeePassRootGroup) {
          if (widget.uuidGroup == null) {
            setState(() {
              _rootGroup = state.rootGroup;
              group = state.rootGroup;
            });
          } else {
            List<DbGroup> allGroups = state.rootGroup?.getAllGroups() ?? [];
            setState(() {
              _rootGroup = state.rootGroup;
              group = allGroups.firstWhereOrNull(
                (g) => g.uuid == widget.uuidGroup,
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AlertStack(
                    alerts: const [
                      AlertItem(
                        title: "Title",
                        text: "dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam",
                      ),
                      AlertItem(
                        title: "Title2",
                        text: "t, sed do eiusmod tempor incididunt ut et dolore magna aliqua. Ut enim ad minim veniam",
                      ),
                      AlertItem(
                        title: "Title3",
                        text: "et dolore magna aliqua. Ut enim ad minim veniam",
                      ),
                    ],
                  ),
                ),
                if (widget.uuidGroup != null) ...[
                  _buildParentGroupItem(),
                ],
                ...List.generate(
                  group?.groups.length ?? 0,
                  (index) {
                    final currentGroup = group!.groups[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: LongPressDraggable<_DragItem>(
                        data: _DragItem(
                          type: _DragType.group,
                          uuid: currentGroup.uuid,
                          sourceGroupUuid: group!.uuid,
                        ),
                        feedback: _buildDragFeedback(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.7,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Icon(FontAwesomeIcons.folder),
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.all(16),
                                    child: Text(currentGroup.name),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.4,
                          child: Row(
                            children: [
                              Icon(FontAwesomeIcons.folder),
                              SizedBox(width: 16),
                              Expanded(
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
                                    child: Text(currentGroup.name),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        child: DragTarget<_DragItem>(
                          onWillAccept: (draggedItem) {
                            if (draggedItem == null) return false;
                            if (draggedItem.type == _DragType.group &&
                                draggedItem.uuid == currentGroup.uuid) {
                              return false;
                            }
                            if (draggedItem.type == _DragType.group &&
                                _isDescendantOf(draggedItem.uuid, currentGroup.uuid)) {
                              return false;
                            }
                            return true;
                          },
                          onAccept: (draggedItem) {
                            final currentGroupUuid = currentGroup.uuid;
                            if (draggedItem.type == _DragType.entry) {
                              _moveEntry(
                                draggedItem.uuid,
                                draggedItem.sourceGroupUuid,
                                currentGroupUuid,
                              );
                            } else {
                              if (draggedItem.uuid == currentGroupUuid) return;
                              _moveGroup(
                                draggedItem.uuid,
                                draggedItem.sourceGroupUuid,
                                currentGroupUuid,
                              );
                            }
                          },
                          builder: (context, candidateData, rejectedData) {
                            final isHovering = candidateData.isNotEmpty;
                            return Row(
                              children: [
                                Icon(FontAwesomeIcons.folder),
                                SizedBox(width: 16),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EntriesPage(
                                            uuidGroup: currentGroup.uuid,
                                          ),
                                        ),
                                      );
                                    },
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 200),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: isHovering
                                            ? Border.all(
                                                color: Colors.lightBlueAccent,
                                                width: 2,
                                              )
                                            : null,
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
                                        child: Text(currentGroup.name),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
                ...List.generate(
                  group?.entries.length ?? 0,
                  (index) {
                    final currentEntry = group!.entries[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: LongPressDraggable<_DragItem>(
                        data: _DragItem(
                          type: _DragType.entry,
                          uuid: currentEntry.uuid,
                          sourceGroupUuid: group!.uuid,
                        ),
                        feedback: _buildDragFeedback(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.7,
                            child: _buildEntryItem(currentEntry),
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.4,
                          child: _buildEntryItem(currentEntry),
                        ),
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
                              isScrollControlled: true,
                              builder: (BuildContext ctx) {
                                return SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.75,
                                  child: BlocBuilder<KeePassBloc, KeePassState>(
                                    builder: (context, state) {
                                      return Stack(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(24),
                                            child: EntryData(
                                              entry: currentEntry,
                                            ),
                                          ),
                                          if (state is KeePassLoading)
                                            Container(
                                              color: Colors.black.withOpacity(0.5),
                                              child: const Center(
                                                child: CircularProgressIndicator(),
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          },
                          child: _buildEntryItem(currentEntry),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
