import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/me/entity/payout.dart';
import 'package:klozy/src/domain/me/me_repository.dart';

@RoutePage()
class PayoutsPage extends StatefulWidget {
  const PayoutsPage({super.key});

  @override
  State<PayoutsPage> createState() => _PayoutsPageState();
}

class _PayoutsPageState extends State<PayoutsPage> {
  late final Future<PayoutSummary> _future = locator<MeRepository>()
      .getPayouts();

  String _aed(BuildContext context, int fils) =>
      context.l10N.checkout_amount_dhs((fils / 100).round());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColor.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 22),
          onPressed: () => context.router.maybePop(),
        ),
        title: Text(context.l10N.settings_payouts),
      ),
      body: FutureBuilder<PayoutSummary>(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<PayoutSummary> snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const DSLoader();
          }
          final data = snap.data ?? const PayoutSummary();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: _tile(
                      context,
                      context.l10N.payouts_pending,
                      _aed(context, data.pendingFils),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _tile(
                      context,
                      context.l10N.payouts_lifetime,
                      _aed(context, data.lifetimePaidFils),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (data.items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      context.l10N.payouts_empty,
                      style: const TextStyle(
                        fontFamily: dsFontFamily,
                        fontSize: DSFontSize.bodyMedium,
                        color: DSColor.onSurface45,
                      ),
                    ),
                  ),
                )
              else
                ...data.items.map((PayoutItem i) => _itemRow(context, i)),
            ],
          );
        },
      ),
    );
  }

  Widget _tile(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DSColor.card,
        borderRadius: BorderRadius.circular(DSBorderRadius.card),
        border: Border.all(color: DSColor.onSurface07, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            value,
            style: const TextStyle(
              fontFamily: dsFontFamily,
              fontSize: 22,
              fontWeight: DSFontWeight.bold,
              color: DSColor.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: dsFontFamily,
              fontSize: DSFontSize.bodySmall,
              color: DSColor.onSurface45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemRow(BuildContext context, PayoutItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DSColor.card,
        borderRadius: BorderRadius.circular(DSBorderRadius.card),
        border: Border.all(color: DSColor.onSurface07, width: 0.5),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _aed(context, item.netFils),
                  style: const TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: DSFontSize.bodyLarge,
                    fontWeight: DSFontWeight.bold,
                    color: DSColor.onSurface,
                  ),
                ),
                Text(
                  '#${item.orderId}',
                  style: const TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: DSFontSize.bodySmall,
                    color: DSColor.onSurface45,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _statusLabel(context, item.status),
            style: TextStyle(
              fontFamily: dsFontFamily,
              fontSize: DSFontSize.bodyMedium,
              fontWeight: DSFontWeight.medium,
              color: item.status == PayoutStatus.completed
                  ? const Color(0xFFA7D2BE)
                  : DSColor.onSurface60,
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(BuildContext context, PayoutStatus status) {
    return switch (status) {
      PayoutStatus.completed => context.l10N.payouts_status_completed,
      PayoutStatus.reversal => context.l10N.payouts_status_reversal,
      PayoutStatus.pending => context.l10N.payouts_status_pending,
    };
  }
}
