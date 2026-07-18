import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klozy/src/app/bloc/account/account_bloc.dart';
import 'package:klozy/src/app/bloc/account/account_state.dart';
import 'package:klozy/src/app/notifications/notifications_cubit.dart';
import 'package:klozy/src/core/account/account_gate.dart';
import 'package:klozy/src/core/account/account_gate_sheet.dart';
import 'package:klozy/src/core/components/app_error_widget.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/core/navigation/safe_navigation.dart';
import 'package:klozy/src/design/components/ds_bottom_sheet.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/account/entity/account_status.dart';
import 'package:klozy/src/domain/social/entity/profile_reel.dart';
import 'package:klozy/src/feature/chat/entry/chat_launcher.dart';
import 'package:klozy/src/feature/profile/presentation/bloc/profile_bloc.dart';
import 'package:klozy/src/feature/profile/presentation/bloc/profile_event.dart';
import 'package:klozy/src/feature/profile/presentation/bloc/profile_state.dart';
import 'package:klozy/src/feature/profile/presentation/bloc/profile_tab.dart';
import 'package:klozy/src/feature/profile/presentation/widget/profile_actions_widget.dart';
import 'package:klozy/src/feature/profile/presentation/widget/profile_circle_button.dart';
import 'package:klozy/src/feature/profile/presentation/widget/profile_header_widget.dart';
import 'package:klozy/src/feature/profile/presentation/widget/profile_menu_sheet.dart';
import 'package:klozy/src/feature/profile/presentation/widget/profile_products_sliver_grid.dart';
import 'package:klozy/src/feature/profile/presentation/widget/profile_reels_sliver_grid.dart';
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

  /// Runs [onValid] when the account is valid; for an incomplete onboarding
  /// it funnels the user into the completion flow via [AccountGateSheet].
  void _guardedOwnerAction(
    BuildContext context, {
    required VoidCallback onValid,
  }) {
    final AccountState accountState = context.read<AccountBloc>().state;
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
        elevation: 0,
        actions: <Widget>[
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (BuildContext context, ProfileState state) {
              if (state is! ProfileLoadedState) {
                return const SizedBox.shrink();
              }
              final List<Widget> buttons = state.profile.isMe
                  ? <Widget>[
                      ProfileCircleButton(
                        icon: Icons.shopping_bag_outlined,
                        onTap: () => _guardedOwnerAction(
                          context,
                          onValid: () =>
                              context.router.pushSafe(const OrdersRoute()),
                        ),
                      ),
                      BlocBuilder<NotificationsCubit, int>(
                        bloc: locator<NotificationsCubit>(),
                        builder: (BuildContext context, int unread) {
                          return ProfileCircleButton(
                            icon: Icons.notifications_none_rounded,
                            showBadge: unread > 0,
                            onTap: () => _guardedOwnerAction(
                              context,
                              onValid: () => context.router.pushSafe(
                                const NotificationsRoute(),
                              ),
                            ),
                          );
                        },
                      ),
                      ProfileCircleButton(
                        icon: Icons.settings_outlined,
                        onTap: () => _guardedOwnerAction(
                          context,
                          onValid: () =>
                              context.router.pushSafe(const SettingsRoute()),
                        ),
                      ),
                    ]
                  : <Widget>[
                      ProfileCircleButton(
                        icon: Icons.more_horiz,
                        onTap: () => _openMenu(context),
                      ),
                    ];
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    for (int i = 0; i < buttons.length; i++) ...<Widget>[
                      if (i > 0) const SizedBox(width: 10),
                      buttons[i],
                    ],
                  ],
                ),
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
                onFollowers: () => context.router.pushSafe(
                  FollowListRoute(userId: profile.id, showFollowers: true),
                ),
                onFollowing: () => context.router.pushSafe(
                  FollowListRoute(userId: profile.id, showFollowers: false),
                ),
                onRatingTap: () {},
              ),
            ),
            if (!profile.isMe)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                  child: ProfileActionsWidget(
                    profile: profile,
                    onFollow: () => locator<AccountGate>().guard(
                      context,
                      onAllowed: () => context.read<ProfileBloc>().add(
                        const ProfileFollowToggled(),
                      ),
                    ),
                    onMessage: () => context.openChatWith(
                      profile.id,
                      displayName: profile.displayName,
                      avatarUrl: profile.avatarUrl,
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
              _ProductsTabContent(state: state),
              _ReelsTabContent(state: state),
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

/// Bottom-of-list loading affordance shown while a "load more" fetch is in
/// flight. Mirrors the Feed tab's inline sliver spinner.
const Widget _kLoadMoreSliver = SliverToBoxAdapter(
  child: Padding(
    padding: EdgeInsets.symmetric(vertical: DSSpacing.s),
    child: DSLoader(size: 22),
  ),
);

/// Products tab: scrollable + pull-to-refresh + infinite scroll.
class _ProductsTabContent extends StatefulWidget {
  final ProfileLoadedState state;

  const _ProductsTabContent({required this.state});

  @override
  State<_ProductsTabContent> createState() => _ProductsTabContentState();
}

class _ProductsTabContentState extends State<_ProductsTabContent> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  void _onScroll() {
    if (!widget.state.productsHasMore || widget.state.productsLoadingMore) {
      return;
    }
    if (_controller.position.pixels >=
        _controller.position.maxScrollExtent - 300) {
      context.read<ProfileBloc>().add(const ProfileProductsLoadMore());
    }
  }

  Future<void> _onRefresh() async {
    final ProfileBloc bloc = context.read<ProfileBloc>();
    // Wait for the refresh to actually settle (a ProfileLoadedState that is no
    // longer loading more products), with a timeout so the indicator can
    // never get stuck if no further state is emitted.
    final Future<ProfileState> settled = bloc.stream
        .firstWhere(
          (ProfileState s) => s is ProfileLoadedState && !s.productsLoadingMore,
        )
        .timeout(const Duration(seconds: 10), onTimeout: () => bloc.state);
    bloc.add(const ProfilePullToRefresh());
    await settled;
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: DSColor.primary,
      backgroundColor: DSColor.card,
      onRefresh: _onRefresh,
      child: CustomScrollView(
        controller: _controller,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: <Widget>[
          ProfileProductsSliverGrid(products: widget.state.products),
          if (widget.state.productsLoadingMore) _kLoadMoreSliver,
        ],
      ),
    );
  }
}

