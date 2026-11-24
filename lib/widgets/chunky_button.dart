import 'package:flutter/material.dart';

/// Круглая/скруглённая «толстая» кнопка в стиле Duolingo:
/// сплошной цвет + тёмная нижняя кромка, которая «продавливается» при нажатии.
class ChunkyButton extends StatefulWidget {
  const ChunkyButton({
    super.key,
    required this.child,
    required this.onTap,
    required this.color,
    required this.shadowColor,
    this.size = 48,
    this.circle = true,
    this.width,
    this.radius = 16,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color color;
  final Color shadowColor;
  final double size;
  final double? width;
  final bool circle;
  final double radius;

  @override
  State<ChunkyButton> createState() => _ChunkyButtonState();
}

class _ChunkyButtonState extends State<ChunkyButton> {
  bool _down = false;
  static const _depth = 4.0;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final w = widget.width ?? widget.size;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => setState(() => _down = true) : null,
      onTapCancel: enabled ? () => setState(() => _down = false) : null,
      onTapUp: enabled ? (_) => setState(() => _down = false) : null,
      onTap: widget.onTap,
      child: SizedBox(
        width: w,
        height: widget.size + _depth,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: _depth,
              height: widget.size,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: widget.shadowColor,
                  borderRadius: BorderRadius.circular(
                      widget.circle ? widget.size : widget.radius),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 60),
              left: 0,
              right: 0,
              top: _down ? _depth : 0,
              height: widget.size,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(
                      widget.circle ? widget.size : widget.radius),
                ),
                child: Center(child: widget.child),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
