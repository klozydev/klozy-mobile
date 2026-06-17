/// Payload for `POST /v1/products` (CreateProductDto).
class CreateProductInput {
  final String title;
  final num price;
  final String conditionId;
  final String categoryId;
  final String? description;
  final String? size;
  final String? brandId;
  final String? brandName;
  final List<String> images;
  final String? location;

  /// AI-generated per-locale `{title, description}` drafts.
  final Map<String, dynamic>? translations;

  const CreateProductInput({
    required this.title,
    required this.price,
    required this.conditionId,
    required this.categoryId,
    this.description,
    this.size,
    this.brandId,
    this.brandName,
    this.images = const <String>[],
    this.location,
    this.translations,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
    'title': title,
    'price': price,
    'conditionId': conditionId,
    'categoryId': categoryId,
    if (description != null && description!.isNotEmpty)
      'description': description,
    if (size != null && size!.isNotEmpty) 'size': size,
    if (brandId != null && brandId!.isNotEmpty) 'brandId': brandId,
    if (brandName != null && brandName!.isNotEmpty) 'brandName': brandName,
    if (images.isNotEmpty) 'images': images,
    if (location != null && location!.isNotEmpty) 'location': location,
    if (translations != null && translations!.isNotEmpty)
      'translations': translations,
  };
}
