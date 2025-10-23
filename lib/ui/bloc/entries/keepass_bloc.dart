import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdbx/kdbx.dart';
import 'package:keepassux/ui/bloc/entries/keepass_events.dart';
import 'package:keepassux/ui/bloc/entries/keepass_states.dart';

class KeePassBloc extends Bloc<KeePassEvent, KeePassState> {
  KeePassBloc() : super(KeePassInitial()) {
    on<LoadDatabase>(_onLoadDatabase);
  }

  Future<void> _onLoadDatabase(
    LoadDatabase event,
    Emitter<KeePassState> emit,
  ) async {
    emit(KeePassLoading());
    try {
      Credentials credentials = Credentials(
        ProtectedValue.fromString(event.password),
      );

      KdbxFile kdbx = await KdbxFormat().read(event.bytes, credentials);

      KdbxGroup? root = kdbx.body.rootGroup;

      print("Lodead items!");
      print(root.getAllEntries().length);
      print(root.getAllGroups().length);
      print(root.getAllGroupsAndEntries().length);

      emit(KeePassLoaded([]));
    } catch (e) {
      emit(KeePassError('Error al cargar la base: $e'));
    }
  }

}
