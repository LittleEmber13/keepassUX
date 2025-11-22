import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keepassux/ui/bloc/entries/keepass_bloc.dart';
import 'package:keepassux/ui/bloc/entries/keepass_states.dart';
import 'package:keepassux/ui/pages/create_database_page.dart';
import 'package:keepassux/ui/pages/entries_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uri_content/uri_content.dart';

import '../bloc/entries/keepass_events.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController folderController = TextEditingController();

  bool obscurePassword = false;

  SharedPreferences? preferences;

  @override
  void initState() {
    SharedPreferences.getInstance().then((preferences) {
      this.preferences = preferences;
      folderController.text = preferences.getString('kdbx_uri') ?? '';
    });
    super.initState();
  }

  @override
  void dispose() {
    folderController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<KeePassBloc, KeePassState>(
      listener: (context, state) {
        if (state is KeePassLoaded) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const EntriesPage()),
          );
        }
      },
      builder: (context, state) {
        if (state is KeePassLoading) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        } else {
          return _page();
        }
      },
    );
  }

  Widget _page() {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(),
          Center(
            child: Text(tr("start_page.title"), style: TextStyle(fontSize: 32)),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Container(color: Colors.black, height: 200),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
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
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () async {
                        if (preferences == null) {
                          return;
                        }

                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['kdbx'],
                          withData: false,
                        );

                        if (result != null && result.files.isNotEmpty) {
                          PlatformFile file = result.files.single;

                          String? safUri = file.identifier;

                          if (safUri != null) {
                            folderController.text = safUri;
                            await preferences!.setString('kdbx_uri', safUri);
                          }
                        }
                      },
                      child: Row(
                        children: [
                          Icon(Icons.folder_open),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: folderController,
                              enabled: false,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Color(0xFFF3F5F9),
                                labelText: tr("start_page.folder_hint"),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Color(0xFFD2D2D2),
                                    width: 1,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFF3F5F9),
                        labelText: tr("start_page.password_hint"),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword == true
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Color(0xFFD2D2D2),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Color(0xFFD2D2D2),
                            width: 1,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () async {
                    final uri = Uri.parse(folderController.text);
                    final bytes = await UriContent().from(uri);
                    context.read<KeePassBloc>().add(
                      LoadDatabase(
                        bytes: bytes,
                        password: passwordController.text,
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF374151),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(Icons.arrow_forward),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              tr("start_page.open_database"),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateDatabasePage(),
                      ),
                    );
                  },
                  child: InkWell(child: Text(tr("start_page.create_database"))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
