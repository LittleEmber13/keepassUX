import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:keepassux/ui/bloc/entries/keepass_bloc.dart';
import 'package:keepassux/ui/bloc/entries/keepass_events.dart';
import 'package:keepassux/ui/bloc/entries/keepass_states.dart';
import 'package:keepassux/ui/utils.dart';
import 'package:keepassux/ui/widgets/root_app_bar.dart';
import 'package:keepassux/ui/widgets/custom_app_scroll.dart';
import 'package:zxcvbnm/languages/en.dart' as en;
import 'package:zxcvbnm/languages/es_es.dart' as es;
import 'package:zxcvbnm/zxcvbnm.dart';

class AddEntryPage extends StatefulWidget {
  const AddEntryPage({this.uuidGroup, super.key});

  final String? uuidGroup;

  @override
  State<AddEntryPage> createState() => _AddEntryPageState();
}

class _AddEntryPageState extends State<AddEntryPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Zxcvbnm _zxcvbnm = Zxcvbnm(
    dictionaries: <Dictionaries>{
      ...en.dictionaries,
      ...es.dictionaries,
    },
  );

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
  void initState() {
    super.initState();
    passwordController.addListener(() {
      setState(() {});
    });
  }

  Color _getStrengthColor(int score) {
    switch (score) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.yellow[700]!;
      case 3:
        return Colors.lightGreen;
      case 4:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStrengthLabel(int score) {
    switch (score) {
      case 0:
        return 'Muy débil';
      case 1:
        return 'Débil';
      case 2:
        return 'Regular';
      case 3:
        return 'Fuerte';
      case 4:
        return 'Muy fuerte';
      default:
        return '';
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    userController.dispose();
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
              isExit: false,
              onTapExit: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
        key: _formKey,
        child: Column(
          children: [
            CustomAppScroll(
              children: [
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tr("add_entry.information")),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: titleController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return tr("form_error.required");
                          }
                          return null;
                        },
                        maxLines: 1,
                        decoration: InputDecoration(
                          labelText: tr("add_entry.title"),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: userController,
                        maxLines: 1,
                        decoration: InputDecoration(
                          labelText: tr("add_entry.user"),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: urlController,
                        maxLines: 1,
                        decoration: InputDecoration(
                          labelText: tr("add_entry.url"),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: notesController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: tr("add_entry.notes"),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tr("add_entry.password")),
                      const SizedBox(height: 16),
                      _buildPasswordField(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text(tr("add_entry.security")),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Builder(
                              builder: (context) {
                                final result = _zxcvbnm(passwordController.text);
                                return LinearProgressIndicator(
                                  value: (result.score + 1) / 5,
                                  color: _getStrengthColor(result.score),
                                  backgroundColor: Colors.grey[300],
                                  minHeight: 6,
                                  borderRadius: BorderRadius.circular(10),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Builder(
                            builder: (context) {
                              final result = _zxcvbnm(passwordController.text);
                              return Text(
                                _getStrengthLabel(result.score),
                                style: const TextStyle(fontSize: 12),
                              );
                            },
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
                      _buildToggle(
                        tr("add_entry.special_characters"),
                        includeSpecial,
                        (v) {
                          setState(() => includeSpecial = v);
                        },
                      ),
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
                      if (_formKey.currentState!.validate()) {
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
                      }
                    },
                    child: Text(
                      tr("add_entry.save"),
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ],
        ),
      ),
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
          child: TextFormField(
            controller: passwordController,
            obscureText: obscurePassword,
            decoration: InputDecoration(
              labelText: tr("add_entry.password_hint"),
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
