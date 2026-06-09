import 'dart:typed_data';

abstract class KeePassEvent {}

class LoadDatabase extends KeePassEvent {
  final Uint8List bytes;
  final String password;

  LoadDatabase({required this.bytes, required this.password});
}

class CreateDatabase extends KeePassEvent {
  final String uri;
  final String password;

  CreateDatabase({required this.uri, required this.password});
}

class GetRootGroup extends KeePassEvent {
  GetRootGroup();
}

class AddEntry extends KeePassEvent {
  final String? uuidGroup;
  final String title;
  final String? userName;
  final String? url;
  final String? notes;
  final String password;

  AddEntry({
    this.uuidGroup,
    required this.title,
    this.userName,
    this.url,
    this.notes,
    required this.password,
  });
}

class AddGroup extends KeePassEvent {
  final String? uuidGroup;
  final String title;

  AddGroup({
    this.uuidGroup,
    required this.title,
  });
}

class UpdateEntry extends KeePassEvent {
  final String entryUuid;
  final String title;
  final String? userName;
  final String? url;
  final String? notes;
  final String password;
  final int? icon;
  final Uint8List? customIconData;

  UpdateEntry({
    required this.entryUuid,
    required this.title,
    this.userName,
    this.url,
    this.notes,
    required this.password,
    this.icon,
    this.customIconData,
  });
}
