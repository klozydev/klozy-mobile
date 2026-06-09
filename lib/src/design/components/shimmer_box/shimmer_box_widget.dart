import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';

class ShimmerBoxWidget extends StatefulWidget {
  const ShimmerBoxWidget({
    super.key,
    this.width,
    this.height,
    this.borderRadius = DSBorderRadius.light,
    this.margin = EdgeInsets.zero,
    this.animationDelay = Duration.zero,
  });

  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsets margin;
  final Duration animationDelay;

  @override
  State<ShimmerBoxWidget> createState() => _ShimmerBoxWidgetState();
}

class _ShimmerBoxWidgetState extends State<ShimmerBoxWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    Future<void>.delayed(widget.animationDelay, () {
      if (mounted) {
        _controller.repeat();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1 + 2 * t, 0),
              end: Alignment(1 + 2 * t, 0),
              colors: [
                appTheme.shimmerBase,
                appTheme.shimmerHighlight,
                appTheme.shimmerBase,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}
