import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:collection/collection.dart';
import 'package:keepassux/ui/bloc/entries/keepass_bloc.dart';
import 'package:keepassux/ui/bloc/entries/keepass_events.dart';
import 'package:keepassux/ui/bloc/entries/keepass_states.dart';
import 'package:keepassux/ui/model/drag_item.dart';
import 'package:keepassux/ui/widgets/animated_entry_list.dart';
import 'package:keepassux/ui/widgets/group_app_bar.dart';
import 'package:keepassux/ui/widgets/custom_bottom_navigation_bar.dart';

import '../model/db_group.dart';

class GroupEntriesPage extends StatefulWidget {
  const GroupEntriesPage({required this.uuidGroup, super.key});

  final String uuidGroup;

  @override
  State<GroupEntriesPage> createState() => _GroupEntriesPageState();
}

class _GroupEntriesPageState extends State<GroupEntriesPage> {
  DbGroup? group;
  DbGroup? _rootGroup;
  bool _isDragging = false;
  bool _showParentSpace = false;
  bool _showParentContent = false;
  Timer? _parentItemTimer;

  @override
  void dispose() {
    _parentItemTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KeePassBloc>().add(GetRootGroup());
    });
  }

  void _onDragStateChanged(bool dragging) {
    _parentItemTimer?.cancel();
    if (dragging) {
      setState(() {
        _isDragging = true;
        _showParentSpace = true;
      });
      _parentItemTimer = Timer(const Duration(milliseconds: 300), () {
        if (_isDragging) {
          setState(() => _showParentContent = true);
        }
      });
    } else {
      setState(() {
        _isDragging = false;
        _showParentContent = false;
      });
      _parentItemTimer = Timer(const Duration(milliseconds: 300), () {
        if (!_isDragging) {
          setState(() => _showParentSpace = false);
        }
      });
    }
  }

  DbGroup? _findParentGroup() {
    if (_rootGroup == null) return null;
    if (_rootGroup!.uuid == widget.uuidGroup) return null;
    return _findParentRecursive(_rootGroup!, widget.uuidGroup);
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

  Widget _buildParentGroupItem() {
    final parentGroup = _findParentGroup();
    final showItem = parentGroup != null && _showParentSpace;

    return SizedBox(
      height: showItem ? null : 0,
      child: AnimatedOpacity(
        opacity: _showParentContent ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: showItem
            ? Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: DragTarget<DragItem>(
                  onWillAcceptWithDetails: (details) {
                    final draggedItem = details.data;
                    if (draggedItem.type == DragType.group &&
                        draggedItem.uuid == parentGroup.uuid) {
                      return false;
                    }
                    return true;
                  },
                  onAcceptWithDetails: (details) {
                    final draggedItem = details.data;
                    if (draggedItem.type == DragType.entry) {
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
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isHovering ? Color(0xFFEEFDFF) : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: isHovering
                                  ? Border.all(
                                      color: Colors.lightBlueAccent,
                                      width: 2,
                                    )
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
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
                      ],
                    );
                  },
                ),
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<KeePassBloc, KeePassState>(
      listener: (context, state) {
        if (state is KeePassRootGroup) {
          List<DbGroup> allGroups = state.rootGroup?.getAllGroups() ?? [];
          setState(() {
            _rootGroup = state.rootGroup;
            group = allGroups.firstWhereOrNull(
              (g) => g.uuid == widget.uuidGroup,
            );
          });
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
                color: Colors.black.withValues(alpha: 0.5),
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
        preferredSize: Size.fromHeight(100),
        child: Container(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.only(
              top: 52,
              bottom: 6,
              left: 24,
              right: 24,
            ),
            child: GroupAppBar(
              title: group?.name ?? '',
              onTapExit: () => Navigator.pop(context),
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
            SizedBox(height: 8),
            Expanded(
              child: AnimatedEntryList(
                group: group,
                rootGroup: _rootGroup,
                onGroupTap: (g) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupEntriesPage(
                        uuidGroup: g.uuid,
                      ),
                    ),
                  );
                },
                onDragStarted: () => _onDragStateChanged(true),
                onDragEnded: () => _onDragStateChanged(false),
                parentGroupItemBuilder: _buildParentGroupItem,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
