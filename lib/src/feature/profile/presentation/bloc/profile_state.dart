import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/domain/product/entity/product.dart';
import 'package:klozy/src/domain/social/entity/profile_reel.dart';
import 'package:klozy/src/domain/social/entity/social_profile.dart';
import 'package:klozy/src/domain/social/entity/user_review.dart';
import 'package:klozy/src/feature/profile/presentation/bloc/profile_tab.dart';

@immutable
sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

final class ProfileLoadingState extends ProfileState {
  const ProfileLoadingState();
}

final class ProfileErrorState extends ProfileState {
  final AppErrorType type;

  const ProfileErrorState({required this.type});

  @override
  List<Object?> get props => [type];
}

final class ProfileLoadedState extends ProfileState {
  final SocialProfile profile;
  final ProfileTab tab;
  final List<Product> products;
  final List<ProfileReel>? reels;
  final List<UserReview>? reviews;
  final bool tabLoading;
  final bool productsHasMore;
  final bool productsLoadingMore;
  final bool reelsHasMore;
  final bool reelsLoadingMore;

  const ProfileLoadedState({
    required this.profile,
    this.tab = ProfileTab.products,
    this.products = const <Product>[],
    this.reels,
    this.reviews,
    this.tabLoading = false,
    this.productsHasMore = true,
    this.productsLoadingMore = false,
    this.reelsHasMore = true,
    this.reelsLoadingMore = false,
  });

  ProfileLoadedState copyWith({
    SocialProfile? profile,
    ProfileTab? tab,
    List<Product>? products,
    List<ProfileReel>? reels,
    List<UserReview>? reviews,
    bool? tabLoading,
    bool? productsHasMore,
    bool? productsLoadingMore,
    bool? reelsHasMore,
    bool? reelsLoadingMore,
  }) {
    return ProfileLoadedState(
      profile: profile ?? this.profile,
      tab: tab ?? this.tab,
      products: products ?? this.products,
      reels: reels ?? this.reels,
      reviews: reviews ?? this.reviews,
      tabLoading: tabLoading ?? this.tabLoading,
      productsHasMore: productsHasMore ?? this.productsHasMore,
      productsLoadingMore: productsLoadingMore ?? this.productsLoadingMore,
      reelsHasMore: reelsHasMore ?? this.reelsHasMore,
      reelsLoadingMore: reelsLoadingMore ?? this.reelsLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
    profile,
    tab,
    products,
    reels,
    reviews,
    tabLoading,
    productsHasMore,
    productsLoadingMore,
    reelsHasMore,
    reelsLoadingMore,
  ];
}
