import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:keepassux/ui/pages/start_page.dart';
import 'package:keepassux/ui/services/biometric_service.dart';
import 'package:keepassux/ui/theme/theme.dart';
import 'package:keepassux/ui/theme/theme_controller.dart';
import 'package:keepassux/ui/widgets/custom_bottom_navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/root_app_bar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final BiometricService _biometricService = BiometricService();

  String selectedLanguage = 'Español';
  bool biometricLoginEnabled = false;
  bool _hasBiometrics = false;
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _initStateAsync();
  }

  Future<void> _initStateAsync() async {
    _prefs = await SharedPreferences.getInstance();
    final currentLocale = context.locale;
    _hasBiometrics = await _biometricService.canAuthenticate();
    final savedEnabled = _prefs?.getBool('biometric_login_enabled') ?? false;
    setState(() {
      if (currentLocale.languageCode == 'es') {
        selectedLanguage = 'Español';
      } else if (currentLocale.languageCode == 'en') {
        selectedLanguage = 'Inglés';
      }
      biometricLoginEnabled = savedEnabled;
    });
  }

  Future<void> _onBiometricToggle(bool value) async {
    await _prefs?.setBool('biometric_login_enabled', value);
    setState(() => biometricLoginEnabled = value);
  }

  Future<void> _onDarkThemeToggle(bool value) async {
    await themeController.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      bottomNavigationBar: CustomBottomNavigationBar(selectedIndex: 3),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RootAppBar(
                isExit: true,
                onTapExit: () {
                  // TODO unload database
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => StartPage()),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
              const SizedBox(height: 24),
              // Container(
              //   decoration: BoxDecoration(
              //     color: Colors.white,
              //     borderRadius: BorderRadius.circular(8),
              //     boxShadow: [
              //       BoxShadow(
              //         color: Colors.black.withOpacity(0.05),
              //         blurRadius: 5,
              //         spreadRadius: 1,
              //         offset: Offset(1, 2),
              //       ),
              //     ],
              //   ),
              //   child: ListTile(
              //     leading: const Icon(Icons.star_border),
              //     title: const Text('FAQ'),
              //     onTap: () {},
              //   ),
              // ),
              // const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      spreadRadius: 1,
                      offset: Offset(1, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr("settings_page.language"),
                        style: TextStyle(color: context.appColors.secondaryText),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: selectedLanguage,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Español',
                            child: Text('Español'),
                          ),
                          DropdownMenuItem(
                            value: 'Inglés',
                            child: Text('Inglés'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => selectedLanguage = value!);
                          if (value == 'Español') {
                            context.setLocale(const Locale('es'));
                          } else if (value == 'Inglés') {
                            context.setLocale(const Locale('en'));
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      ValueListenableBuilder<ThemeMode>(
                        valueListenable: themeController,
                        builder: (context, mode, _) {
                          return SwitchListTile(
                            title: Text(tr("settings_page.dark_theme")),
                            value: mode == ThemeMode.dark,
                            onChanged: _onDarkThemeToggle,
                            contentPadding: EdgeInsets.zero,
                          );
                        },
                      ),
                      if (_hasBiometrics) ...[
                        const SizedBox(height: 12),
                        SwitchListTile(
                          title: Text(tr("settings_page.biometric_login")),
                          value: biometricLoginEnabled,
                          onChanged: _onBiometricToggle,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'v0.0.0',
                  style: TextStyle(color: context.appColors.secondaryText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
