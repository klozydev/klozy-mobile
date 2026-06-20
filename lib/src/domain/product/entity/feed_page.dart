import 'package:klozy/src/domain/product/entity/product.dart';

/// A page of feed products plus the "Picked for you" labels (preferred category
/// names derived from the signed-in user's preferences). The feed endpoint
/// returns these alongside the product page; they drive the subtle "Picked for
/// you · …" hint shown above the grid on the All tab.
class FeedPage {
  final List<Product> data;
  final List<String> pickedForYou;

  const FeedPage({required this.data, this.pickedForYou = const <String>[]});
}
