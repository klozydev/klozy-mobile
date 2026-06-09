import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/domain/orders/entity/order_tracking.dart';

/// Vertical EMX tracking stepper.
class OrderTrackingStepperWidget extends StatelessWidget {
  final List<TrackingStep> steps;

  const OrderTrackingStepperWidget({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (int i = 0; i < steps.length; i++)
          _row(steps[i], isLast: i == steps.length - 1),
      ],
    );
  }

  Widget _row(TrackingStep step, {required bool isLast}) {
    final bool done = step.state == TrackStepState.done;
    final bool active = step.state == TrackStepState.active;
    final Color accent = done || active ? DSColor.primary : DSColor.onSurface18;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            children: <Widget>[
              _marker(done, active),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: done ? DSColor.primary : DSColor.onSurface10,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    step.label,
                    style: TextStyle(
                      fontFamily: dsFontFamily,
                      fontSize: DSFontSize.bodyMedium,
                      fontWeight: done || active
                          ? DSFontWeight.semiBold
                          : DSFontWeight.regular,
                      color: done || active
                          ? DSColor.onSurface
                          : DSColor.onSurface45,
                    ),
                  ),
                  if (step.sublabel != null) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(
                      step.sublabel!,
                      style: TextStyle(
                        fontFamily: dsFontFamily,
                        fontSize: DSFontSize.bodySmall,
                        color: active ? accent : DSColor.onSurface35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _marker(bool done, bool active) {
    if (done) {
      return Container(
        width: 22,
        height: 22,
        decoration: const BoxDecoration(
          color: DSColor.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, size: 14, color: DSColor.surface),
      );
    }
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: active ? DSColor.primary : DSColor.onSurface18,
          width: 2,
        ),
      ),
      child: active
          ? Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: DSColor.primary,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}
