import '../../model/db_group.dart';

abstract class KeePassState {}

class KeePassInitial extends KeePassState {}

class KeePassLoading extends KeePassState {}

class KeePassLoaded extends KeePassState {}

class KeePassCreated extends KeePassState {}

class KeePassRootGroup extends KeePassState {
  final DbGroup? rootGroup;
  KeePassRootGroup(this.rootGroup);
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

class KeePassUpdateEntrySuccess extends KeePassState {
  KeePassUpdateEntrySuccess();
}
