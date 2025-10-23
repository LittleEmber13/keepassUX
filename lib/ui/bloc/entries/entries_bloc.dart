import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kpasslib/kpasslib.dart';

import 'entries_events.dart';
import 'entries_states.dart';

class KeePassBloc extends Bloc<KeePassEvent, KeePassState> {
  KeePassBloc() : super(KeePassInitial()) {
    on<LoadDatabase>(_onLoadDatabase);
  }

  Future<void> _onLoadDatabase(
      LoadDatabase event, Emitter<KeePassState> emit) async {
    emit(KeePassLoading());

    try {
      final credentials = KdbxCredentials(
        password: ProtectedData.fromString(event.password),
      );

      final db = await KdbxDatabase.fromBytes(
        data: event.bytes,
        credentials: credentials,
      );

      final items = <dynamic>[];

      void recorrerGrupo(KdbxGroup grupo) {
        items.add(grupo);
        items.addAll(grupo.entries);
        for (final sub in grupo.groups) {
          recorrerGrupo(sub);
        }
      }

      recorrerGrupo(db.root);

      emit(KeePassLoaded(items));
    } catch (e) {
      emit(KeePassError('Error al cargar la base: $e'));
    }
  }
}
