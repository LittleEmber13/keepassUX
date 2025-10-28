import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:keepassux/ui/widgets/custom_app_bar.dart';

class AddEntryPage extends StatefulWidget {
  const AddEntryPage({super.key});

  @override
  State<AddEntryPage> createState() => _AddEntryPageState();
}

class _AddEntryPageState extends State<AddEntryPage> {
  double passwordLength = 14;
  bool includeUppercase = true;
  bool includeLowercase = true;
  bool includeNumbers = true;
  bool includeSpecial = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomAppBar(),
                const SizedBox(height: 24),
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Información"),
                      const SizedBox(height: 16),
                      _buildTextField(label: "Título"),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: "Usuario",
                        initialValue: "Test@gmail.com",
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(label: "URL"),
                      const SizedBox(height: 16),
                      _buildTextField(label: "Notas", maxLines: 3),
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
                              value: passwordLength,
                              min: 4,
                              max: 32,
                              activeColor: Colors.teal,
                              onChanged: (v) {
                                setState(() => passwordLength = v);
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Toggles
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

                // Save button
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
                    onPressed: () {},
                    child: const Text(
                      "Guardar",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
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
      child: child,
    );
  }

  Widget _buildTextField({
    required String label,
    String? initialValue,
    int maxLines = 1,
  }) {
    return TextField(
      controller:
          initialValue != null
              ? TextEditingController(text: initialValue)
              : null,
      maxLines: maxLines,
      decoration: InputDecoration(
        filled: true,
        fillColor: Color(0xFFF3F5F9),
        labelText: label,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFFD2D2D2), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFFD2D2D2), width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Row(
      children: [
        InkWell(onTap: () {}, child: Icon(FeatherIcons.refreshCcw)),
        SizedBox(width: 16),
        Expanded(
          child: TextField(
            obscureText: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: Color(0xFFF3F5F9),
              labelText: "Contraseña",
              suffixIcon: IconButton(
                icon: const Icon(Icons.visibility_outlined),
                onPressed: () {},
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Color(0xFFD2D2D2), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Color(0xFFD2D2D2), width: 1),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
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
