import 'dart:async';
import 'dart:isolate';
import 'package:kdbx/kdbx.dart';

import '../error/kdbx_isolate_error.dart';
import 'kdbx_command.dart';
import '../model/db_entry.dart';
import '../model/db_group.dart';
import '../model/db_root.dart';
import '../model/kdbx_action_result.dart';

class KdbxIsolate {
  Isolate? _isolate;
  SendPort? _sendPort;
  final Completer<void> _initCompleter = Completer<void>();

  Future<void> init() async {
    final receivePort = ReceivePort();
    _isolate = await Isolate.spawn(kdbxIsolateEntryPoint, receivePort.sendPort);
    _sendPort = await receivePort.first as SendPort;
    _initCompleter.complete();
  }

  Future<T> send<T>(KdbxCommand command) async {
    await _initCompleter.future;
    final responsePort = ReceivePort();
    _sendPort!.send([command, responsePort.sendPort]);
    final result = await responsePort.first;
    if (result is KdbxIsolateError) {
      throw Exception(result.message);
    }
    return result as T;
  }

  void dispose() {
    _isolate?.kill();
    _isolate = null;
    _sendPort = null;
  }
}

void kdbxIsolateEntryPoint(SendPort mainSendPort) {
  final receivePort = ReceivePort();
  mainSendPort.send(receivePort.sendPort);

  KdbxFile? kdbx;

  receivePort.listen((dynamic message) async {
    final List<dynamic> parts = message;
    final KdbxCommand command = parts[0] as KdbxCommand;
    final SendPort replyPort = parts[1] as SendPort;

    try {
      if (command is LoadDatabaseCmd) {
        final credentials = Credentials(
          ProtectedValue.fromString(command.password),
        );
        kdbx = await KdbxFormat().read(command.bytes, credentials);
        replyPort.send(_serializeRoot(kdbx!));
      } else if (command is AddEntryCmd) {
        if (kdbx == null) throw Exception('No database loaded');
        final group = _findGroup(kdbx!, command.groupUuid);
        final entry = KdbxEntry.create(kdbx!, group);
        group.addEntry(entry);
        entry.setString(KdbxKeyCommon.TITLE, PlainValue(command.title));
        entry.setString(KdbxKeyCommon.USER_NAME, PlainValue(command.userName));
        entry.setString(KdbxKeyCommon.URL, PlainValue(command.url));
        entry.setString(KdbxKey('Notes'), PlainValue(command.notes));
        entry.setString(
          KdbxKeyCommon.PASSWORD,
          ProtectedValue.fromString(command.password),
        );
        final bytes = await kdbx!.save();
        replyPort.send(
          KdbxActionResult(root: _serializeRoot(kdbx!), savedBytes: bytes),
        );
      } else if (command is UpdateEntryCmd) {
        if (kdbx == null) throw Exception('No database loaded');
        final entry = _findEntry(kdbx!, command.entryUuid);
        entry.setString(KdbxKeyCommon.TITLE, PlainValue(command.title));
        entry.setString(KdbxKeyCommon.USER_NAME, PlainValue(command.userName));
        entry.setString(KdbxKeyCommon.URL, PlainValue(command.url));
        entry.setString(KdbxKey('Notes'), PlainValue(command.notes));
        entry.setString(
          KdbxKeyCommon.PASSWORD,
          ProtectedValue.fromString(command.password),
        );
        final bytes = await kdbx!.save();
        replyPort.send(
          KdbxActionResult(root: _serializeRoot(kdbx!), savedBytes: bytes),
        );
      } else if (command is AddGroupCmd) {
        if (kdbx == null) throw Exception('No database loaded');
        final parentGroup = _findGroup(kdbx!, command.parentUuid);
        final newGroup = KdbxGroup.create(
          ctx: kdbx!.ctx,
          parent: parentGroup,
          name: command.name,
        );
        parentGroup.addGroup(newGroup);
        final bytes = await kdbx!.save();
        replyPort.send(
          KdbxActionResult(root: _serializeRoot(kdbx!), savedBytes: bytes),
        );
      } else if (command is CreateDatabaseCmd) {
        kdbx = KdbxFormat().create(
          Credentials(ProtectedValue.fromString(command.password)),
          'KeepassUX',
        );
        final bytes = await kdbx!.save();
        replyPort.send(
          KdbxActionResult(root: _serializeRoot(kdbx!), savedBytes: bytes),
        );
      }
    } catch (e) {
      replyPort.send(KdbxIsolateError(e.toString()));
    }
  });
}

KdbxGroup _findGroup(KdbxFile kdbx, String uuid) {
  final allGroups = kdbx.body.rootGroup.getAllGroups();
  return allGroups.firstWhere(
    (g) => g.uuid.uuid == uuid,
    orElse: () => kdbx.body.rootGroup,
  );
}

KdbxEntry _findEntry(KdbxFile kdbx, String uuid) {
  final allGroups = kdbx.body.rootGroup.getAllGroups();
  for (final group in allGroups) {
    for (final entry in group.entries) {
      if (entry.uuid.uuid == uuid) return entry;
    }
  }
  for (final entry in kdbx.body.rootGroup.entries) {
    if (entry.uuid.uuid == uuid) return entry;
  }
  throw Exception('Entry not found: $uuid');
}

DbRoot _serializeRoot(KdbxFile kdbx) {
  return DbRoot(rootGroup: _serializeGroup(kdbx.body.rootGroup));
}

DbGroup _serializeGroup(KdbxGroup group) {
  return DbGroup(
    uuid: group.uuid.uuid,
    name: group.name.get() ?? '',
    icon: group.icon.get()?.index ?? 0,
    customIconData: group.customIcon?.data,
    groups: group.groups.map(_serializeGroup).toList(),
    entries: group.entries.map(_serializeEntry).toList(),
  );
}

DbEntry _serializeEntry(KdbxEntry entry) {
  return DbEntry(
    uuid: entry.uuid.uuid,
    label: entry.label ?? '',
    userName: entry.getString(KdbxKeyCommon.USER_NAME)?.getText() ?? '',
    password: entry.getString(KdbxKeyCommon.PASSWORD)?.getText() ?? '',
    url: entry.getString(KdbxKeyCommon.URL)?.getText() ?? '',
    notes: entry.getString(KdbxKey('Notes'))?.getText() ?? '',
    icon: entry.icon.get()?.index ?? 0,
    customIconData: entry.customIcon?.data,
  );
}