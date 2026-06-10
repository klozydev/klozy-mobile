import 'package:flutter/material.dart';

class ProductBottomScrimWidget extends StatelessWidget {
  const ProductBottomScrimWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const FractionallySizedBox(
      heightFactor: 0.66,
      alignment: Alignment.bottomCenter,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: <Color>[
              Color(0xFF000000),
              Color(0xEB000000),
              Color(0x9E000000),
              Color(0x33000000),
              Color(0x00000000),
            ],
            stops: <double>[0.0, 0.16, 0.40, 0.72, 1.0],
          ),
        ),
      ),
    );
  }
}
