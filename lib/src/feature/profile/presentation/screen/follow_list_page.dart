import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klozy/src/core/components/app_error_widget.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/components/ds_segmented_control.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/social/entity/follow_user.dart';
import 'package:klozy/src/feature/profile/presentation/bloc/follow_list_bloc.dart';
import 'package:klozy/src/feature/profile/presentation/bloc/follow_list_event.dart';
import 'package:klozy/src/feature/profile/presentation/bloc/follow_list_state.dart';
import 'package:klozy/src/feature/profile/presentation/widget/follow_user_row_widget.dart';
import 'package:klozy/src/router/app_router.dart';

@RoutePage()
class FollowListPage extends StatefulWidget implements AutoRouteWrapper {
  final String userId;
  final bool showFollowers;

  const FollowListPage({
    @PathParam('id') required this.userId,
    this.showFollowers = true,
    super.key,
  });

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<FollowListBloc>(
      create: (_) => locator<FollowListBloc>()..add(FollowListStarted(userId)),
      child: this,
    );
  }

  @override
  State<FollowListPage> createState() => _FollowListPageState();
}

class _FollowListPageState extends State<FollowListPage> {
  late int _index = widget.showFollowers ? 0 : 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColor.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 22),
          onPressed: () => context.router.maybePop(),
        ),
        title: Text(context.l10N.profile_connections_title),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: DSSegmentedControl(
              labels: <String>[
                context.l10N.profile_stat_followers,
                context.l10N.profile_stat_following,
              ],
              selectedIndex: _index,
              onChanged: (int i) => setState(() => _index = i),
            ),
          ),
          Expanded(
            child: BlocBuilder<FollowListBloc, FollowListState>(
              builder: (BuildContext context, FollowListState state) {
                return switch (state) {
                  FollowListLoadingState() => const DSLoader(),
                  FollowListErrorState(:final type) => AppErrorWidget(
                    type: type,
                    onRetry: () => context.read<FollowListBloc>().add(
                      FollowListStarted(widget.userId),
                    ),
                  ),
                  FollowListLoadedState() => _list(
                    context,
                    _index == 0 ? state.followers : state.following,
                  ),
                };
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _list(BuildContext context, List<FollowUser> users) {
    if (users.isEmpty) {
      return Center(
        child: Text(
          _index == 0
              ? context.l10N.profile_no_followers
              : context.l10N.profile_no_following,
          style: const TextStyle(
            fontFamily: dsFontFamily,
            fontSize: DSFontSize.bodyMedium,
            color: DSColor.onSurface45,
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: users.length,
      itemBuilder: (BuildContext context, int i) {
        final FollowUser u = users[i];
        return FollowUserRowWidget(
          user: u,
          onTap: () => context.router.push(UserProfileRoute(userId: u.id)),
          onToggleFollow: () =>
              context.read<FollowListBloc>().add(FollowListRowToggled(u.id)),
        );
      },
    );
  }
}
