import 'package:flutter/material.dart';
import 'package:keepassux/ui/model/alert_item.dart';

class AlertStack extends StatefulWidget {
  const AlertStack({required this.alerts, super.key});

  final List<AlertItem> alerts;

  @override
  State<AlertStack> createState() => _AlertStackState();
}

class _AlertStackState extends State<AlertStack>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _settling = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _hasCurrent => _currentIndex < widget.alerts.length;

  bool get _hasNext => _currentIndex + 1 < widget.alerts.length;

  bool get _hasAfterNext => _currentIndex + 2 < widget.alerts.length;

  void _dismiss() {
    if (!_hasCurrent || _controller.isAnimating) return;
    _controller.forward(from: 0.0).then((_) {
      setState(() {
        _currentIndex++;
        _settling = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() { _settling = false; });
      });
    });
  }

  Widget _buildAlertCard(AlertItem alert, {VoidCallback? onClose}) {
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                GestureDetector(
                  onTap: onClose,
                  child: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(alert.text),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasCurrent) return const SizedBox.shrink();

    final frontAlert = widget.alerts[_currentIndex];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final isAnimating = _controller.isAnimating;

        final backTopPadding = isAnimating ? t * 8.0 : 0.0;

        return Stack(
          alignment: Alignment.topCenter,
          children: [
            if (_hasAfterNext)
              Padding(
                padding: EdgeInsets.only(top: isAnimating ? (8.0 - t * 8.0) : 8.0),
                child: Transform.scale(
                  scale: 0.95,
                  alignment: Alignment.topCenter,
                  child: AnimatedOpacity(
                    opacity: _settling ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: Opacity(
                      opacity: isAnimating ? (0.5 + t * 0.2) : 0.5,
                      child: _buildAlertCard(widget.alerts[_currentIndex + 2]),
                    ),
                  ),
                ),
              ),
            if (_hasNext)
              Padding(
                padding: EdgeInsets.only(top: backTopPadding),
                child: Transform.scale(
                  scale: isAnimating ? (0.95 + t * 0.05) : 0.95,
                  alignment: Alignment.topCenter,
                  child: Opacity(
                    opacity: isAnimating ? (0.7 + t * 0.3) : 0.7,
                    child: _buildAlertCard(widget.alerts[_currentIndex + 1]),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Opacity(
                opacity: isAnimating ? (1.0 - t) : 1.0,
                child: _buildAlertCard(frontAlert, onClose: _dismiss),
              ),
            ),
          ],
        );
      },
    );
  }
}
