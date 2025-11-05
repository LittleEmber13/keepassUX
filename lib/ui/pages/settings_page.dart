import 'package:flutter/material.dart';
import 'package:keepassux/ui/widgets/custom_bottom_navigation_bar.dart';

import '../widgets/custom_app_bar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String selectedLanguage = 'Español';
  bool autoTheme = false;
  bool darkTheme = false;
  bool biometricLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      bottomNavigationBar: CustomBottomNavigationBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppBar(
                onTapExit: () {
                  /// TODO
                },
              ),
              const SizedBox(height: 24),
              Container(
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
                child: ListTile(
                  leading: const Icon(Icons.star_border),
                  title: const Text('FAQ'),
                  onTap: () {},
                ),
              ),
              const SizedBox(height: 16),
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
                      const Text(
                        'Idioma',
                        style: TextStyle(color: Colors.grey),
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
                        },
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Automatic app theme'),
                        value: autoTheme,
                        onChanged: (val) => setState(() => autoTheme = val),
                      ),
                      SwitchListTile(
                        title: const Text('Dark theme'),
                        value: darkTheme,
                        onChanged: (val) => setState(() => darkTheme = val),
                      ),
                      SwitchListTile(
                        title: const Text('Login biometrico'),
                        value: biometricLogin,
                        onChanged:
                            (val) => setState(() => biometricLogin = val),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text('v0.0.0', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
