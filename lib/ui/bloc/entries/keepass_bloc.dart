import 'dart:isolate';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdbx/kdbx.dart';
import 'package:keepassux/ui/bloc/entries/keepass_events.dart';
import 'package:keepassux/ui/bloc/entries/keepass_states.dart';

class KeePassBloc extends Bloc<KeePassEvent, KeePassState> {
  KeePassBloc() : super(KeePassInitial()) {
    on<LoadDatabase>(_onLoadDatabase);
    on<GetRootGroup>(_onGetRootGroup);
  }

  KdbxGroup? root;

  Future<void> _onLoadDatabase(
      LoadDatabase event,
      Emitter<KeePassState> emit,
      ) async {
    try {
      emit(KeePassLoading());
      print("Loading database...");

      final result = await Isolate.run(() async {
        final credentials = Credentials(ProtectedValue.fromString(event.password));
        final kdbx = await KdbxFormat().read(event.bytes, credentials);
        return {'root': kdbx.body.rootGroup};
      });

      root = result['root'];
      print("Loaded database");
      emit(KeePassLoaded());
    } catch (e, s) {
      print("Error loading: $e\n$s");
      emit(KeePassError('Error al cargar la base: $e'));
    }
  }

  Future<void> _onGetRootGroup(
    GetRootGroup event,
    Emitter<KeePassState> emit,
  ) async {
    try {
      emit(KeePassRootGroup(root));
    } catch (e) {
      emit(KeePassError('Error al cargar la base: $e'));
    }
  }
}
