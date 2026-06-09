import 'dart:async';

import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';

/// "AI is working" transition shown while photos upload + analyze.
class SellTransitionWidget extends StatefulWidget {
  const SellTransitionWidget({super.key});

  @override
  State<SellTransitionWidget> createState() => _SellTransitionWidgetState();
}

class _SellTransitionWidgetState extends State<SellTransitionWidget> {
  static const int _messageCount = 3;
  int _index = 0;
  Timer? _timer;

  List<String> _messages(BuildContext context) => <String>[
    context.l10N.sell_analysing_your_photos,
    context.l10N.sell_identifying_the_item,
    context.l10N.sell_generating_title_and_price,
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1400), (Timer t) {
      setState(() => _index = (_index + 1) % _messageCount);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: DSColor.primary,
            ),
          ),
          const SizedBox(height: 24),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _messages(context)[_index],
              key: ValueKey<int>(_index),
              style: const TextStyle(
                fontFamily: dsFontFamily,
                fontSize: DSFontSize.bodyLarge,
                fontWeight: DSFontWeight.medium,
                color: DSColor.onSurface75,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
