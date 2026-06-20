import 'package:flutter/material.dart';
import 'package:klozy/src/design/components/shimmer_box/shimmer_box_widget.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';

/// First-load placeholder rows for the notification center — animated shimmer,
/// mirroring the prototype's `k-shimmer` rows.
class NotificationSkeletonWidget extends StatelessWidget {
  const NotificationSkeletonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: 5,
      itemBuilder: (BuildContext context, int index) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 13, horizontal: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ShimmerBoxWidget(
              width: 40,
              height: 40,
              borderRadius: DSBorderRadius.chip,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ShimmerBoxWidget(width: 160, height: 13),
                  SizedBox(height: 8),
                  ShimmerBoxWidget(width: double.infinity, height: 11),
                  SizedBox(height: 6),
                  ShimmerBoxWidget(width: 80, height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
