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
  static const _safChannel = MethodChannel('com.example.keepassux/saf');

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController passwordController = TextEditingController();
  TextEditingController folderController = TextEditingController();

  bool obscurePassword = false;

  SharedPreferences? preferences;

  Future<void> _takePersistablePermission(String uri) async {
    try {
      await _safChannel.invokeMethod('takePersistableUriPermission', {'uri': uri});
    } catch (_) {}
  }

  @override
  void initState() {
    SharedPreferences.getInstance().then((preferences) {
      this.preferences = preferences;
      final savedUri = preferences.getString('kdbx_uri') ?? '';
      folderController.text = savedUri;
      if (savedUri.isNotEmpty) {
        _takePersistablePermission(savedUri);
      }
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
            if (state is KeePassLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      },
    );
  }

  Widget _page() {
    return Scaffold(
      body: SafeArea(
        child: Column(
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
              child: Form(
                key: _formKey,
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
                              _takePersistablePermission(safUri);
                            }
                          }
                        },
                        child: Row(
                          children: [
                            Icon(Icons.folder_open),
                            SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: folderController,
                                enabled: false,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return tr("form_error.required");
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: tr("start_page.folder_hint"),
                                 ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: passwordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return tr("form_error.required");
                          }
                          return null;
                        },
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
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
                       ),
                      ),
                    ],
                  ),
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
                    if (_formKey.currentState!.validate()) {
                      try {
                        final uri = Uri.parse(folderController.text);
                        final bytes = await UriContent().from(uri);
                        context.read<KeePassBloc>().add(
                          LoadDatabase(
                            bytes: bytes,
                            password: passwordController.text,
                          ),
                        );
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(tr("start_page.open_database_error")),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      }
                    }
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
      ),
    );
  }
}
