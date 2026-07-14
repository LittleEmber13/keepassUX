import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:keepassux/ui/theme/theme.dart';

const Color _kTrackColor = Color(0xFF374151);
const Color _kErrorColor = Color(0xFFDC2626);
const Color _kDisabledTrackLight = Color(0xFF9CA3AF);
const Color _kDisabledKnobLight = Colors.white;
const Color _kDisabledTextLight = Colors.white70;

enum _SlideStatus { idle, loading, success, error }

class SlideToOpenButton extends StatefulWidget {
  final String label;
  final Future<bool> Function() onConfirmed;
  final bool enabled;

  const SlideToOpenButton({
    super.key,
    required this.label,
    required this.onConfirmed,
    this.enabled = true,
  });

  @override
  State<SlideToOpenButton> createState() => _SlideToOpenButtonState();
}

class _SlideToOpenButtonState extends State<SlideToOpenButton>
    with TickerProviderStateMixin {
  static const double _trackHeight = 56;
  static const double _knobPadding = 6;
  static const double _textGap = 12;
  static const double _trailingPadding = 24;
  static const double _radius = 14;
  static const TextStyle _labelStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  double _dragExtent = 0;
  _SlideStatus _status = _SlideStatus.idle;

  late final AnimationController _shimmerController;
  late final AnimationController _shakeController;

  double get _knobSize => _trackHeight - _knobPadding * 2;

  double get _trackWidth {
    final painter = TextPainter(
      text: TextSpan(text: widget.label, style: _labelStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    return _knobPadding * 2 +
        _knobSize +
        _textGap +
        painter.width +
        _trailingPadding;
  }

  double get _maxDrag => _trackWidth - _knobSize - _knobPadding * 2;

  bool get _canDrag => widget.enabled && _status == _SlideStatus.idle;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _updateShimmer();
  }

  @override
  void didUpdateWidget(SlideToOpenButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateShimmer();
  }

  void _updateShimmer() {
    if (widget.enabled) {
      if (!_shimmerController.isAnimating) {
        _shimmerController.repeat();
      }
    } else {
      _shimmerController.stop();
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _onDragUpdate(double delta) {
    if (!_canDrag) return;
    setState(() {
      _dragExtent = (_dragExtent + delta).clamp(0.0, _maxDrag);
    });
  }

  void _onDragEnd() {
    if (!_canDrag) return;
    if (_dragExtent >= _maxDrag * 0.75) {
      _confirm();
    } else {
      setState(() {
        _dragExtent = 0;
      });
    }
  }

  Future<void> _confirm() async {
    setState(() {
      _status = _SlideStatus.loading;
      _dragExtent = _maxDrag;
    });
    final success = await widget.onConfirmed();
    if (!mounted) return;
    if (success) {
      setState(() => _status = _SlideStatus.success);
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() {
        _status = _SlideStatus.idle;
        _dragExtent = 0;
      });
    } else {
      setState(() => _status = _SlideStatus.error);
      await _shakeController.forward(from: 0);
      if (!mounted) return;
      setState(() {
        _status = _SlideStatus.idle;
        _dragExtent = 0;
      });
    }
  }

  Widget _knobIcon(AppColors colors, bool isDark) {
    switch (_status) {
      case _SlideStatus.loading:
        return const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: _kTrackColor,
          ),
        );
      case _SlideStatus.success:
        return const Icon(Icons.check, color: _kTrackColor);
      case _SlideStatus.error:
        return const Icon(Icons.close, color: _kErrorColor);
      case _SlideStatus.idle:
        return Icon(
          Icons.arrow_forward,
          color: widget.enabled
              ? _kTrackColor
              : (isDark
                  ? colors.disabledActionText.withOpacity(0.05)
                  : _kDisabledTrackLight),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackWidth = _trackWidth;
    final progress =
        _maxDrag > 0 ? (_dragExtent / _maxDrag).clamp(0.0, 1.0) : 0.0;
    final trackColor = widget.enabled
        ? _kTrackColor
        : (isDark ? colors.cardBackground : _kDisabledTrackLight);
    final knobColor = widget.enabled
        ? Colors.white
        : (isDark ? colors.inputFill : _kDisabledKnobLight);

    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final shake = !_shakeController.isAnimating
            ? 0.0
            : math.sin(_shakeController.value * math.pi * 6) *
                8 *
                (1 - _shakeController.value);
        return Transform.translate(offset: Offset(shake, 0), child: child);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_radius),
        child: Container(
          width: trackWidth,
          height: _trackHeight,
          decoration: BoxDecoration(
            color: trackColor,
            borderRadius: BorderRadius.circular(_radius),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              if (widget.enabled)
                AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (context, child) {
                    final bandWidth = trackWidth * 0.5;
                    final left = -bandWidth +
                        _shimmerController.value * (trackWidth + bandWidth);
                    return Positioned(
                      left: left,
                      top: 0,
                      bottom: 0,
                      width: bandWidth,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0x00FFFFFF),
                              Color(0x1FFFFFFF),
                              Color(0x00FFFFFF),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              Positioned(
                left: _knobPadding + _knobSize + _textGap,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Opacity(
                    opacity: 1 - progress,
                    child: Text(
                      widget.label,
                      style: _labelStyle.copyWith(
                        color: widget.enabled
                            ? Colors.white
                            : (isDark
                                ? colors.disabledActionText.withOpacity(0.05)
                                : _kDisabledTextLight),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: _knobPadding + _dragExtent,
                top: _knobPadding,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) =>
                      _onDragUpdate(details.delta.dx),
                  onHorizontalDragEnd: (_) => _onDragEnd(),
                  child: Container(
                    width: _knobSize,
                    height: _knobSize,
                    decoration: BoxDecoration(
                      color: knobColor,
                      borderRadius: BorderRadius.circular(_radius - 4),
                    ),
                    child: Center(child: _knobIcon(colors, isDark)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
