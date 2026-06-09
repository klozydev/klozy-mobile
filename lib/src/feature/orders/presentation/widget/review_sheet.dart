import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_text_field.dart';
import 'package:klozy/src/feature/orders/presentation/widget/star_rating_input.dart';

typedef ReviewResult = ({int rating, String? body});

class ReviewSheet extends StatefulWidget {
  const ReviewSheet({super.key});

  @override
  State<ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<ReviewSheet> {
  final TextEditingController _body = TextEditingController();
  int _rating = 5;

  @override
  void dispose() {
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        StarRatingInput(
          rating: _rating,
          onChanged: (int v) => setState(() => _rating = v),
        ),
        const SizedBox(height: 16),
        DSTextField(
          controller: _body,
          hintText: context.l10N.orders_review_hint,
          maxLines: 3,
          maxLength: 1000,
        ),
        const SizedBox(height: 16),
        DSButtonElevated(
          text: context.l10N.orders_submit_review,
          onPressed: () => Navigator.of(
            context,
          ).pop((rating: _rating, body: _body.text.trim())),
        ),
      ],
    );
  }
}
