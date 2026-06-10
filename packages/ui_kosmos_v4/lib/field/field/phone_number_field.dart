// ignore_for_file: deprecated_member_use

import 'package:core_kosmos/core_kosmos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:ui_kosmos_v4/ui_kosmos_v4.dart';

/// {@category Widget}
/// {@category Form, Input}
///
/// Champ de formulaire pour numéro de téléphone.
/// Widget permettant d'ajouter un un [fieldName] et/ou une [fieldAction] à un champ de formulaire.
/// Vous pouvez aussi ajouter un [fieldSuffix] à votre champ, sous la forme d'un widget.
///
/// Pour vos Validators, vous pouvez utiliser les fonctions de validation de [AuthValidator] et [FieldValidator] du package Core_Kosmos.
///
/// Exemple:
///
/// ![form_field_item](../../images/field/phone_number_field.png)
///
/// ```dart
/// FormPhoneNumberField(
///   fieldName: "Numéro de téléphone",
///   onChanged: (val) => printDebug(val),
///   hintText: "06 00 00 00 00",
/// ),
/// ```
///
/// Vous pouvez créer votre propre theme, ou définir celui par défaut via le [FormFieldThemeData] : "form_field".
///
class FormPhoneNumberField extends StatefulHookConsumerWidget {
  final bool isEnabled;
  final FocusNode? focusNode;
  final String? hintText;
  final bool isRequired;
  final String? Function(String?)? validator;
  final void Function(PhoneNumber)? onChanged;
  final PhoneNumber? initialValue;
  final AutovalidateMode autoValidateMode;
  final bool isError;
  final bool showErrorIcon;
  final bool showErrorTitle;
  final String? labelSearchBox;
  final String phoneKey;

  /// Item
  final String? fieldName;
  final String? fieldAction;
  final Widget? fieldSuffix;
  final VoidCallback? fieldActionOnTap;

  /// Theme
  final FormFieldThemeData? theme;
  final String? themeName;
  final InputDecoration? inputDecoration;

  const FormPhoneNumberField({
    super.key,
    this.isEnabled = true,
    this.focusNode,
    this.hintText,
    this.isRequired = false,
    this.validator,
    this.onChanged,
    this.initialValue,
    this.autoValidateMode = AutovalidateMode.disabled,
    this.isError = false,
    this.showErrorIcon = true,
    this.showErrorTitle = true,
    this.labelSearchBox,
    this.phoneKey = "AE",

    /// Item
    this.fieldName,
    this.fieldAction,
    this.fieldSuffix,
    this.fieldActionOnTap,

    /// Theme
    this.theme,
    this.themeName,
    this.inputDecoration,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FormPhoneNumberFieldState();
}

class _FormPhoneNumberFieldState extends ConsumerState<FormPhoneNumberField> {
  late PhoneNumber intialPhone =
      widget.initialValue ?? PhoneNumber(isoCode: widget.phoneKey);
  @override
  Widget build(BuildContext context) {
    final themeData = loadThemeData(
      widget.theme,
      widget.themeName ?? "form_field",
      () => const FormFieldThemeData(),
      isDark: ref.watch(isDarkModeProvider).isDarkMode,
    );
    final inputDecoration = (widget.inputDecoration ??
        themeData.inputDecoration ??
        kDefaultInputDecoration);

    return FormFieldItem(
      /// Theme configuration
      fieldName: (widget.fieldName == null && !widget.isRequired)
          ? null
          : "${widget.fieldName?.trim() ?? ""}${widget.isRequired ? "*" : ""}",
      fieldAction: widget.fieldAction,
      fieldActionOnTap: widget.fieldActionOnTap,
      fieldSuffix: widget.fieldSuffix,
      isError: widget.isError,
      showErrorTitle: widget.showErrorTitle,
      theme: themeData,

      child: InternationalPhoneNumberInput(
        autoValidateMode: widget.autoValidateMode,
        isEnabled: widget.isEnabled,
        focusNode: widget.focusNode,
        onInputChanged: widget.onChanged,
        validator: widget.validator,
        hintText: widget.hintText,
        // replace the default locale with the one provided
        locale: widget.phoneKey,
        initialValue: intialPhone,
        selectorConfig: const SelectorConfig(
          setSelectorButtonAsPrefixIcon: true,
          showFlags: true,
          useEmoji: true,
          
          leadingPadding: 15,
          selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
        ),
        searchBoxDecoration: InputDecoration(
          border: themeData.searchCountryBorder,
          labelStyle: themeData.searchCountryLabelStyle,
          label: Text(widget.labelSearchBox ??
              "package.ui-kosmos_v4.field.phone_number_field.search-label"
                  .tr()),
        ),
        textStyle: themeData.fieldTextStyle,
        selectorTextStyle: DefaultAppStyle.darkBlue(13, FontWeight.w500)
            .copyWith(
                color: themeData.fieldNameStyle?.color ??
                    themeData.fieldActionStyle?.color),
        spaceBetweenSelectorAndTextField: 0,
        errorMessage:
            "package.ui-kosmos_v4.field.phone_number_field.error_message".tr(),
        inputDecoration: inputDecoration.copyWith(
          hintText: widget.hintText,
          suffixIcon: widget.isError && widget.showErrorIcon
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      "assets/svg/ic_warning.svg",
                      package: "ui_kosmos_v4",
                      color: DefaultColor.error,
                      width: formatWidth(21),
                    )
                  ],
                )
              : null,
        ),
      ),
    );
  }
}
