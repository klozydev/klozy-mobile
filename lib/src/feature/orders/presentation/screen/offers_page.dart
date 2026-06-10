import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/components/ds_segmented_control.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/offers/entity/offer.dart';
import 'package:klozy/src/domain/offers/offers_repository.dart';
import 'package:klozy/src/feature/orders/presentation/widget/offer_row_widget.dart';

/// Incoming (on my listings) and outgoing (offers I made) offers.
@RoutePage()
class OffersPage extends StatefulWidget {
  const OffersPage({super.key});

  @override
  State<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
  final OffersRepository _repo = locator<OffersRepository>();
  int _index = 0;
  bool _loading = true;
  List<Offer> _incoming = const <Offer>[];
  List<Offer> _outgoing = const <Offer>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait<List<Offer>>(<Future<List<Offer>>>[
        _repo.listOffers(incoming: true),
        _repo.listOffers(incoming: false),
      ]);
      _incoming = results[0];
      _outgoing = results[1];
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _act(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      if (mounted) context.showSnackBar(context.l10N.settings_save_failed);
    }
    if (mounted) {
      setState(() => _loading = true);
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final offers = _index == 0 ? _incoming : _outgoing;
    return Scaffold(
      backgroundColor: DSColor.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 22),
          onPressed: () => context.router.maybePop(),
        ),
        title: Text(context.l10N.offers_title),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: DSSegmentedControl(
              labels: <String>[
                context.l10N.offers_incoming,
                context.l10N.offers_outgoing,
              ],
              selectedIndex: _index,
              onChanged: (int i) => setState(() => _index = i),
            ),
          ),
          Expanded(
            child: _loading
                ? const DSLoader()
                : offers.isEmpty
                ? Center(
                    child: Text(
                      context.l10N.offers_empty,
                      style: const TextStyle(
                        fontFamily: dsFontFamily,
                        fontSize: DSFontSize.bodyMedium,
                        color: DSColor.onSurface45,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    itemCount: offers.length,
                    itemBuilder: (BuildContext context, int i) {
                      final Offer offer = offers[i];
                      return OfferRowWidget(
                        offer: offer,
                        incoming: _index == 0,
                        onAccept: () => _act(() => _repo.acceptOffer(offer.id)),
                        onDecline: () =>
                            _act(() => _repo.declineOffer(offer.id)),
                        onCancel: () => _act(() => _repo.cancelOffer(offer.id)),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
