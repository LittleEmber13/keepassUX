abstract class KeePassEvent {}

class LoadDatabase extends KeePassEvent {
  final List<int> bytes;
  final String password;

  LoadDatabase({required this.bytes, required this.password});
}
