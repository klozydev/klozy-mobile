import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_bottom_bar.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/me/entity/connect_status.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:url_launcher/url_launcher.dart';

/// Vendor Stripe Connect (KYB) onboarding status + Account Link entry.
@RoutePage()
class SellerVerificationPage extends StatefulWidget {
  const SellerVerificationPage({super.key});

  @override
  State<SellerVerificationPage> createState() => _SellerVerificationPageState();
}

class _SellerVerificationPageState extends State<SellerVerificationPage> {
  final MeRepository _repo = locator<MeRepository>();
  bool _loading = true;
  bool _opening = false;
  ConnectStatus _status = const ConnectStatus();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      _status = await _repo.getConnectStatus();
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _openKyb() async {
    setState(() => _opening = true);
    try {
      final url = await _repo.createKybLink();
      final uri = url == null ? null : Uri.tryParse(url);
      if (uri == null ||
          !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          context.showSnackBar(context.l10N.settings_link_failed);
        }
      }
    } catch (_) {
      if (mounted) context.showSnackBar(context.l10N.settings_link_failed);
    }
    if (mounted) setState(() => _opening = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10N;
    final bool complete = _status.onboarding == ConnectOnboarding.complete;
    return Scaffold(
      backgroundColor: DSColor.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 22),
          onPressed: () => context.router.maybePop(),
        ),
        title: Text(l.connect_title),
      ),
      bottomNavigationBar: _loading || complete
          ? null
          : DSBottomBar(
              child: DSButtonElevated(
                text: _status.onboarding == ConnectOnboarding.notStarted
                    ? l.connect_start
                    : l.connect_continue,
                isLoading: _opening,
                onPressed: _openKyb,
              ),
            ),
      body: _loading
          ? const DSLoader()
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: <Widget>[
                Container(
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
                        switch (_status.onboarding) {
                          ConnectOnboarding.complete =>
                            l.connect_status_complete,
                          ConnectOnboarding.pending => l.connect_status_pending,
                          ConnectOnboarding.notStarted =>
                            l.connect_status_not_started,
                        },
                        style: TextStyle(
                          fontFamily: dsFontFamily,
                          fontSize: DSFontSize.titleLarge,
                          fontWeight: DSFontWeight.semiBold,
                          color: complete
                              ? const Color(0xFFA7D2BE)
                              : DSColor.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l.connect_explainer,
                        style: const TextStyle(
                          fontFamily: dsFontFamily,
                          fontSize: DSFontSize.bodyMedium,
                          height: 1.45,
                          color: DSColor.onSurface60,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _CheckRow(
                        label: l.connect_details_submitted,
                        done: _status.detailsSubmitted,
                      ),
                      _CheckRow(
                        label: l.connect_charges_enabled,
                        done: _status.chargesEnabled,
                      ),
                      _CheckRow(
                        label: l.connect_payouts_enabled,
                        done: _status.payoutsEnabled,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final String label;
  final bool done;

  const _CheckRow({required this.label, required this.done});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 18,
            color: done ? const Color(0xFFA7D2BE) : DSColor.onSurface35,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontFamily: dsFontFamily,
              fontSize: DSFontSize.bodyMedium,
              color: done ? DSColor.onSurface : DSColor.onSurface60,
            ),
          ),
        ],
      ),
    );
  }
}
