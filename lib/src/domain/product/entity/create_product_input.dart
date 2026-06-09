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
  final num? weightGrams;
  final List<String> images;
  final String? location;

  const CreateProductInput({
    required this.title,
    required this.price,
    required this.conditionId,
    required this.categoryId,
    this.description,
    this.size,
    this.brandId,
    this.brandName,
    this.weightGrams,
    this.images = const <String>[],
    this.location,
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
    if (weightGrams != null && weightGrams! > 0) 'weightGrams': weightGrams,
    if (images.isNotEmpty) 'images': images,
    if (location != null && location!.isNotEmpty) 'location': location,
  };
}
