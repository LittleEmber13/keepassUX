import 'package:content_resolver/content_resolver.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keepassux/ui/bloc/entries/keepass_events.dart';
import 'package:keepassux/ui/bloc/entries/keepass_states.dart';
import 'package:keepassux/ui/utils/kdbx_isolate.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/db_group.dart';
import '../../model/db_root.dart';
import '../../model/kdbx_action_result.dart';
import '../../utils/kdbx_command.dart';

class KeePassBloc extends Bloc<KeePassEvent, KeePassState> {
  KeePassBloc() : super(KeePassInitial()) {
    on<LoadDatabase>(_onLoadDatabase);
    on<AddEntry>(_onAddEntry);
    on<AddGroup>(_onAddGroup);
    on<GetRootGroup>(_onGetRootGroup);
    on<CreateDatabase>(_onCreateDatabase);
    on<UpdateEntry>(_onUpdateEntry);
    on<MoveEntry>(_onMoveEntry);
    on<MoveGroup>(_onMoveGroup);
    _initIsolate();
  }

  final KdbxIsolate _kdbxIsolate = KdbxIsolate();
  SharedPreferences? preferences;
  DbGroup? _currentRoot;

  Logger logger = Logger();

  Future<void> _initIsolate() async {
    await _kdbxIsolate.init();
  }

  Future<void> _onLoadDatabase(
    LoadDatabase event,
    Emitter<KeePassState> emit,
  ) async {
    try {
      emit(KeePassLoading());

      preferences = await SharedPreferences.getInstance();

      final root = await _kdbxIsolate.send<DbRoot>(
        LoadDatabaseCmd(bytes: event.bytes, password: event.password),
      );
      _currentRoot = root.rootGroup;

      emit(KeePassLoaded());
    } catch (e) {
      logger.e(e);
      if (e.toString().contains('Invalid key') ||
          e.toString().contains('decrypt')) {
        emit(KeePassError(tr("exception.invalid_password")));
      } else {
        emit(KeePassError(tr("exception.unknown")));
      }
    }
  }

  Future<void> _onCreateDatabase(
    CreateDatabase event,
    Emitter<KeePassState> emit,
  ) async {
    try {
      emit(KeePassLoading());

      if (event.uri.isEmpty) {
        throw Exception("URI is null");
      }

      preferences = await SharedPreferences.getInstance();

      final result = await _kdbxIsolate.send<KdbxActionResult>(
        CreateDatabaseCmd(password: event.password),
      );
      _currentRoot = result.root.rootGroup;

      await ContentResolver.writeContent(event.uri, result.savedBytes);
      await preferences!.setString('kdbx_uri', event.uri);

      emit(KeePassCreated());
    } catch (e) {
      logger.e(e);
      emit(KeePassError(tr("exception.unknown")));
    }
  }

  void _onGetRootGroup(
    GetRootGroup event,
    Emitter<KeePassState> emit,
  ) {
    if (_currentRoot != null) {
      emit(KeePassRootGroup(_currentRoot!));
    }
  }

  Future<void> _onAddEntry(AddEntry event, Emitter<KeePassState> emit) async {
    try {
      emit(KeePassLoading());

      final result = await _kdbxIsolate.send<KdbxActionResult>(
        AddEntryCmd(
          groupUuid: event.uuidGroup ?? _currentRoot!.uuid,
          title: event.title,
          userName: event.userName ?? '',
          url: event.url ?? '',
          notes: event.notes ?? '',
          password: event.password,
        ),
      );
      _currentRoot = result.root.rootGroup;

      await _saveBytes(result.savedBytes);

      emit(KeePassRootGroup(_currentRoot!));
      emit(KeePassAddEntrySuccess());
    } catch (e) {
      logger.e(e);
      emit(KeePassError(tr("exception.unknown")));
    }
  }

  Future<void> _onAddGroup(AddGroup event, Emitter<KeePassState> emit) async {
    try {
      emit(KeePassLoading());

      final result = await _kdbxIsolate.send<KdbxActionResult>(
        AddGroupCmd(
          parentUuid: event.uuidGroup ?? _currentRoot!.uuid,
          name: event.title,
        ),
      );
      _currentRoot = result.root.rootGroup;

      await _saveBytes(result.savedBytes);

      emit(KeePassRootGroup(_currentRoot!));
      emit(KeePassAddGroupSuccess());
    } catch (e) {
      logger.e(e);
      emit(KeePassError(tr("exception.unknown")));
    }
  }

  Future<void> _onUpdateEntry(
    UpdateEntry event,
    Emitter<KeePassState> emit,
  ) async {
    try {
      emit(KeePassLoading());

      final result = await _kdbxIsolate.send<KdbxActionResult>(
        UpdateEntryCmd(
          entryUuid: event.entryUuid,
          title: event.title,
          userName: event.userName ?? '',
          url: event.url ?? '',
          notes: event.notes ?? '',
          password: event.password,
          icon: event.icon ?? 0,
          customIconData: event.customIconData,
        ),
      );
      _currentRoot = result.root.rootGroup;

      await _saveBytes(result.savedBytes);

      emit(KeePassRootGroup(_currentRoot!));
      emit(KeePassUpdateEntrySuccess());
    } catch (e) {
      logger.e(e);
      emit(KeePassError(tr("exception.unknown")));
    }
  }

  Future<void> _onMoveEntry(MoveEntry event, Emitter<KeePassState> emit) async {
    try {
      emit(KeePassLoading());

      final result = await _kdbxIsolate.send<KdbxActionResult>(
        MoveEntryCmd(
          entryUuid: event.entryUuid,
          fromGroupUuid: event.fromGroupUuid,
          toGroupUuid: event.toGroupUuid,
        ),
      );
      _currentRoot = result.root.rootGroup;

      await _saveBytes(result.savedBytes);

      emit(KeePassRootGroup(_currentRoot!));
      emit(KeePassMoveSuccess());
    } catch (e) {
      logger.e(e);
      emit(KeePassError(tr("exception.unknown")));
    }
  }

  Future<void> _onMoveGroup(MoveGroup event, Emitter<KeePassState> emit) async {
    try {
      emit(KeePassLoading());

      final result = await _kdbxIsolate.send<KdbxActionResult>(
        MoveGroupCmd(
          groupUuid: event.groupUuid,
          fromGroupUuid: event.fromGroupUuid,
          toGroupUuid: event.toGroupUuid,
        ),
      );
      _currentRoot = result.root.rootGroup;

      await _saveBytes(result.savedBytes);

      emit(KeePassRootGroup(_currentRoot!));
      emit(KeePassMoveSuccess());
    } catch (e) {
      logger.e(e);
      emit(KeePassError(tr("exception.unknown")));
    }
  }

  Future<void> _saveBytes(dynamic bytes) async {
    String? uri = preferences?.getString('kdbx_uri');
    if (uri != null) {
      await ContentResolver.writeContent(uri, bytes);
    } else {
      throw Exception('No URI saved');
    }
  }
}
