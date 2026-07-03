import 'package:content_resolver/content_resolver.dart';
import 'package:easy_localization/easy_localization.dart';
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
import '../ui/widgets/loading_overlay.dart';
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
    final label = entry.label.isNotEmpty ? entry.label : tr('autofill.untitled_entry');
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr('autofill.confirm_associate_title')),
        content: Text(
          tr(
            'autofill.confirm_associate_message',
            namedArgs: {'label': label, 'source': _sourceLabel},
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(tr('autofill.fill_only')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(tr('autofill.associate_and_fill')),
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

    final label = entry.label.isNotEmpty ? entry.label : tr('autofill.untitled_entry');
    final where = _sourceLabel.isNotEmpty ? _sourceLabel : tr('autofill.this_app_fallback');
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr('autofill.cannot_autofill_title')),
        content: Text(
          enabled
              ? tr(
                  'autofill.cannot_autofill_message_keyboard_enabled',
                  namedArgs: {'where': where, 'label': label},
                )
              : tr(
                  'autofill.cannot_autofill_message_keyboard_disabled',
                  namedArgs: {'where': where},
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(tr('autofill.close')),
          ),
          if (!enabled)
            TextButton(
              onPressed: () async {
                await keyboard.openSettings();
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(tr('autofill.enable_keyboard')),
            ),
          if (enabled)
            TextButton(
              onPressed: () async {
                await keyboard.showPicker();
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(tr('autofill.switch_keyboard')),
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
      header = tr('autofill.matches_header');
    } else if (noAssociations) {
      header = tr('autofill.no_matches_header');
    } else {
      header = tr('autofill.results_header');
    }

    final colors = context.appColors;

    return Scaffold(
      appBar: AppBar(title: Text(tr('autofill.fill_password_title'))),
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
                      tr('autofill.for_source', namedArgs: {'source': _sourceLabel}),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: tr('autofill.search_entry_hint'),
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
          LoadingOverlay(isLoading: _busy),
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
                      Text(entry.label.isNotEmpty ? entry.label : tr('autofill.untitled_entry')),
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
      return Center(child: Text(tr('autofill.no_results')));
    }
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 48, color: colors.secondaryText),
          const SizedBox(height: 16),
          Text(
            tr('autofill.empty_no_matches'),
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.secondaryText),
          ),
        ],
      ),
    );
  }
}
