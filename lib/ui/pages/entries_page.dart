import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:keepassux/ui/bloc/entries/keepass_bloc.dart';
import 'package:keepassux/ui/bloc/entries/keepass_events.dart';
import 'package:keepassux/ui/bloc/entries/keepass_states.dart';
import 'package:keepassux/ui/pages/group_entries_page.dart';
import 'package:keepassux/ui/pages/start_page.dart';
import 'package:keepassux/ui/pages/trash_page.dart';
import 'package:keepassux/ui/services/alert_service.dart';
import 'package:keepassux/ui/services/biometric_service.dart';
import 'package:keepassux/ui/widgets/animated_entry_list.dart';
import 'package:keepassux/ui/widgets/root_app_bar.dart';
import 'package:keepassux/ui/widgets/custom_bottom_navigation_bar.dart';
import 'package:keepassux/ui/model/alert_item.dart';
import 'package:keepassux/ui/widgets/alert_stack.dart';
import 'package:keepassux/ui/widgets/fade_in_item.dart';
import 'package:keepassux/ui/widgets/loading_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/db_group.dart';

class EntriesPage extends StatefulWidget {
  const EntriesPage({this.uuidGroup, super.key});

  final String? uuidGroup;

  @override
  State<EntriesPage> createState() => _EntriesPageState();
}

class _EntriesPageState extends State<EntriesPage> {
  final AlertService _alertService = AlertService();
  final BiometricService _biometricService = BiometricService();

  DbGroup? group;
  DbGroup? _rootGroup;
  DbGroup? _trashGroup;
  List<AlertItem> _alerts = [];
  bool _hasBiometrics = false;
  bool _biometricLoginEnabled = false;
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _initStateAsync();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KeePassBloc>().add(GetRootGroup());
    });
  }

  Future<void> _initStateAsync() async {
    final prefs = await SharedPreferences.getInstance();
    _hasBiometrics = await _biometricService.canAuthenticate();
    _biometricLoginEnabled = prefs.getBool('biometric_login_enabled') ?? false;
  }

  Future<void> _loadAlerts(DbGroup? rootGroup) async {
    await _initFuture;
    final alerts = await _alertService.getAlerts(
      hasBiometrics: _hasBiometrics,
      biometricLoginEnabled: _biometricLoginEnabled,
      rootGroup: rootGroup,
    );
    setState(() => _alerts = alerts);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<KeePassBloc, KeePassState>(
      listener: (context, state) {
        if (state is KeePassRootGroup) {
          if (widget.uuidGroup == null) {
            setState(() {
              _rootGroup = state.rootGroup;
              group = state.rootGroup;
              _trashGroup = state.rootGroup?.groups.firstWhereOrNull(
                (g) => g.isRecycleBin,
              );
            });
          } else {
            List<DbGroup> allGroups = state.rootGroup?.getAllGroups() ?? [];
            setState(() {
              _rootGroup = state.rootGroup;
              group = allGroups.firstWhereOrNull(
                (g) => g.uuid == widget.uuidGroup,
              );
              _trashGroup = state.rootGroup?.groups.firstWhereOrNull(
                (g) => g.isRecycleBin,
              );
            });
          }
          _loadAlerts(state.rootGroup);
        }
        if (state is KeePassError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      builder: (context, state) {
        return Stack(
          fit: StackFit.expand,
          children: [
            _page(),
            LoadingOverlay(isLoading: state is KeePassLoading),
          ],
        );
      },
    );
  }

  Widget _page() {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(116),
        child: Container(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.only(
              top: 52,
              bottom: 6,
              left: 24,
              right: 24,
            ),
            child: RootAppBar(
              isExit: widget.uuidGroup == null,
              title: tr("entries_page.title"),
              onTapExit: () {
                if (widget.uuidGroup != null) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => StartPage()),
                    (Route<dynamic> route) => false,
                  );
                }
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        uuidGroup: widget.uuidGroup,
        selectedIndex: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: FadeInItem(
                      child: _alerts.isEmpty
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: AlertStack(
                                alerts: _alerts,
                                onDismiss: (alertId) async {
                                  await _alertService.dismissAlert(alertId);
                                  setState(() {
                                    _alerts = _alerts
                                        .where((a) => a.id != alertId)
                                        .toList();
                                  });
                                },
                              ),
                            ),
                    ),
                  ),
                  AnimatedEntryList(
                    group: group,
                    rootGroup: _rootGroup,
                    trashGroup: _trashGroup,
                    onGroupTap: (g) {
                      if (g.isRecycleBin) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TrashPage(),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GroupEntriesPage(
                              uuidGroup: g.uuid,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
