import 'dart:typed_data';
import 'db_entry.dart';

class DbGroup {
  final String uuid;
  final String name;
  final int icon;
  final Uint8List? customIconData;
  final List<DbGroup> groups;
  final List<DbEntry> entries;
  final bool isRecycleBin;

  DbGroup({
    required this.uuid,
    required this.name,
    required this.icon,
    this.customIconData,
    required this.groups,
    required this.entries,
    this.isRecycleBin = false,
  });

  List<DbGroup> getAllGroups() {
    final result = <DbGroup>[];
    for (final group in groups) {
      result.add(group);
      result.addAll(group.getAllGroups());
    }
    return result;
  }
}