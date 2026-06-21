import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';

/// Placeholder rows shown while the threads stream delivers its first snapshot.
class ChatListLoadingWidget extends StatelessWidget {
  const ChatListLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 32),
      itemCount: 8,
      itemBuilder: (_, _) => const _SkeletonRow(),
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 11),
      child: Row(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: DSColor.card,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 120,
                  height: 13,
                  decoration: BoxDecoration(
                    color: DSColor.card,
                    borderRadius: BorderRadius.circular(DSBorderRadius.badge),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 200,
                  height: 11,
                  decoration: BoxDecoration(
                    color: DSColor.onSurface06,
                    borderRadius: BorderRadius.circular(DSBorderRadius.badge),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
