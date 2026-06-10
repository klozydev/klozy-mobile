import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klozy/src/app/bloc/account/account_bloc.dart';
import 'package:klozy/src/app/bloc/account/account_state.dart';
import 'package:klozy/src/core/account/account_gate.dart';
import 'package:klozy/src/core/account/account_gate_sheet.dart';
import 'package:klozy/src/core/components/app_error_widget.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_bottom_sheet.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/account/entity/account_status.dart';
import 'package:klozy/src/domain/social/entity/profile_reel.dart';
import 'package:klozy/src/feature/chat/entry/chat_launcher.dart';
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
import 'package:klozy/src/feature/profile/presentation/widget/profile_tab_bar_widget.dart';
import 'package:klozy/src/router/app_router.dart';

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
    final ProfileBloc bloc = context.read<ProfileBloc>();
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
        backgroundColor: DSColor.surface,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () => context.router.push(const CartRoute()),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.router.push(const NotificationsRoute()),
          ),
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
            ProfileLoadedState() => _ProfileBody(initialState: state),
          };
        },
      ),
    );
  }
}

class _ProfileBody extends StatefulWidget {
  final ProfileLoadedState initialState;

  const _ProfileBody({required this.initialState});

  @override
  State<_ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<_ProfileBody>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  /// Runs [onValid] when the account is [AccountStatus.valid]; for
  /// [AccountStatus.incompleteOnboarding] shows [AccountGateSheet] so the
  /// user is funnelled into the completion flow instead of hitting a silent
  /// guard redirect.
  void _guardedOwnerAction(
    BuildContext context, {
    required VoidCallback onValid,
  }) {
    final accountState = context.read<AccountBloc>().state;
    if (accountState is AccountResolved &&
        accountState.status == AccountStatus.incompleteOnboarding) {
      AccountGateSheet.show(
        context,
        status: AccountStatus.incompleteOnboarding,
      );
      return;
    }
    onValid();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: ProfileTab.values.indexOf(widget.initialState.tab),
    );
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final ProfileTab tab = ProfileTab.values[_tabController.index];
    context.read<ProfileBloc>().add(ProfileTabChanged(tab));
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (BuildContext context, ProfileState state) {
        if (state is! ProfileLoadedState) return const DSLoader();
        final profile = state.profile;
        return NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool _) => <Widget>[
            SliverToBoxAdapter(
              child: ProfileHeaderWidget(
                profile: profile,
                onFollowers: () => context.router.push(
                  FollowListRoute(userId: profile.id, showFollowers: true),
                ),
                onFollowing: () => context.router.push(
                  FollowListRoute(userId: profile.id, showFollowers: false),
                ),
                onRatingTap: () {},
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: ProfileActionsWidget(
                  profile: profile,
                  onFollow: () => locator<AccountGate>().guard(
                    context,
                    onAllowed: () => context.read<ProfileBloc>().add(
                      const ProfileFollowToggled(),
                    ),
                  ),
                  onMessage: () => context.openChatWith(profile.id),
                  onEdit: () => _guardedOwnerAction(
                    context,
                    onValid: () =>
                        context.router.push(const EditProfileRoute()),
                  ),
                  onOrders: () => _guardedOwnerAction(
                    context,
                    onValid: () => context.router.push(const OrdersRoute()),
                  ),
                  onNotifications: () => _guardedOwnerAction(
                    context,
                    onValid: () =>
                        context.router.push(const NotificationsRoute()),
                  ),
                  onSettings: () => _guardedOwnerAction(
                    context,
                    onValid: () => context.router.push(const SettingsRoute()),
                  ),
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(tabController: _tabController),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: <Widget>[
              SingleChildScrollView(
                child: ProfileProductsGrid(products: state.products),
              ),
              _ReelTabContent(state: state),
              _ReviewTabContent(state: state),
            ],
          ),
        );
      },
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;

  const _TabBarDelegate({required this.tabController});

  @override
  double get minExtent => 48;

  @override
  double get maxExtent => 48;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: DSColor.surface,
      child: ProfileTabBarWidget(tabController: tabController),
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate old) => false;
}

class _ReelTabContent extends StatelessWidget {
  final ProfileLoadedState state;

  const _ReelTabContent({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.tabLoading && state.reels == null) {
      return const DSLoader();
    }
    return SingleChildScrollView(
      child: ProfileReelsGrid(
        reels: state.reels ?? const <ProfileReel>[],
        onTap: (ProfileReel reel) =>
            context.router.push(SingleReelRoute(reelId: reel.id)),
      ),
    );
  }
}

class _ReviewTabContent extends StatelessWidget {
  final ProfileLoadedState state;

  const _ReviewTabContent({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.tabLoading && state.reviews == null) {
      return const DSLoader();
    }
    return SingleChildScrollView(
      child: ProfileReviewsList(
        profile: state.profile,
        reviews: state.reviews ?? const [],
      ),
    );
  }
}
