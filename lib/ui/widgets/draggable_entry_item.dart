import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keepassux/ui/bloc/entries/keepass_bloc.dart';
import 'package:keepassux/ui/bloc/entries/keepass_states.dart';
import 'package:keepassux/ui/model/db_entry.dart';
import 'package:keepassux/ui/model/drag_item.dart';
import 'package:keepassux/ui/theme/theme.dart';
import 'package:keepassux/ui/widgets/entry_data.dart';
import 'package:keepassux/ui/widgets/kdbx_icon_widget.dart';

class DraggableEntryItem extends StatelessWidget {
  const DraggableEntryItem({
    required this.entry,
    required this.sourceGroupUuid,
    required this.onDragStarted,
    required this.onDragEnd,
    super.key,
  });

  final DbEntry entry;
  final String sourceGroupUuid;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: LongPressDraggable<DragItem>(
        data: DragItem(
          type: DragType.entry,
          uuid: entry.uuid,
          sourceGroupUuid: sourceGroupUuid,
        ),
        onDragStarted: onDragStarted,
        onDragEnd: onDragEnd != null ? (_) => onDragEnd!() : null,
        feedback: _buildDragFeedback(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            child: _buildEntryItem(context),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.4,
          child: _buildEntryItem(context),
        ),
        child: InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Theme.of(context).colorScheme.surface,
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
                            child: EntryData(entry: entry),
                          ),
                          if (state is KeePassLoading)
                            Container(
                              color: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.5),
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
          child: _buildEntryItem(context),
        ),
      ),
    );
  }

  Widget _buildEntryItem(BuildContext context) {
    return Container(
      decoration: cardDecoration(context),
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
            Text(entry.label),
          ],
        ),
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
                  color: Colors.black.withValues(alpha: 0.2),
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
}
