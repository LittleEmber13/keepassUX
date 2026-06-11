import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:keepassux/ui/bloc/entries/keepass_bloc.dart';
import 'package:keepassux/ui/bloc/entries/keepass_events.dart';
import 'package:keepassux/ui/model/drag_item.dart';
import 'package:keepassux/ui/pages/group_entries_page.dart';
import 'package:keepassux/ui/widgets/custom_app_scroll.dart';
import 'package:keepassux/ui/widgets/entry_data.dart';
import 'package:keepassux/ui/widgets/kdbx_icon_widget.dart';

import '../bloc/entries/keepass_states.dart';
import '../model/db_entry.dart';
import '../model/db_group.dart';

class AnimatedEntryList extends StatefulWidget {
  const AnimatedEntryList({
    required this.group,
    required this.rootGroup,
    this.onGroupTap,
    this.onDragStarted,
    this.onDragEnded,
    this.parentGroupItemBuilder,
    super.key,
  });

  final DbGroup? group;
  final DbGroup? rootGroup;
  final void Function(DbGroup group)? onGroupTap;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnded;
  final Widget Function()? parentGroupItemBuilder;

  @override
  State<AnimatedEntryList> createState() => _AnimatedEntryListState();
}

class _AnimatedEntryListState extends State<AnimatedEntryList> {
  final GlobalKey<AnimatedListState> _groupsListKey = GlobalKey<AnimatedListState>();
  final GlobalKey<AnimatedListState> _entriesListKey = GlobalKey<AnimatedListState>();

  List<DbGroup> _displayedGroups = [];
  List<DbEntry> _displayedEntries = [];

  @override
  void didUpdateWidget(AnimatedEntryList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.group != oldWidget.group) {
      _syncLists();
    }
  }

  void _syncLists() {
    if (widget.group == null) return;

    final newGroups = widget.group!.groups;
    final newEntries = widget.group!.entries;

    _syncItems<DbGroup>(
      listKey: _groupsListKey,
      oldList: _displayedGroups,
      newList: newGroups,
      getUuid: (item) => item.uuid,
      onUpdated: (updated) => _displayedGroups = updated,
    );

    _syncItems<DbEntry>(
      listKey: _entriesListKey,
      oldList: _displayedEntries,
      newList: newEntries,
      getUuid: (item) => item.uuid,
      onUpdated: (updated) => _displayedEntries = updated,
    );
  }

  void _syncItems<T>({
    required GlobalKey<AnimatedListState> listKey,
    required List<T> oldList,
    required List<T> newList,
    required String Function(T) getUuid,
    required void Function(List<T>) onUpdated,
  }) {
    final oldUuids = oldList.map(getUuid).toList();
    final newUuids = newList.map(getUuid).toList();

    final itemsToRemove = <int>[];
    for (int i = oldUuids.length - 1; i >= 0; i--) {
      if (!newUuids.contains(oldUuids[i])) {
        itemsToRemove.add(i);
      }
    }

    for (final index in itemsToRemove) {
      final removedItem = oldList[index];
      listKey.currentState?.removeItem(
        index,
        (context, animation) => FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            child: _buildRemovedItem(removedItem),
          ),
        ),
        duration: const Duration(milliseconds: 300),
      );
      oldList.removeAt(index);
    }

    for (int i = 0; i < newList.length; i++) {
      final newItem = newList[i];
      final newItemUuid = getUuid(newItem);
      final oldIndex = oldUuids.indexOf(newItemUuid);
      if (oldIndex == -1) {
        listKey.currentState?.insertItem(i, duration: const Duration(milliseconds: 300));
        oldList.insert(i, newItem);
      } else if (oldIndex != i) {
        oldList.removeAt(oldIndex);
        oldList.insert(i, newItem);
      } else {
        oldList[i] = newItem;
      }
    }

    onUpdated(oldList);
  }

  Widget _buildRemovedItem(dynamic item) {
    if (item is DbGroup) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
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
                  child: Text(item.name),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (item is DbEntry) {
      return _buildEntryItem(item);
    }
    return SizedBox.shrink();
  }

  bool _isDescendantOf(String ancestorUuid, String descendantUuid) {
    if (ancestorUuid == descendantUuid) return true;
    final ancestor = _findGroupByUuid(widget.group!, ancestorUuid);
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

  Widget _buildGroupItem(DbGroup currentGroup) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: LongPressDraggable<DragItem>(
        data: DragItem(
          type: DragType.group,
          uuid: currentGroup.uuid,
          sourceGroupUuid: widget.group!.uuid,
        ),
        onDragStarted: widget.onDragStarted,
        onDragEnd: widget.onDragEnded != null ? (_) => widget.onDragEnded!() : null,
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
        child: DragTarget<DragItem>(
          onWillAccept: (draggedItem) {
            if (draggedItem == null) return false;
            if (draggedItem.type == DragType.group &&
                draggedItem.uuid == currentGroup.uuid) {
              return false;
            }
            if (draggedItem.type == DragType.group &&
                _isDescendantOf(draggedItem.uuid, currentGroup.uuid)) {
              return false;
            }
            return true;
          },
          onAccept: (draggedItem) {
            final currentGroupUuid = currentGroup.uuid;
            if (draggedItem.type == DragType.entry) {
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
                    onTap: () => widget.onGroupTap?.call(currentGroup),
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
  }

  Widget _buildEntryDragItem(DbEntry currentEntry) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: LongPressDraggable<DragItem>(
        data: DragItem(
          type: DragType.entry,
          uuid: currentEntry.uuid,
          sourceGroupUuid: widget.group!.uuid,
        ),
        onDragStarted: widget.onDragStarted,
        onDragEnd: widget.onDragEnded != null ? (_) => widget.onDragEnded!() : null,
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
  }

  @override
  Widget build(BuildContext context) {
    _syncLists();

    return CustomAppScroll(
      children: [
        if (widget.parentGroupItemBuilder != null)
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: widget.parentGroupItemBuilder!(),
          ),
        AnimatedList(
          key: _groupsListKey,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          initialItemCount: _displayedGroups.length,
          itemBuilder: (context, index, animation) {
            if (index >= _displayedGroups.length) {
              return SizedBox.shrink();
            }
            final currentGroup = _displayedGroups[index];
            return SizeTransition(
              sizeFactor: AlwaysStoppedAnimation(1.0),
              child: FadeTransition(
                opacity: animation,
                child: _buildGroupItem(currentGroup),
              ),
            );
          },
        ),
        AnimatedList(
          key: _entriesListKey,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          initialItemCount: _displayedEntries.length,
          itemBuilder: (context, index, animation) {
            if (index >= _displayedEntries.length) {
              return SizedBox.shrink();
            }
            final currentEntry = _displayedEntries[index];
            return SizeTransition(
              sizeFactor: AlwaysStoppedAnimation(1.0),
              child: FadeTransition(
                opacity: animation,
                child: _buildEntryDragItem(currentEntry),
              ),
            );
          },
        ),
      ],
    );
  }
}
