import 'dart:io';
import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:kdbx/kdbx.dart';

import 'kdbx_icon_widget.dart';

class IconPickerResult {
  final int icon;
  final Uint8List? customIconData;

  const IconPickerResult({required this.icon, this.customIconData});
}

class IconPickerDialog extends StatefulWidget {
  const IconPickerDialog({
    required this.currentIcon,
    this.currentCustomIconData,
    super.key,
  });

  final int currentIcon;
  final Uint8List? currentCustomIconData;

  static Future<IconPickerResult?> show(
    BuildContext context, {
    required int currentIcon,
    Uint8List? currentCustomIconData,
  }) {
    return showModalBottomSheet<IconPickerResult>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder:
          (_) => SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: IconPickerDialog(
              currentIcon: currentIcon,
              currentCustomIconData: currentCustomIconData,
            ),
          ),
    );
  }

  @override
  State<IconPickerDialog> createState() => _IconPickerDialogState();
}

class _IconPickerDialogState extends State<IconPickerDialog> {
  late int _selectedIcon;
  Uint8List? _selectedCustomIconData;
  bool _isCustomSelected = false;

  @override
  void initState() {
    super.initState();
    _selectedIcon = widget.currentIcon;
    _selectedCustomIconData = widget.currentCustomIconData;
    _isCustomSelected = widget.currentCustomIconData != null;
  }

  Future<void> _pickCustomIcon() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      final file = result.files.single;
      Uint8List? bytes;
      if (file.bytes != null) {
        bytes = file.bytes;
      } else if (file.path != null) {
        bytes = await File(file.path!).readAsBytes();
      }
      if (bytes != null) {
        setState(() {
          _selectedCustomIconData = bytes;
          _isCustomSelected = true;
        });
      }
    }
  }

  void _selectIcon(int index) {
    setState(() {
      _selectedIcon = index;
      _isCustomSelected = false;
      _selectedCustomIconData = null;
    });
  }

  void _confirm() {
    Navigator.pop(
      context,
      IconPickerResult(
        icon: _selectedIcon,
        customIconData: _isCustomSelected ? _selectedCustomIconData : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 24,
                bottom: 16,
                left: 24,
                right: 24,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tr("icon_picker.title"),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            mainAxisSpacing: 4,
                            crossAxisSpacing: 4,
                          ),
                      itemCount: KdbxIcon.values.length,
                      itemBuilder: (context, index) {
                        final isSelected =
                            !_isCustomSelected && _selectedIcon == index;
                        return GestureDetector(
                          onTap: () => _selectIcon(index),
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? Colors.teal.withOpacity(0.15)
                                      : Colors.transparent,
                              border: Border.all(
                                color:
                                    isSelected
                                        ? Colors.teal
                                        : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: KDBXIconWidget(
                                icon: index,
                                size: 22,
                                color:
                                    isSelected
                                        ? Colors.teal
                                        : Colors.grey.shade700,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        if (_selectedCustomIconData != null)
                          GestureDetector(
                            onTap: _pickCustomIcon,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      _isCustomSelected
                                          ? Colors.teal
                                          : Colors.grey.shade300,
                                  width: _isCustomSelected ? 2.5 : 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: KDBXIconWidget(
                                icon: _selectedIcon,
                                customIconData: _selectedCustomIconData,
                                size: 40,
                              ),
                            ),
                          ),
                        if (_selectedCustomIconData != null)
                          const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: OutlinedButton.icon(
                              onPressed: _pickCustomIcon,
                              icon: const Icon(Icons.upload),
                              label: Text(
                                _selectedCustomIconData != null
                                    ? tr("icon_picker.change_custom_icon")
                                    : tr("icon_picker.custom_icon"),
                              ),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        tr("icon_picker.cancel"),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _confirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        tr("icon_picker.select"),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
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
