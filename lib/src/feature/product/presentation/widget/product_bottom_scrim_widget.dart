import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';

class ProductBottomScrimWidget extends StatelessWidget {
  const ProductBottomScrimWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.66,
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: <Color>[
              DSColor.surface.withOpacity(0.85),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}
