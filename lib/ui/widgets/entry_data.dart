import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kdbx/kdbx.dart';
import 'package:keepassux/ui/widgets/kdbx_icon_widget.dart';

class EntryData extends StatefulWidget {
  const EntryData({required this.entry, super.key});

  final KdbxEntry entry;

  @override
  State<EntryData> createState() => _EntryDataState();
}

class _EntryDataState extends State<EntryData> {
  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back),
            ),
            KDBXIconWidget(object: widget.entry, size: 27),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView(
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: widget.entry.label,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: tr("entry_data.title"),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.transparent,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.transparent,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(
                        ClipboardData(text: widget.entry.label ?? ""),
                      );
                    },
                    child: Icon(Icons.copy),
                  ),
                ],
              ),
              if ((widget.entry.getString(KdbxKeyCommon.USER_NAME)?.getText() ??
                      "")
                  .isNotEmpty) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue:
                            widget.entry
                                .getString(KdbxKeyCommon.USER_NAME)
                                ?.getText() ??
                            "",
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: tr("entry_data.user"),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.transparent,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.transparent,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    InkWell(
                      onTap: () {
                        String? value =
                            widget.entry
                                .getString(KdbxKeyCommon.USER_NAME)
                                ?.getText();
                        if (value != null) {
                          Clipboard.setData(ClipboardData(text: value));
                        }
                      },
                      child: Icon(Icons.copy),
                    ),
                  ],
                ),
              ],
              if ((widget.entry.getString(KdbxKeyCommon.PASSWORD)?.getText() ??
                      "")
                  .isNotEmpty) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue:
                            widget.entry
                                .getString(KdbxKeyCommon.PASSWORD)
                                ?.getText() ??
                            "",
                        readOnly: true,
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
                          labelText: tr("entry_data.password"),
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
                              color: Colors.transparent,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.transparent,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    InkWell(
                      onTap: () {
                        String? value =
                            widget.entry
                                .getString(KdbxKeyCommon.PASSWORD)
                                ?.getText();
                        if (value != null) {
                          Clipboard.setData(ClipboardData(text: value));
                        }
                      },
                      child: Icon(Icons.copy),
                    ),
                  ],
                ),
              ],
              if ((widget.entry.getString(KdbxKeyCommon.URL)?.getText() ?? "")
                  .isNotEmpty) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue:
                            widget.entry
                                .getString(KdbxKeyCommon.URL)
                                ?.getText() ??
                            "",
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: tr("entry_data.url"),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.transparent,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.transparent,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    InkWell(
                      onTap: () {
                        String? value =
                            widget.entry
                                .getString(KdbxKeyCommon.URL)
                                ?.getText();
                        if (value != null) {
                          Clipboard.setData(ClipboardData(text: value));
                        }
                      },
                      child: Icon(Icons.copy),
                    ),
                  ],
                ),
              ],
              if ((widget.entry.getString(KdbxKey('Notes'))?.getText() ??
                      "")
                  .isNotEmpty) ...[
                const SizedBox(height: 16),
                TextFormField(
                  initialValue:
                      widget.entry
                          .getString(KdbxKey('Notes'))
                          ?.getText() ??
                      "",
                  readOnly: true,
                  maxLines: null,
                  decoration: InputDecoration(
                    labelText: tr("entry_data.notes"),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Colors.transparent,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Colors.transparent,
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
