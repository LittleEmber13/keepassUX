import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class TrashInfoCard extends StatelessWidget {
  const TrashInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFEEFDFF),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            spreadRadius: 1,
            offset: const Offset(1, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInstruction(
              icon: Icons.delete_outline,
              iconColor: Colors.red,
              text: tr("trash.info_delete"),
            ),
            const SizedBox(height: 8),
            _buildInstruction(
              icon: Icons.restore,
              iconColor: Colors.orange,
              text: tr("trash.info_restore"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstruction({
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }
}