/// Reels tab: scrollable + pull-to-refresh + infinite scroll.
class _ReelsTabContent extends StatefulWidget {
  final ProfileLoadedState state;

  const _ReelsTabContent({required this.state});

  @override
  State<_ReelsTabContent> createState() => _ReelsTabContentState();
}

class _ReelsTabContentState extends State<_ReelsTabContent> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  void _onScroll() {
    if (!widget.state.reelsHasMore || widget.state.reelsLoadingMore) {
      return;
    }
    if (_controller.position.pixels >=
        _controller.position.maxScrollExtent - 300) {
      context.read<ProfileBloc>().add(const ProfileReelsLoadMore());
    }
  }

  Future<void> _onRefresh() async {
    final ProfileBloc bloc = context.read<ProfileBloc>();
    final Future<ProfileState> settled = bloc.stream
        .firstWhere(
          (ProfileState s) => s is ProfileLoadedState && !s.reelsLoadingMore,
        )
        .timeout(const Duration(seconds: 10), onTimeout: () => bloc.state);
    bloc.add(const ProfilePullToRefresh());
    await settled;
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.state.tabLoading && widget.state.reels == null) {
      return const DSLoader();
    }
    final List<ProfileReel> reels = widget.state.reels ?? const <ProfileReel>[];
    return RefreshIndicator(
      color: DSColor.primary,
      backgroundColor: DSColor.card,
      onRefresh: _onRefresh,
      child: CustomScrollView(
        controller: _controller,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: <Widget>[
          ProfileReelsSliverGrid(
            reels: reels,
            onTap: (ProfileReel reel) => context.router.pushSafe(
              SingleReelRoute(
                reelId: reel.id,
                reelIds: reels.map((ProfileReel r) => r.id).toList(),
                initialIndex: reels.indexOf(reel),
              ),
            ),
          ),
          if (widget.state.reelsLoadingMore) _kLoadMoreSliver,
        ],
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
