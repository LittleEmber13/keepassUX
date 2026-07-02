import 'dart:async';
import 'dart:isolate';
import 'package:collection/collection.dart';
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
        entry.icon.set(KdbxIcon.values[command.icon]);
        if (command.customIconData != null) {
          entry.customIcon = KdbxCustomIcon(
            uuid: KdbxUuid.random(),
            data: command.customIconData!,
          );
        }
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
        entry.icon.set(KdbxIcon.values[command.icon]);
        if (command.customIconData != null) {
          entry.customIcon = KdbxCustomIcon(
            uuid: KdbxUuid.random(),
            data: command.customIconData!,
          );
        } else {
          entry.customIcon = null;
        }
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
      } else if (command is MoveEntryCmd) {
        if (kdbx == null) throw Exception('No database loaded');
        final entry = _findEntry(kdbx!, command.entryUuid);
        final toGroup = _findGroup(kdbx!, command.toGroupUuid);
        kdbx!.move(entry, toGroup);
        final bytes = await kdbx!.save();
        replyPort.send(
          KdbxActionResult(root: _serializeRoot(kdbx!), savedBytes: bytes),
        );
      } else if (command is MoveGroupCmd) {
        if (kdbx == null) throw Exception('No database loaded');
        final groupToMove = _findGroup(kdbx!, command.groupUuid);
        final toParent = _findGroup(kdbx!, command.toGroupUuid);
        final descendants = groupToMove.getAllGroups().map((g) => g.uuid.uuid).toList();
        if (descendants.contains(toParent.uuid.uuid)) {
          throw Exception('Cannot move group into its own descendant');
        }
        kdbx!.move(groupToMove, toParent);
        final bytes = await kdbx!.save();
        replyPort.send(
          KdbxActionResult(root: _serializeRoot(kdbx!), savedBytes: bytes),
        );
      } else if (command is UpdateGroupCmd) {
        if (kdbx == null) throw Exception('No database loaded');
        final group = _findGroup(kdbx!, command.groupUuid);
        group.name.set(command.name);
        final bytes = await kdbx!.save();
        replyPort.send(
          KdbxActionResult(root: _serializeRoot(kdbx!), savedBytes: bytes),
        );
      } else if (command is DeleteEntryCmd) {
        if (kdbx == null) throw Exception('No database loaded');
        final entry = _findEntry(kdbx!, command.entryUuid);
        kdbx!.deleteEntry(entry);
        final bytes = await kdbx!.save();
        replyPort.send(
          KdbxActionResult(root: _serializeRoot(kdbx!), savedBytes: bytes),
        );
      } else if (command is DeleteGroupCmd) {
        if (kdbx == null) throw Exception('No database loaded');
        final group = _findGroup(kdbx!, command.groupUuid);
        kdbx!.deleteGroup(group);
        final bytes = await kdbx!.save();
        replyPort.send(
          KdbxActionResult(root: _serializeRoot(kdbx!), savedBytes: bytes),
        );
      } else if (command is DeleteEntryPermanentlyCmd) {
        if (kdbx == null) throw Exception('No database loaded');
        final entry = _findEntry(kdbx!, command.entryUuid);
        kdbx!.deletePermanently(entry);
        final bytes = await kdbx!.save();
        replyPort.send(
          KdbxActionResult(root: _serializeRoot(kdbx!), savedBytes: bytes),
        );
      } else if (command is DeleteGroupPermanentlyCmd) {
        if (kdbx == null) throw Exception('No database loaded');
        final group = _findGroup(kdbx!, command.groupUuid);
        kdbx!.deletePermanently(group);
        final bytes = await kdbx!.save();
        replyPort.send(
          KdbxActionResult(root: _serializeRoot(kdbx!), savedBytes: bytes),
        );
      } else if (command is AssociateAppCmd) {
        if (kdbx == null) throw Exception('No database loaded');
        final entry = _findEntry(kdbx!, command.entryUuid);
        _addAssociation(entry, command.association);
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
      } else if (command is ChangeMasterPasswordCmd) {
        if (kdbx == null) throw Exception('No database loaded');
        final oldCredentials = Credentials(
          ProtectedValue.fromString(command.oldPassword),
        );
        final matches = const ListEquality<int>().equals(
          oldCredentials.getHash(),
          kdbx!.credentials.getHash(),
        );
        if (!matches) {
          throw Exception('Invalid current password');
        }
        kdbx!.credentials = Credentials(
          ProtectedValue.fromString(command.newPassword),
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
  final recycleBinUuid = kdbx.recycleBin?.uuid.uuid;
  return DbRoot(rootGroup: _serializeGroup(kdbx.body.rootGroup, recycleBinUuid));
}

DbGroup _serializeGroup(KdbxGroup group, String? recycleBinUuid) {
  return DbGroup(
    uuid: group.uuid.uuid,
    name: group.name.get() ?? '',
    icon: group.icon.get()?.index ?? 0,
    customIconData: group.customIcon?.data,
    groups: group.groups.map((g) => _serializeGroup(g, recycleBinUuid)).toList(),
    entries: group.entries.map(_serializeEntry).toList(),
    isRecycleBin: group.uuid.uuid == recycleBinUuid,
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
    additionalUrls: _readAdditionalUrls(entry),
  );
}

List<String> _readAdditionalUrls(KdbxEntry entry) {
  final urls = <String>[];
  for (final e in entry.stringEntries) {
    if (e.key.key.startsWith('KP2A_URL')) {
      final value = e.value?.getText();
      if (value != null && value.isNotEmpty) urls.add(value);
    }
  }
  return urls;
}

void _addAssociation(KdbxEntry entry, String association) {
  final mainUrl = entry.getString(KdbxKeyCommon.URL)?.getText() ?? '';
  final existing = <String>[
    mainUrl,
    ..._readAdditionalUrls(entry),
  ].map((u) => u.toLowerCase()).toList();
  if (existing.contains(association.toLowerCase())) return;

  if (mainUrl.isEmpty) {
    entry.setString(KdbxKeyCommon.URL, PlainValue(association));
    return;
  }
  var n = 1;
  while (entry.getString(KdbxKey('KP2A_URL_$n')) != null) {
    n++;
  }
  entry.setString(KdbxKey('KP2A_URL_$n'), PlainValue(association));
}