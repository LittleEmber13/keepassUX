abstract class KeePassState {}

class KeePassInitial extends KeePassState {}
class KeePassLoading extends KeePassState {}
class KeePassLoaded extends KeePassState {
  final List<dynamic> items;
  KeePassLoaded(this.items);
}
class KeePassError extends KeePassState {
  final String message;
  KeePassError(this.message);
}