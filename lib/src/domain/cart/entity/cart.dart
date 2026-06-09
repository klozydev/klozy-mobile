import 'package:equatable/equatable.dart';
import 'package:klozy/src/domain/cart/entity/cart_bucket.dart';

class Cart extends Equatable {
  final List<CartBucket> buckets;

  const Cart({this.buckets = const <CartBucket>[]});

  static const Cart empty = Cart();

  bool get isEmpty => buckets.isEmpty;

  int get itemCount =>
      buckets.fold(0, (int sum, CartBucket b) => sum + b.items.length);

  @override
  List<Object?> get props => [buckets];
}
