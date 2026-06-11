import 'dart:typed_data';

abstract class KdbxCommand {}

class LoadDatabaseCmd extends KdbxCommand {
  final Uint8List bytes;
  final String password;
  LoadDatabaseCmd({required this.bytes, required this.password});
}

class AddEntryCmd extends KdbxCommand {
  final String groupUuid;
  final String title;
  final String userName;
  final String url;
  final String notes;
  final String password;
  final int icon;
  final Uint8List? customIconData;
  AddEntryCmd({
    required this.groupUuid,
    required this.title,
    required this.userName,
    required this.url,
    required this.notes,
    required this.password,
    this.icon = 0,
    this.customIconData,
  });
}

class UpdateEntryCmd extends KdbxCommand {
  final String entryUuid;
  final String title;
  final String userName;
  final String url;
  final String notes;
  final String password;
  final int icon;
  final Uint8List? customIconData;
  UpdateEntryCmd({
    required this.entryUuid,
    required this.title,
    required this.userName,
    required this.url,
    required this.notes,
    required this.password,
    required this.icon,
    this.customIconData,
  });
}

class AddGroupCmd extends KdbxCommand {
  final String parentUuid;
  final String name;
  AddGroupCmd({required this.parentUuid, required this.name});
}

class MoveEntryCmd extends KdbxCommand {
  final String entryUuid;
  final String fromGroupUuid;
  final String toGroupUuid;
  MoveEntryCmd({
    required this.entryUuid,
    required this.fromGroupUuid,
    required this.toGroupUuid,
  });
}

class MoveGroupCmd extends KdbxCommand {
  final String groupUuid;
  final String fromGroupUuid;
  final String toGroupUuid;
  MoveGroupCmd({
    required this.groupUuid,
    required this.fromGroupUuid,
    required this.toGroupUuid,
  });
}

class CreateDatabaseCmd extends KdbxCommand {
  final String password;
  CreateDatabaseCmd({required this.password});
}
