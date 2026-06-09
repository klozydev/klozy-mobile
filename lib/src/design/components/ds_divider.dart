import 'package:flutter/material.dart';

import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';

class DSDivider extends StatelessWidget {
  const DSDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: DSSpacing.s),
      child: SizedBox(height: 1, child: ColoredBox(color: DSColor.onSurface24)),
    );
  }
}
