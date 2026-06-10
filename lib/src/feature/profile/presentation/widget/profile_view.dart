import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klozy/src/core/components/app_error_widget.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_bottom_sheet.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/components/ds_segmented_control.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/social/entity/profile_reel.dart';
import 'package:klozy/src/feature/profile/presentation/bloc/profile_bloc.dart';
import 'package:klozy/src/feature/profile/presentation/bloc/profile_event.dart';
import 'package:klozy/src/feature/profile/presentation/bloc/profile_state.dart';
import 'package:klozy/src/feature/profile/presentation/bloc/profile_tab.dart';
import 'package:klozy/src/feature/profile/presentation/widget/profile_actions_widget.dart';
import 'package:klozy/src/feature/profile/presentation/widget/profile_header_widget.dart';
import 'package:klozy/src/feature/profile/presentation/widget/profile_menu_sheet.dart';
import 'package:klozy/src/feature/profile/presentation/widget/profile_products_grid.dart';
import 'package:klozy/src/feature/profile/presentation/widget/profile_reels_grid.dart';
import 'package:klozy/src/feature/profile/presentation/widget/profile_reviews_list.dart';
import 'package:klozy/src/router/app_router.dart';

/// Profile UI shared by the self tab and public user pages.
class ProfileView extends StatelessWidget {
  final String? userId;

  const ProfileView({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileBloc>(
      create: (_) =>
          locator<ProfileBloc>()..add(ProfileStarted(userId: userId)),
      child: const _ProfileScaffold(),
    );
  }
}

class _ProfileScaffold extends StatelessWidget {
  const _ProfileScaffold();

  void _openMenu(BuildContext context) {
    final bloc = context.read<ProfileBloc>();
    DSBottomSheet.show<void>(
      context,
      child: ProfileMenuSheet(
        onReport: () {
          Navigator.of(context).maybePop();
          bloc.add(const ProfileReported());
          context.showSnackBar(context.l10N.profile_reported);
        },
        onBlock: () {
          Navigator.of(context).maybePop();
          bloc.add(const ProfileBlocked());
          context.showSnackBar(context.l10N.profile_blocked);
          context.router.maybePop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColor.surface,
      appBar: AppBar(
        actions: <Widget>[
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (BuildContext context, ProfileState state) {
              if (state is! ProfileLoadedState || state.profile.isMe) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.more_horiz),
                onPressed: () => _openMenu(context),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (BuildContext context, ProfileState state) {
          return switch (state) {
            ProfileLoadingState() => const DSLoader(),
            ProfileErrorState(:final type) => AppErrorWidget(
              type: type,
              onRetry: () =>
                  context.read<ProfileBloc>().add(const ProfileStarted()),
            ),
            ProfileLoadedState() => _Body(state: state),
          };
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final ProfileLoadedState state;

  const _Body({required this.state});

  @override
  Widget build(BuildContext context) {
    final profile = state.profile;
    return ListView(
      padding: const EdgeInsets.only(top: 8),
      children: <Widget>[
        ProfileHeaderWidget(
          profile: profile,
          onFollowers: () => context.router.push(
            FollowListRoute(userId: profile.id, showFollowers: true),
          ),
          onFollowing: () => context.router.push(
            FollowListRoute(userId: profile.id, showFollowers: false),
          ),
          onRatingTap: () => context.read<ProfileBloc>().add(
            const ProfileTabChanged(ProfileTab.reviews),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: ProfileActionsWidget(
            profile: profile,
            onFollow: () =>
                context.read<ProfileBloc>().add(const ProfileFollowToggled()),
            onMessage: () =>
                context.showSnackBar(context.l10N.profile_message_coming_soon),
            onEdit: () => context.router.push(const EditProfileRoute()),
            onOrders: () => context.router.push(const OrdersRoute()),
            onNotifications: () =>
                context.router.push(const NotificationsRoute()),
            onSettings: () => context.router.push(const SettingsRoute()),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: DSSegmentedControl(
            labels: <String>[
              context.l10N.profile_tab_products,
              context.l10N.profile_tab_reels,
              context.l10N.profile_tab_reviews,
            ],
            selectedIndex: ProfileTab.values.indexOf(state.tab),
            onChanged: (int i) => context.read<ProfileBloc>().add(
              ProfileTabChanged(ProfileTab.values[i]),
            ),
          ),
        ),
        if (state.tabLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: DSLoader(),
          )
        else
          _tabBody(context),
      ],
    );
  }

  Widget _tabBody(BuildContext context) {
    switch (state.tab) {
      case ProfileTab.products:
        return ProfileProductsGrid(products: state.products);
      case ProfileTab.reels:
        return ProfileReelsGrid(
          reels: state.reels ?? const [],
          onTap: (ProfileReel reel) =>
              context.router.push(SingleReelRoute(reelId: reel.id)),
        );
      case ProfileTab.reviews:
        return ProfileReviewsList(
          profile: state.profile,
          reviews: state.reviews ?? const [],
        );
    }
  }
}
