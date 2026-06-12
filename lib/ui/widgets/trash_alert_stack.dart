import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:keepassux/ui/model/alert_item.dart';

class TrashAlertStack extends StatelessWidget {
  const TrashAlertStack({required this.alerts, super.key});

  final List<AlertItem> alerts;

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        if (alerts.length > 2)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Transform.scale(
              scale: 0.95,
              alignment: Alignment.topCenter,
              child: Opacity(
                opacity: 0.5,
                child: _buildAlertCard(alerts[2]),
              ),
            ),
          ),
        if (alerts.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 0.0),
            child: Transform.scale(
              scale: 0.95,
              alignment: Alignment.topCenter,
              child: Opacity(
                opacity: 0.7,
                child: _buildAlertCard(alerts[1]),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: _buildAlertCard(alerts.first),
        ),
      ],
    );
  }

  Widget _buildAlertCard(AlertItem alert) {
    return Container(
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
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    alert.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const Icon(Icons.info_outline, color: Colors.black54),
              ],
            ),
            const SizedBox(height: 8),
            Text(alert.text),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.drag_indicator, size: 16, color: Colors.orange),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      tr("trash.restore_message"),
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
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
