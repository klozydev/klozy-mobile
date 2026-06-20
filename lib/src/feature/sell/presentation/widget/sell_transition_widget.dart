import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';

/// "AI is working" transition: the cover photo blurred behind a rotating gold
/// ring wrapped around the cover thumbnail, a sparkle badge, an evolving step
/// message and progress dots (design variant A). The steps advance forward and
/// hold on the last one — they do not loop.
class SellTransitionWidget extends StatefulWidget {
  final String? coverPath;

  const SellTransitionWidget({super.key, this.coverPath});

  @override
  State<SellTransitionWidget> createState() => _SellTransitionWidgetState();
}

class _SellTransitionWidgetState extends State<SellTransitionWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ring = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();
  int _step = 0;
  Timer? _timer;

  List<String> _steps(BuildContext context) => <String>[
    context.l10N.sell_analysing_your_photos,
    context.l10N.sell_identifying_the_item,
    context.l10N.sell_generating_title_and_price,
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1400), (Timer t) {
      // Advance and clamp at the final step — no infinite loop.
      if (_step >= 2) {
        t.cancel();
        return;
      }
      setState(() => _step += 1);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ring.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> steps = _steps(context);
    final File? cover = widget.coverPath == null
        ? null
        : File(widget.coverPath!);
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        // Blurred cover backdrop.
        if (cover != null)
          ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: 26, sigmaY: 26),
            child: Image.file(
              cover,
              fit: BoxFit.cover,
              color: Colors.black.withValues(alpha: 0.55),
              colorBlendMode: BlendMode.darken,
            ),
          ),
        const ColoredBox(color: Color(0x66000000)),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                width: 132,
                height: 132,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    // Rotating gold ring.
                    RotationTransition(
                      turns: _ring,
                      child: Container(
                        width: 132,
                        height: 132,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: <Color>[
                              DSColor.onSurface10,
                              DSColor.onSurface10,
                              DSColor.primary,
                            ],
                            stops: <double>[0.0, 0.75, 1.0],
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(3),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: DSColor.surface,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Cover thumbnail.
                    ClipOval(
                      child: SizedBox(
                        width: 104,
                        height: 104,
                        child: cover == null
                            ? const ColoredBox(color: DSColor.lowBlack)
                            : Image.file(cover, fit: BoxFit.cover),
                      ),
                    ),
                    // Sparkle badge.
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: Container(
                        width: 34,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: DSColor.primary,
                          boxShadow: <BoxShadow>[
                            BoxShadow(color: Color(0x66000000), blurRadius: 14),
                          ],
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          size: 18,
                          color: DSColor.surface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: DSSpacing.xl),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  steps[_step],
                  key: ValueKey<int>(_step),
                  style: const TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: DSFontSize.headlineLarge,
                    fontWeight: DSFontWeight.semiBold,
                    color: DSColor.onSurface,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
              const SizedBox(height: DSSpacing.s),
              // Progress dots — active is wider; all up to the current step lit.
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  for (int i = 0; i < steps.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3.5),
                      width: i == _step ? 22 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: i <= _step
                            ? DSColor.primary
                            : DSColor.onSurface15,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
