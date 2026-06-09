import 'package:equatable/equatable.dart';

/// Payload for `PUT /v1/me/preferences` (UpdatePreferencesDto).
class PreferencesInput extends Equatable {
  final String sizeSystem; // EU | US | UK
  final List<String> sizes;
  final List<String> categoryIds;
  final List<String> brandIds;

  const PreferencesInput({
    this.sizeSystem = 'EU',
    this.sizes = const <String>[],
    this.categoryIds = const <String>[],
    this.brandIds = const <String>[],
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
    'sizeSystem': sizeSystem,
    'sizes': sizes,
    'categoryIds': categoryIds,
    'brandIds': brandIds,
  };

  @override
  List<Object?> get props => [sizeSystem, sizes, categoryIds, brandIds];
}
