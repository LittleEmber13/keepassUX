import 'package:content_resolver/content_resolver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_autofill_service/flutter_autofill_service.dart';

import '../ui/model/db_entry.dart';
import '../ui/model/db_root.dart';
import '../ui/model/kdbx_action_result.dart';
import '../ui/services/keyboard_fill_service.dart';
import '../ui/theme/theme.dart';
import '../ui/utils/kdbx_command.dart';
import '../ui/utils/kdbx_isolate.dart';
import '../ui/widgets/kdbx_icon_widget.dart';
import 'autofill_matcher.dart';

const _channel = MethodChannel('com.example.keepassux/autofill');

class AutofillFillPage extends StatefulWidget {
  const AutofillFillPage({
    super.key,
    required this.root,
    required this.isolate,
    required this.kdbxUri,
    this.metadata,
    this.appPackage,
  });

  final DbRoot root;
  final KdbxIsolate isolate;
  final String kdbxUri;
  final AutofillMetadata? metadata;

  final String? appPackage;

  @override
  State<AutofillFillPage> createState() => _AutofillFillPageState();
}

class _AutofillFillPageState extends State<AutofillFillPage> {
  final TextEditingController _searchController = TextEditingController();

  late final List<DbEntry> _all = AutofillMatcher.allEntries(
    widget.root.rootGroup,
  );
  late final List<DbEntry> _matches = AutofillMatcher.match(
    _all,
    widget.metadata,
  );
  late final Set<String> _matchUuids = _matches.map((e) => e.uuid).toSet();

  String _query = '';
  bool _busy = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String get _sourceLabel {
    final domains = widget.metadata?.webDomains
        .map((d) => d.domain)
        .where((d) => d.isNotEmpty);
    if (domains != null && domains.isNotEmpty) return domains.first;
    final packages = widget.metadata?.packageNames.where((p) => p != 'android');
    if (packages != null && packages.isNotEmpty) return packages.first;
    return '';
  }

  List<DbEntry> get _visibleEntries {
    if (_query.isEmpty) {
      return _matches;
    }
    final q = _query.toLowerCase();
    return _all
        .where(
          (e) =>
              e.label.toLowerCase().contains(q) ||
              e.userName.toLowerCase().contains(q) ||
              e.url.toLowerCase().contains(q),
        )
        .toList(growable: false);
  }

  Future<void> _onPick(DbEntry entry) async {
    if (_busy) return;
    final pkg = widget.appPackage;
    final alreadyAssociated = _matchUuids.contains(entry.uuid);

    if (pkg != null && !alreadyAssociated) {
      final choice = await _confirmAssociate(entry);
      if (choice == null) return; // dismissed
      if (choice) {
        setState(() => _busy = true);
        await _associate(entry, pkg);
      }
    }
    await _fill(entry);
  }

  Future<bool?> _confirmAssociate(DbEntry entry) {
    final label = entry.label.isNotEmpty ? entry.label : '(sin título)';
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Recordar para esta app'),
        content: Text(
          '¿Asociar "$label" con $_sourceLabel para que aparezca automáticamente la próxima vez?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Solo rellenar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Asociar y rellenar'),
          ),
        ],
      ),
    );
  }

  Future<void> _associate(DbEntry entry, String pkg) async {
    try {
      final result = await widget.isolate.send<KdbxActionResult>(
        AssociateAppCmd(
          entryUuid: entry.uuid,
          association: 'androidapp://$pkg',
        ),
      );
      await ContentResolver.writeContent(widget.kdbxUri, result.savedBytes);
    } catch (_) {
    }
  }

  Future<void> _fill(DbEntry entry) async {
    String status = 'keyboard';
    try {
      status = await _channel.invokeMethod<String>('fillDataset', {
            'label': entry.label,
            'username': entry.userName,
            'password': entry.password,
          }) ??
          'keyboard';
    } catch (e) {
      debugPrint('Native fillDataset failed: $e');
    }

    if (status == 'dataset') return; // filled; activity already finished natively.
    if (mounted) await _offerKeyboardFallback(entry);
  }

  Future<void> _offerKeyboardFallback(DbEntry entry) async {
    final keyboard = KeyboardFillService();
    await keyboard.setEntry(
      label: entry.label,
      username: entry.userName,
      password: entry.password,
    );
    final enabled = await keyboard.isEnabled();
    if (!mounted) return;

    final label = entry.label.isNotEmpty ? entry.label : '(sin título)';
    final where = _sourceLabel.isNotEmpty ? _sourceLabel : 'esta app';
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('No se puede autorrellenar aquí'),
        content: Text(
          enabled
              ? 'El formulario de $where no admite el autocompletado directo '
                  '(es habitual en apps hechas con Jetpack Compose).\n\n'
                  'Cambia al teclado de KeepassUX y pulsa Usuario o Contraseña para '
                  'escribir los datos de "$label".'
              : 'El formulario de $where no admite el autocompletado directo '
                  '(es habitual en apps hechas con Jetpack Compose).\n\n'
                  'Para rellenarlo necesitas activar una vez el teclado de KeepassUX. '
                  'Después podrás cambiar a él y pulsar Usuario o Contraseña.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
          if (!enabled)
            TextButton(
              onPressed: () async {
                await keyboard.openSettings();
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Activar teclado'),
            ),
          if (enabled)
            TextButton(
              onPressed: () async {
                await keyboard.showPicker();
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Cambiar teclado'),
            ),
        ],
      ),
    );
    if (mounted) SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final entries = _visibleEntries;
    final showingMatches = _query.isEmpty && _matches.isNotEmpty;
    final noAssociations = _query.isEmpty && _matches.isEmpty;

    final String header;
    if (showingMatches) {
      header = 'Coincidencias';
    } else if (noAssociations) {
      header = 'Sin coincidencias para esta app';
    } else {
      header = 'Resultados';
    }

    final colors = context.appColors;

    return Scaffold(
      appBar: AppBar(title: const Text('Rellenar contraseña')),
      body: Stack(
        children: [
          Column(
            children: [
              if (_sourceLabel.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colors.infoCardBackground,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(8)),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Text(
                      'Para: $_sourceLabel',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Buscar entrada',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    header,
                    style: TextStyle(color: colors.secondaryText, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: entries.isEmpty
                    ? _EmptyState(noAssociations: noAssociations)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: entries.length,
                        itemBuilder: (context, i) => _EntryCard(
                          entry: entries[i],
                          onTap: () => _onPick(entries[i]),
                        ),
                      ),
              ),
            ],
          ),
          if (_busy)
            Container(
              color: Theme.of(context)
                  .colorScheme
                  .scrim
                  .withValues(alpha: 0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry, required this.onTap});

  final DbEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final subtitle = entry.userName.isNotEmpty ? entry.userName : entry.url;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: cardDecoration(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                KDBXIconWidget(
                  icon: entry.icon,
                  customIconData: entry.customIconData,
                  size: 24,
                  color: Colors.lightBlueAccent,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.label.isNotEmpty ? entry.label : '(sin título)'),
                      if (subtitle.isNotEmpty)
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.appColors.secondaryText,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.noAssociations});

  final bool noAssociations;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    if (!noAssociations) {
      return const Center(child: Text('Sin resultados'));
    }
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 48, color: colors.secondaryText),
          const SizedBox(height: 16),
          Text(
            'Ninguna entrada coincide con esta app.\n'
            'Búscala arriba para asociarla.',
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.secondaryText),
          ),
        ],
      ),
    );
  }
}
