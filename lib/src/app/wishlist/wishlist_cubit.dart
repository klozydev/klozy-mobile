import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/domain/wishlist/wishlist_repository.dart';

/// App-wide set of wishlisted product ids — the single source of truth for the
/// heart state across Feed, Wishlist, Reels, Product detail and Profile.
/// Toggles are optimistic and reverted if the API call fails.
@lazySingleton
class WishlistCubit extends Cubit<Set<String>> {
  final WishlistRepository _repository;

  WishlistCubit(this._repository) : super(const <String>{});

  bool isWished(String id) => state.contains(id);

  Future<void> load() async {
    try {
      emit(await _repository.getWishlistProductIds());
    } catch (_) {
      // Keep whatever we have; the toggle still works optimistically.
    }
  }

  Future<void> toggle(String id) async {
    final wasWished = state.contains(id);
    final optimistic = Set<String>.from(state);
    wasWished ? optimistic.remove(id) : optimistic.add(id);
    emit(optimistic);

    try {
      if (wasWished) {
        await _repository.remove(id);
      } else {
        await _repository.add(id);
      }
    } catch (_) {
      final reverted = Set<String>.from(state);
      wasWished ? reverted.add(id) : reverted.remove(id);
      emit(reverted);
    }
  }
}
