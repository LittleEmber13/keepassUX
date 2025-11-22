import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keepassux/ui/bloc/entries/keepass_bloc.dart';
import 'package:keepassux/ui/bloc/entries/keepass_states.dart';
import 'package:keepassux/ui/pages/entries_page.dart';
import 'package:keepassux/ui/pages/start_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc/entries/keepass_events.dart';

class CreateDatabasePage extends StatefulWidget {
  const CreateDatabasePage({super.key});

  @override
  State<CreateDatabasePage> createState() => _CreateDatabasePageState();
}

class _CreateDatabasePageState extends State<CreateDatabasePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool obscurePassword = false;

  SharedPreferences? preferences;

  @override
  void initState() {
    SharedPreferences.getInstance().then((preferences) {
      this.preferences = preferences;
    });
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<KeePassBloc, KeePassState>(
      listener: (context, state) {
        if (state is KeePassCreated) {
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
            child: Text("Crear base de datos", style: TextStyle(fontSize: 32)),
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
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFF3F5F9),
                        labelText: "Nombre del archivo",
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
                    SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFF3F5F9),
                        labelText: "Contraseña",
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
                    if (preferences == null) {
                      return;
                    }
                    final rawPath = await FilePicker.platform.saveFile(
                      dialogTitle: 'Guardar como',
                      fileName: "${nameController.text}.kdbx",
                      type: FileType.custom,
                      allowedExtensions: ['kdbx'],
                      bytes: Uint8List.fromList([0]),
                    );
                    if (rawPath == null) {
                      return;
                    }
                    String documentId = rawPath.replaceFirst('/document/', '');
                    String encoded = Uri.encodeComponent(documentId);
                    String safUri =
                        "content://com.android.externalstorage.documents/document/$encoded";
                    await preferences!.setString('kdbx_uri', safUri);
                    context.read<KeePassBloc>().add(
                      CreateDatabase(
                        uri: safUri,
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
                              child: Icon(Icons.call_received),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Create database",
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
                        builder: (context) => const StartPage(),
                      ),
                    );
                  },
                  child: InkWell(child: Text("Abrir base de datos")),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
