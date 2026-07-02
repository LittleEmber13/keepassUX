import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../ui/model/db_root.dart';
import '../ui/services/biometric_service.dart';
import '../ui/utils/kdbx_command.dart';
import '../ui/utils/kdbx_isolate.dart';

class AutofillUnlockPage extends StatefulWidget {
  const AutofillUnlockPage({
    super.key,
    required this.kdbxUri,
    required this.bytes,
    required this.isolate,
    required this.biometricEligible,
    required this.onUnlocked,
    this.subtitle,
  });

  final String kdbxUri;
  final Uint8List bytes;
  final KdbxIsolate isolate;

  final bool biometricEligible;

  final void Function(DbRoot root) onUnlocked;

  final String? subtitle;

  @override
  State<AutofillUnlockPage> createState() => _AutofillUnlockPageState();
}

class _AutofillUnlockPageState extends State<AutofillUnlockPage> {
  final TextEditingController _passwordController = TextEditingController();
  final BiometricService _biometric = BiometricService();

  bool _obscure = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _unlockWithPassword() async {
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() => _error = 'Introduce la contraseña maestra.');
      return;
    }
    await _tryUnlock(password);
  }

  Future<void> _unlockWithBiometric() async {
    final password = await _biometric.authenticateAndRetrievePassword(
      widget.kdbxUri,
    );
    if (password == null || password.isEmpty) {
      if (mounted) {
        setState(() => _error = 'No se pudo verificar tu identidad.');
      }
      return;
    }
    await _tryUnlock(password);
  }

  Future<void> _tryUnlock(String password) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final root = await widget.isolate.send<DbRoot>(
        LoadDatabaseCmd(bytes: widget.bytes, password: password),
      );
      widget.onUnlocked(root);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Contraseña incorrecta.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KeepassUX')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                widget.subtitle ?? 'Desbloquea tu base de datos',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _passwordController,
                obscureText: _obscure,
                autofocus: true,
                enabled: !_busy,
                onSubmitted: (_) => _unlockWithPassword(),
                decoration: InputDecoration(
                  labelText: 'Contraseña maestra',
                  errorText: _error,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _busy ? null : _unlockWithPassword,
                  icon: const Icon(Icons.lock_open),
                  label: const Text('Desbloquear'),
                ),
              ),
              if (widget.biometricEligible) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _busy ? null : _unlockWithBiometric,
                    icon: const Icon(FontAwesomeIcons.fingerprint),
                    label: const Text('Usar huella'),
                  ),
                ),
              ],
              if (_busy) ...[
                const SizedBox(height: 24),
                const CircularProgressIndicator(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
