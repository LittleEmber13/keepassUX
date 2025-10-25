import 'dart:typed_data';

abstract class KeePassEvent {}

class LoadDatabase extends KeePassEvent {
  final Uint8List bytes;
  final String password;

  LoadDatabase({required this.bytes, required this.password});
}

class GetRootGroup extends KeePassEvent {
  GetRootGroup();
}
