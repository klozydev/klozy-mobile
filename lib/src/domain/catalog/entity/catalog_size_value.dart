import 'package:equatable/equatable.dart';

/// A size facet token (e.g. token "M" or "EU 42", with a display label).
///
/// Shoe (and other region-scoped) sizes carry a [systemLabels] map keyed by
/// size system — e.g. `{'EU': '42', 'US': '9', 'UK': '8'}` — so the same
/// underlying [token] can be rendered in whichever representation the user has
/// selected. Region-agnostic sizes (clothing: S/M/L…) leave [systemLabels]
/// null and always render their plain [label].
class CatalogSizeValue extends Equatable {
  final String token;
  final String label;
  final Map<String, String>? systemLabels;

  const CatalogSizeValue({
    required this.token,
    required this.label,
    this.systemLabels,
  });

  /// Whether this size has more than one regional representation (i.e. the
  /// EU/UK/US selector is meaningful for it).
  bool get isRegional => (systemLabels?.length ?? 0) > 1;

  /// The label to display for the given size [system] (e.g. `'EU'`, `'US'`,
  /// `'UK'`), falling back to the plain [label] when there is no region-specific
  /// representation.
  String labelFor(String system) =>
      systemLabels?[system.toUpperCase()] ?? label;

  @override
  List<Object?> get props => [token, label, systemLabels];
}
