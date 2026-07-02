import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:keepassux/ui/services/autofill_settings_service.dart';
import 'package:keepassux/ui/services/keyboard_fill_service.dart';
import 'package:keepassux/ui/theme/theme.dart';
import 'package:keepassux/ui/widgets/custom_app_scroll.dart';
import 'package:keepassux/ui/widgets/group_app_bar.dart';

class AutofillSettingsPage extends StatefulWidget {
  const AutofillSettingsPage({super.key});

  @override
  State<AutofillSettingsPage> createState() => _AutofillSettingsPageState();
}

class _AutofillSettingsPageState extends State<AutofillSettingsPage> {
  final AutofillSettingsService _autofillService = AutofillSettingsService();
  final KeyboardFillService _keyboardService = KeyboardFillService();

  bool _autofillSupported = false;
  bool _autofillEnabled = false;
  final bool _keyboardSupported = Platform.isAndroid;
  bool _keyboardEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final autofillSupported = await _autofillService.isSupported;
    final autofillEnabled = autofillSupported ? await _autofillService.isEnabled : false;
    final keyboardEnabled = _keyboardSupported ? await _keyboardService.isEnabled() : false;
    if (!mounted) return;
    setState(() {
      _autofillSupported = autofillSupported;
      _autofillEnabled = autofillEnabled;
      _keyboardEnabled = keyboardEnabled;
    });
  }

  Future<void> _onAutofillToggle(bool value) async {
    if (value) {
      await _autofillService.requestEnable();
    } else {
      await _autofillService.disable();
    }
    final enabled = await _autofillService.isEnabled;
    if (mounted) setState(() => _autofillEnabled = enabled);
  }

  Future<void> _onKeyboardTap() async {
    await _keyboardService.openSettings();
    final enabled = await _keyboardService.isEnabled();
    if (mounted) setState(() => _keyboardEnabled = enabled);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 24, right: 24),
              child: GroupAppBar(
                onTapExit: () => Navigator.pop(context),
                title: tr("autofill_settings_page.title"),
              ),
            ),
            CustomAppScroll(
              children: [
                Text(
                  tr("autofill_settings_page.intro"),
                  style: TextStyle(color: context.appColors.secondaryText),
                ),
                const SizedBox(height: 16),
                if (_autofillSupported) ...[
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SwitchListTile(
                          title: Text(tr("autofill_settings_page.autofill_toggle_title")),
                          value: _autofillEnabled,
                          onChanged: _onAutofillToggle,
                          contentPadding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tr("autofill_settings_page.autofill_toggle_description"),
                          style: TextStyle(color: context.appColors.secondaryText),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (_keyboardSupported)
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text(tr("autofill_settings_page.keyboard_toggle_title")),
                          subtitle: Text(
                            _keyboardEnabled
                                ? tr("autofill_settings_page.keyboard_status_enabled")
                                : tr("autofill_settings_page.keyboard_status_disabled"),
                          ),
                          trailing: Icon(
                            _keyboardEnabled ? Icons.check_circle : Icons.chevron_right,
                            color: _keyboardEnabled ? Colors.green : null,
                          ),
                          onTap: _onKeyboardTap,
                          contentPadding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tr("autofill_settings_page.keyboard_toggle_description"),
                          style: TextStyle(color: context.appColors.secondaryText),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: cardDecoration(context),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}
