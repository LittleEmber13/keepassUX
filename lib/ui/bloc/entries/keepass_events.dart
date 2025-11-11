import 'dart:typed_data';

import 'package:kdbx/kdbx.dart';

abstract class KeePassEvent {}

class LoadDatabase extends KeePassEvent {
  final Uint8List bytes;
  final String password;

  LoadDatabase({required this.bytes, required this.password});
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
