import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_bottom_bar.dart';
import 'package:klozy/src/design/components/ds_button_outline.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/me/entity/address.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/router/app_router.dart';

@RoutePage()
class AddressBookPage extends StatefulWidget {
  const AddressBookPage({super.key});

  @override
  State<AddressBookPage> createState() => _AddressBookPageState();
}

class _AddressBookPageState extends State<AddressBookPage> {
  final MeRepository _repo = locator<MeRepository>();
  bool _loading = true;
  List<Address> _addresses = const <Address>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      _addresses = await _repo.getAddresses();
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _add() async {
    final changed = await context.router.push<bool>(AddressFormRoute());
    if (changed == true) _reload();
  }

  Future<void> _edit(Address address) async {
    final changed = await context.router.push<bool>(
      AddressFormRoute(address: address),
    );
    if (changed == true) _reload();
  }

  void _reload() {
    setState(() => _loading = true);
    _load();
  }

  Future<void> _setDefault(Address a) async {
    try {
      _addresses = await _repo.setDefaultAddress(a.id);
      if (mounted) setState(() {});
    } catch (_) {}
  }

  Future<void> _delete(Address a) async {
    setState(
      () => _addresses = _addresses.where((Address x) => x.id != a.id).toList(),
    );
    try {
      await _repo.deleteAddress(a.id);
    } catch (_) {}
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColor.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 22),
          onPressed: () => context.router.maybePop(),
        ),
        title: Text(context.l10N.settings_delivery_address),
      ),
      bottomNavigationBar: DSBottomBar(
        child: DSButtonOutline(
          text: context.l10N.address_add_title,
          onPressed: _add,
        ),
      ),
      body: _loading
          ? const DSLoader()
          : _addresses.isEmpty
          ? Center(
              child: Text(
                context.l10N.address_empty,
                style: const TextStyle(
                  fontFamily: dsFontFamily,
                  fontSize: DSFontSize.bodyMedium,
                  color: DSColor.onSurface45,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: _addresses
                  .map((Address a) => _row(context, a))
                  .toList(),
            ),
    );
  }

  Widget _row(BuildContext context, Address a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
      decoration: BoxDecoration(
        color: DSColor.card,
        borderRadius: BorderRadius.circular(DSBorderRadius.card),
        border: Border.all(color: DSColor.onSurface07, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        a.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: dsFontFamily,
                          fontSize: DSFontSize.bodyLarge,
                          fontWeight: DSFontWeight.semiBold,
                          color: DSColor.onSurface,
                        ),
                      ),
                    ),
                    if (a.isDefault) ...<Widget>[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x1FE0CE7D),
                          borderRadius: BorderRadius.circular(
                            DSBorderRadius.chip,
                          ),
                        ),
                        child: Text(
                          context.l10N.address_default,
                          style: const TextStyle(
                            fontFamily: dsFontFamily,
                            fontSize: 9,
                            fontWeight: DSFontWeight.bold,
                            color: DSColor.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  a.summary,
                  style: const TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: DSFontSize.bodyMedium,
                    color: DSColor.onSurface60,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: DSColor.onSurface45),
            color: DSColor.card,
            onSelected: (String v) {
              switch (v) {
                case 'edit':
                  _edit(a);
                case 'default':
                  _setDefault(a);
                case 'delete':
                  _delete(a);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'edit',
                child: Text(context.l10N.address_action_edit),
              ),
              if (!a.isDefault)
                PopupMenuItem<String>(
                  value: 'default',
                  child: Text(context.l10N.address_action_default),
                ),
              if (_addresses.length > 1)
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Text(context.l10N.address_action_delete),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
