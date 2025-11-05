import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdbx/kdbx.dart';
import 'package:keepassux/ui/bloc/entries/keepass_events.dart';
import 'package:keepassux/ui/bloc/entries/keepass_states.dart';
import 'package:logger/logger.dart';

class KeePassBloc extends Bloc<KeePassEvent, KeePassState> {
  KeePassBloc() : super(KeePassInitial()) {
    on<LoadDatabase>(_onLoadDatabase);
    on<AddEntry>(_onAddEntry);
    on<GetRootGroup>(_onGetRootGroup);
  }

  KdbxFile? kdbx;

  Logger logger = Logger();

  Future<void> _onLoadDatabase(
    LoadDatabase event,
    Emitter<KeePassState> emit,
  ) async {
    try {
      emit(KeePassLoading());
      print("Loading database...");

      //final result = await Isolate.run(() async {
      //  final credentials = Credentials(
      //    ProtectedValue.fromString(event.password),
      //  );
      //  KdbxFile kdbx = await KdbxFormat().read(event.bytes, credentials);
      //  return {'kdbx': kdbx};
      //});
      //
      //KdbxFile? originalKdbx = result['kdbx'];

      kdbx = KdbxFormat().create(
        Credentials(ProtectedValue.fromString(event.password)),
        'KeepassUX',
      );

      print("Loaded database");
      emit(KeePassLoaded());
    } catch (e, s) {
      logger.e(e);
      emit(KeePassError('Error al cargar la base: $e'));
    }
  }

  Future<void> _onGetRootGroup(
    GetRootGroup event,
    Emitter<KeePassState> emit,
  ) async {
    try {
      emit(KeePassRootGroup(kdbx!.body.rootGroup));
    } catch (e) {
      logger.e(e);
      emit(KeePassError('Error al cargar la base: $e'));
    }
  }

  Future<void> _onAddEntry(AddEntry event, Emitter<KeePassState> emit) async {
    try {
      emit(KeePassLoading());
      KdbxGroup group = event.group ?? kdbx!.body.rootGroup;
      KdbxEntry entry = KdbxEntry.create(kdbx!, group);
      group.addEntry(entry);
      entry.setString(KdbxKeyCommon.TITLE, PlainValue(event.title));
      entry.setString(KdbxKeyCommon.USER_NAME, PlainValue(event.userName));
      entry.setString(KdbxKeyCommon.URL, PlainValue(event.url));

      /// TODO NOTES

      entry.setString(
        KdbxKeyCommon.PASSWORD,
        ProtectedValue.fromString(event.password),
      );

      await Future(() => kdbx!.save());

      emit(KeePassRootGroup(kdbx!.body.rootGroup));
    } catch (e) {
      logger.e(e);
      emit(KeePassError('Error al cargar la base: $e'));
    }
  }
}
