import 'package:kdbx/kdbx.dart';

abstract class KeePassState {}

class KeePassInitial extends KeePassState {}

class KeePassLoading extends KeePassState {}

class KeePassLoaded extends KeePassState {
  KeePassLoaded();
}

class KeePassRootGroup extends KeePassState {
  final KdbxGroup? group;
  KeePassRootGroup(this.group);
}

class KeePassError extends KeePassState {
  final String message;
  KeePassError(this.message);
}

class KeePassAddEntrySuccess extends KeePassState {
  KeePassAddEntrySuccess();
}

class KeePassAddGroupSuccess extends KeePassState {
  KeePassAddGroupSuccess();
}