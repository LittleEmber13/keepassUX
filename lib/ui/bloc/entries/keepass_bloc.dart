import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:content_resolver/content_resolver.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdbx/kdbx.dart';
import 'package:keepassux/ui/bloc/entries/keepass_events.dart';
import 'package:keepassux/ui/bloc/entries/keepass_states.dart';
import 'package:logger/logger.dart';
import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KeePassBloc extends Bloc<KeePassEvent, KeePassState> {
  KeePassBloc() : super(KeePassInitial()) {
    on<LoadDatabase>(_onLoadDatabase);
    on<AddEntry>(_onAddEntry);
    on<AddGroup>(_onAddGroup);
    on<GetRootGroup>(_onGetRootGroup);
    on<CreateDatabase>(_onCreateDatabase);
  }

  KdbxFile? kdbx;
  SharedPreferences? preferences;

  Logger logger = Logger();

  Future<void> _onLoadDatabase(
      LoadDatabase event,
      Emitter<KeePassState> emit,
      ) async {
    try {
      emit(KeePassLoading());
      print("Loading database...");

      preferences = await SharedPreferences.getInstance();

      final result = await Isolate.run(() async {
        final credentials = Credentials(
          ProtectedValue.fromString(event.password),
        );
        KdbxFile kdbx = await KdbxFormat().read(event.bytes, credentials);
        return {'kdbx': kdbx};
      });

      kdbx = result['kdbx'];

      print("Loaded database");
      emit(KeePassLoaded());
    } catch (e, s) {
      logger.e(e);
      emit(KeePassError('Error al cargar la base: $e'));
    }
  }

  Future<void> _onCreateDatabase(
      CreateDatabase event,
      Emitter<KeePassState> emit,
      ) async {
    try {
      emit(KeePassLoading());
      print("Creating database...");

      preferences = await SharedPreferences.getInstance();

      kdbx = KdbxFormat().create(
        Credentials(ProtectedValue.fromString(event.password)),
        'KeepassUX',
      );
      Uint8List bytes = await kdbx!.save();
      await ContentResolver.writeContent(event.uri, bytes);

      print("Created database");
      emit(KeePassCreated());
    } catch (e, s) {
      logger.e(e);
      emit(KeePassError('Error al crear la base: $e'));
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
      List<KdbxGroup> allGroups = kdbx!.body.rootGroup.getAllGroups();
      KdbxGroup? foundGroup = allGroups.firstWhereOrNull(
              (g) => g.uuid.uuid == event.uuidGroup,
        );
      KdbxGroup group = foundGroup ?? kdbx!.body.rootGroup;
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

      await _saveFile();

      emit(KeePassRootGroup(kdbx!.body.rootGroup));
      emit(KeePassAddEntrySuccess());
    } catch (e) {
      logger.e(e);
      emit(KeePassError('Error al cargar la base: $e'));
    }
  }

  Future<void> _onAddGroup(AddGroup event, Emitter<KeePassState> emit) async {
    try {
      emit(KeePassLoading());
      List<KdbxGroup> allGroups = kdbx!.body.rootGroup.getAllGroups();
      KdbxGroup? foundGroup = allGroups.firstWhereOrNull(
            (g) => g.uuid.uuid == event.uuidGroup,
      );
      KdbxGroup group = foundGroup ?? kdbx!.body.rootGroup;
      KdbxGroup newGroup = KdbxGroup.create(
        ctx: kdbx!.ctx,
        parent: group,
        name: event.title,
      );
      group.addGroup(newGroup);

      await _saveFile();

      emit(KeePassRootGroup(kdbx!.body.rootGroup));
      emit(KeePassAddGroupSuccess());
    } catch (e) {
      logger.e(e);
      emit(KeePassError('Error al cargar la base: $e'));
    }
  }

  _saveFile() async {
    String? uri = preferences?.getString('kdbx_uri');
    if (uri != null) {
      Uint8List bytes = await kdbx!.save();
      await ContentResolver.writeContent(uri, bytes);
      print("Archivo actualizado correctamente en su ubicación original");
    } else {
      print("file unsaved");
      throw Exception();
    }
  }

}
