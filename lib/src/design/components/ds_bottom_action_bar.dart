import 'package:flutter/material.dart';

import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';

/// Variantes contextuelles de la [DSBottomActionBar].
///
/// - [buyer]  : Acheter (primary) + Faire une offre (secondary dark)
/// - [owner]  : Supprimer (danger outline) + Modifier (primary)
/// - [sold]   : Déjà Vendu (disabled, single, full-width)
enum DSBottomActionBarVariant { buyer, owner, sold }

/// [DSBottomActionBar] — barre d'actions fixe en bas de la page produit.
///
/// Respecte la safe-area via [SafeArea]. Toujours fixée via [Positioned] ou
/// [bottomNavigationBar] du [Scaffold].
///
/// Deux boutons côte à côte (buyer/owner) ou bouton unique désactivé (sold).
/// La variante s'adapte au contexte sans logique dans l'écran parent.
///
/// Tokens :
/// - primary btn   : [DSColor.primary] bg · [DSColor.surface] text · radius 14
/// - secondary btn : [DSColor.lowBlack] bg · [DSColor.onSurface24] border
/// - danger btn    : transparent bg · [DSColor.danger] border + text · 1.5 px
/// - disabled btn  : [DSColor.lowBlack] bg · [DSColor.onSurface24] text
/// - height buttons: 50 px
/// - horizontal gap between buttons: [DSSpacing.xxs+2] (10 px)
/// - padding h     : [DSSpacing.s] (16)
/// - padding top   : [DSSpacing.xs] (12)
class DSBottomActionBar extends StatelessWidget {
  final DSBottomActionBarVariant variant;
  final VoidCallback? onPrimaryTap;
  final VoidCallback? onSecondaryTap;

  const DSBottomActionBar({
    super.key,
    required this.variant,
    this.onPrimaryTap,
    this.onSecondaryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: DSColor.surface,
        border: Border(top: BorderSide(color: DSColor.onSurface10, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            DSSpacing.s,
            DSSpacing.xs,
            DSSpacing.s,
            DSSpacing.xs,
          ),
          child: _buildButtons(),
        ),
      ),
    );
  }

  Widget _buildButtons() {
    switch (variant) {
      case DSBottomActionBarVariant.buyer:
        return Row(
          children: [
            Expanded(
              child: _PrimaryBtn(label: 'Acheter', onTap: onPrimaryTap),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SecondaryBtn(
                label: 'Faire une offre',
                onTap: onSecondaryTap,
              ),
            ),
          ],
        );

      case DSBottomActionBarVariant.owner:
        return Row(
          children: [
            Expanded(
              child: _DangerBtn(label: 'Supprimer', onTap: onSecondaryTap),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _PrimaryBtn(
                label: 'Modifier',
                icon: Icons.edit_outlined,
                onTap: onPrimaryTap,
              ),
            ),
          ],
        );

      case DSBottomActionBarVariant.sold:
        return const SizedBox(
          width: double.infinity,
          height: 50,
          child: _DisabledBtn(label: 'Déjà Vendu'),
        );
    }
  }
}

// ── Private button variants ───────────────────────────────────────────────

const _kBtnStyle = TextStyle(
  fontFamily: dsFontFamily,
  fontSize: 15,
  fontWeight: DSFontWeight.semiBold,
  letterSpacing: -0.01,
);

class _PrimaryBtn extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  const _PrimaryBtn({required this.label, this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: DSColor.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: DSColor.surface),
              const SizedBox(width: 7),
            ],
            Text(label, style: _kBtnStyle.copyWith(color: DSColor.surface)),
          ],
        ),
      ),
    );
  }
}

class _SecondaryBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const _SecondaryBtn({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: DSColor.lowBlack,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: DSColor.onSurface24, width: 0.5),
        ),
        child: Center(
          child: Text(
            label,
            style: _kBtnStyle.copyWith(color: DSColor.onSurface85),
          ),
        ),
      ),
    );
  }
}

class _DangerBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const _DangerBtn({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: DSColor.danger, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.delete_outline_rounded,
              size: 16,
              color: DSColor.danger,
            ),
            const SizedBox(width: 7),
            Text(label, style: _kBtnStyle.copyWith(color: DSColor.danger)),
          ],
        ),
      ),
    );
  }
}

class _DisabledBtn extends StatelessWidget {
  final String label;
  const _DisabledBtn({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DSColor.lowBlack,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DSColor.onSurface10, width: 0.5),
      ),
      child: Center(
        child: Text(
          label,
          style: _kBtnStyle.copyWith(color: DSColor.onSurface24),
        ),
      ),
    );
  }
}
