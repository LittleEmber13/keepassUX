import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:keepassux/ui/bloc/entries/keepass_bloc.dart';
import 'package:keepassux/ui/bloc/entries/keepass_events.dart';
import 'package:keepassux/ui/bloc/entries/keepass_states.dart';
import 'package:keepassux/ui/utils.dart';
import 'package:keepassux/ui/widgets/custom_app_bar.dart';
import 'package:keepassux/ui/widgets/custom_app_scroll.dart';

class AddEntryPage extends StatefulWidget {
  const AddEntryPage({this.uuidGroup, super.key});

  final String? uuidGroup;

  @override
  State<AddEntryPage> createState() => _AddEntryPageState();
}

class _AddEntryPageState extends State<AddEntryPage> {
  int passwordLength = 14;
  bool includeUppercase = true;
  bool includeLowercase = true;
  bool includeNumbers = true;
  bool includeSpecial = false;

  TextEditingController titleController = TextEditingController();
  TextEditingController userController = TextEditingController();
  TextEditingController urlController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool obscurePassword = false;

  @override
  void dispose() {
    titleController.dispose();
    urlController.dispose();
    urlController.dispose();
    notesController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<KeePassBloc, KeePassState>(
      listener: (context, state) {
        if (state is KeePassAddEntrySuccess) {
          Navigator.pop(context);
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
            child: CustomAppBar(
              isExit: false,
              onTapExit: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          CustomAppScroll(
            children: [
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Información"),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: "Título",
                      controller: titleController,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: "Usuario",
                      controller: userController,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(label: "URL", controller: urlController),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: "Notas",
                      controller: notesController,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Contraseña"),
                    const SizedBox(height: 16),
                    _buildPasswordField(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text("Security"),
                        const SizedBox(width: 8),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: 0.8,
                            color: Colors.greenAccent,
                            backgroundColor: Colors.grey[300],
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          passwordLength.toInt().toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: Slider(
                            value: passwordLength.toDouble(),
                            min: 4,
                            max: 32,
                            activeColor: Colors.teal,
                            onChanged: (v) {
                              setState(() => passwordLength = v.toInt());
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildToggle("A-Z", includeUppercase, (v) {
                      setState(() => includeUppercase = v);
                    }),
                    _buildToggle("a-z", includeLowercase, (v) {
                      setState(() => includeLowercase = v);
                    }),
                    _buildToggle("0-9", includeNumbers, (v) {
                      setState(() => includeNumbers = v);
                    }),
                    _buildToggle("Special characters", includeSpecial, (v) {
                      setState(() => includeSpecial = v);
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    context.read<KeePassBloc>().add(
                      AddEntry(
                        uuidGroup: widget.uuidGroup,
                        title: titleController.text,
                        userName: userController.text,
                        url: urlController.text,
                        notes: notesController.text,
                        password: passwordController.text,
                      ),
                    );
                  },
                  child: const Text("Guardar", style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: child,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _buildPasswordField() {
    return Row(
      children: [
        InkWell(
          onTap: () {
            passwordController.text = generatePassword(
              upperCase: includeUppercase,
              lowerCase: includeLowercase,
              numeric: includeNumbers,
              special: includeSpecial,
              length: passwordLength,
            );
          },
          child: Icon(FeatherIcons.refreshCcw),
        ),
        SizedBox(width: 16),
        Expanded(
          child: TextField(
            controller: passwordController,
            obscureText: obscurePassword,
            decoration: InputDecoration(
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
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggle(String label, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(label),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.teal,
      contentPadding: EdgeInsets.zero,
    );
  }
}
