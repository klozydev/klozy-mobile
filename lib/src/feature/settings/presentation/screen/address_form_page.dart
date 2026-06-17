import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_bottom_bar.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_field_label.dart';
import 'package:klozy/src/design/components/ds_text_field.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/me/entity/address.dart';
import 'package:klozy/src/domain/me/entity/address_input.dart';
import 'package:klozy/src/domain/me/me_repository.dart';

@RoutePage()
class AddressFormPage extends StatefulWidget {
  final Address? address;

  /// When true (seller shipping setup), the phone is mandatory — EMX rejects a
  /// forward shipment whose shipper has no phone number.
  final bool requirePhone;

  const AddressFormPage({this.address, this.requirePhone = false, super.key});

  @override
  State<AddressFormPage> createState() => _AddressFormPageState();
}

class _AddressFormPageState extends State<AddressFormPage> {
  final MeRepository _repo = locator<MeRepository>();
  late final TextEditingController _label = _ctl(widget.address?.label);
  late final TextEditingController _recipient = _ctl(
    widget.address?.recipientName,
  );
  late final TextEditingController _phone = _ctl(widget.address?.phone);
  late final TextEditingController _line1 = _ctl(widget.address?.line1);
  late final TextEditingController _area = _ctl(widget.address?.area);
  late final TextEditingController _city = _ctl(widget.address?.city);
  late final TextEditingController _emirate = _ctl(widget.address?.emirate);
  bool _saving = false;

  TextEditingController _ctl(String? text) => TextEditingController(text: text);

  @override
  void dispose() {
    for (final TextEditingController c in <TextEditingController>[
      _label,
      _recipient,
      _phone,
      _line1,
      _area,
      _city,
      _emirate,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _valid =>
      _line1.text.trim().isNotEmpty &&
      _city.text.trim().isNotEmpty &&
      _emirate.text.trim().isNotEmpty &&
      (!widget.requirePhone || _phone.text.trim().isNotEmpty);

  Future<void> _save() async {
    setState(() => _saving = true);
    final input = AddressInput(
      line1: _line1.text.trim(),
      city: _city.text.trim(),
      emirate: _emirate.text.trim(),
      area: _area.text.trim().isEmpty ? null : _area.text.trim(),
      label: _label.text.trim().isEmpty ? null : _label.text.trim(),
      recipientName: _recipient.text.trim().isEmpty
          ? null
          : _recipient.text.trim(),
      phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
    );
    try {
      if (widget.address == null) {
        await _repo.createAddress(input);
      } else {
        await _repo.updateAddress(widget.address!.id, input);
      }
      if (mounted) {
        context.showSnackBar(context.l10N.settings_saved);
        context.router.maybePop(true);
      }
    } catch (_) {
      if (mounted) context.showSnackBar(context.l10N.settings_save_failed);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10N;
    return Scaffold(
      backgroundColor: DSColor.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 22),
          onPressed: () => context.router.maybePop(),
        ),
        title: Text(
          widget.address == null ? l.address_add_title : l.address_edit_title,
        ),
      ),
      bottomNavigationBar: DSBottomBar(
        child: DSButtonElevated(
          text: l.settings_save,
          isEnable: _valid,
          isLoading: _saving,
          onPressed: _save,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        children: <Widget>[
          DSFieldLabel(l.address_label),
          DSTextField(controller: _label, hintText: 'Home'),
          const SizedBox(height: 12),
          DSFieldLabel(l.address_recipient),
          DSTextField(controller: _recipient),
          const SizedBox(height: 12),
          DSFieldLabel(l.address_phone, required: widget.requirePhone),
          DSTextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            onChanged: widget.requirePhone ? (_) => setState(() {}) : null,
          ),
          const SizedBox(height: 12),
          DSFieldLabel(l.settings_address_line1, required: true),
          DSTextField(controller: _line1, onChanged: (_) => setState(() {})),
          const SizedBox(height: 12),
          DSFieldLabel(l.settings_address_area),
          DSTextField(controller: _area),
          const SizedBox(height: 12),
          DSFieldLabel(l.settings_address_city, required: true),
          DSTextField(controller: _city, onChanged: (_) => setState(() {})),
          const SizedBox(height: 12),
          DSFieldLabel(l.settings_address_emirate, required: true),
          DSTextField(controller: _emirate, onChanged: (_) => setState(() {})),
        ],
      ),
    );
  }
}
