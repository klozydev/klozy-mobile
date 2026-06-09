import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';

enum DSSegmentedSize { sm, md }

/// Pill segmented control with an animated sliding indicator. Mirrors the
/// prototype `Segmented` (used for Sign up/Log in and EU/US toggles).
class DSSegmentedControl extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final DSSegmentedSize size;

  const DSSegmentedControl({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.size = DSSegmentedSize.md,
  });

  bool get _md => size == DSSegmentedSize.md;
  double get _height => _md ? 44 : 32;
  double get _radius => _md ? 14 : 10;
  double get _innerRadius => _md ? 11 : 7;

  @override
  Widget build(BuildContext context) {
    const double pad = 3;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double segWidth =
            (constraints.maxWidth - pad * 2) / labels.length;
        return Container(
          height: _height,
          padding: const EdgeInsets.all(pad),
          decoration: BoxDecoration(
            color: DSColor.onSurface07,
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(color: DSColor.onSurface08, width: 0.5),
          ),
          child: Stack(
            children: <Widget>[
              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                left: segWidth * selectedIndex,
                width: segWidth,
                top: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: DSColor.onSurface,
                    borderRadius: BorderRadius.circular(_innerRadius),
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  for (int i = 0; i < labels.length; i++)
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onChanged(i),
                        child: Center(
                          child: Text(
                            labels[i],
                            style: TextStyle(
                              fontFamily: dsFontFamily,
                              fontSize: _md
                                  ? DSFontSize.bodyLarge
                                  : DSFontSize.bodyMedium,
                              fontWeight: DSFontWeight.semiBold,
                              letterSpacing: -0.14,
                              color: i == selectedIndex
                                  ? DSColor.surface
                                  : DSColor.onSurface60,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
