import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klozy/src/core/components/app_error_widget.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/notifications/entity/app_notification.dart';
import 'package:klozy/src/feature/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:klozy/src/feature/notifications/presentation/bloc/notifications_event.dart';
import 'package:klozy/src/feature/notifications/presentation/bloc/notifications_state.dart';
import 'package:klozy/src/feature/notifications/presentation/widget/notification_row_widget.dart';
import 'package:klozy/src/feature/notifications/presentation/widget/notification_skeleton_widget.dart';
import 'package:klozy/src/router/app_router.dart';

@RoutePage()
class NotificationsPage extends StatefulWidget implements AutoRouteWrapper {
  const NotificationsPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<NotificationsBloc>(
      create: (_) =>
          locator<NotificationsBloc>()..add(const NotificationsStarted()),
      child: this,
    );
  }

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final ScrollController _scrollController = ScrollController();
  Timer? _autoRead;
  bool _autoReadArmed = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 400) {
      context.read<NotificationsBloc>().add(const NotificationsLoadMore());
    }
  }

  // Mirrors the prototype: clear unread shortly after the list has LOADED —
  // arming the timer on page open silently no-oped whenever loading took
  // longer than the delay (the bloc drops ReadAll while not loaded).
  void _armAutoRead() {
    if (_autoReadArmed) return;
    _autoReadArmed = true;
    _autoRead = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        context.read<NotificationsBloc>().add(const NotificationsReadAll());
      }
    });
  }

  @override
  void dispose() {
    _autoRead?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _open(BuildContext context, AppNotification n) {
    context.read<NotificationsBloc>().add(NotificationMarkedRead(n.id));
    if (n.productId != null) {
      context.router.push(ProductRoute(id: n.productId!));
    } else if (n.orderId != null) {
      context.router.push(OrderDetailRoute(id: n.orderId!));
    } else if (n.userId != null) {
      context.router.push(UserProfileRoute(userId: n.userId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColor.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 22),
          onPressed: () => context.router.maybePop(),
        ),
        title: Text(context.l10N.notifications_title),
        actions: <Widget>[
          TextButton(
            onPressed: () => context.read<NotificationsBloc>().add(
              const NotificationsReadAll(),
            ),
            child: Text(
              context.l10N.notifications_read_all,
              style: const TextStyle(
                fontFamily: dsFontFamily,
                fontSize: DSFontSize.bodyMedium,
                fontWeight: DSFontWeight.medium,
                color: DSColor.primary,
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<NotificationsBloc, NotificationsState>(
        listenWhen: (NotificationsState previous, NotificationsState current) =>
            current is NotificationsLoadedState,
        listener: (BuildContext context, NotificationsState state) =>
            _armAutoRead(),
        builder: (BuildContext context, NotificationsState state) {
          return switch (state) {
            NotificationsLoadingState() => const NotificationSkeletonWidget(),
            NotificationsErrorState(:final type) => AppErrorWidget(
              type: type,
              onRetry: () => context.read<NotificationsBloc>().add(
                const NotificationsStarted(),
              ),
            ),
            NotificationsLoadedState() =>
              state.isEmpty ? _Empty() : _grouped(context, state.items),
          };
        },
      ),
    );
  }

  Widget _grouped(BuildContext context, List<AppNotification> items) {
    final now = DateTime.now();
    bool isToday(DateTime? d) =>
        d != null &&
        d.year == now.year &&
        d.month == now.month &&
        d.day == now.day;
    final today = items.where((AppNotification n) => isToday(n.createdAt));
    final earlier = items.where((AppNotification n) => !isToday(n.createdAt));
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: <Widget>[
        if (today.isNotEmpty) _header(context.l10N.notifications_group_today),
        ...today.map(_row),
        if (earlier.isNotEmpty)
          _header(context.l10N.notifications_group_earlier),
        ...earlier.map(_row),
      ],
    );
  }

  Widget _header(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 12, 2, 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontFamily: dsFontFamily,
          fontSize: DSFontSize.bodySmall,
          fontWeight: DSFontWeight.semiBold,
          letterSpacing: 0.6,
          color: DSColor.onSurface45,
        ),
      ),
    );
  }

  Widget _row(AppNotification n) {
    return NotificationRowWidget(
      notification: n,
      onTap: () => _open(context, n),
      onDelete: () =>
          context.read<NotificationsBloc>().add(NotificationRemoved(n.id)),
    );
  }
}

class _Empty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.notifications_none_rounded,
            size: 40,
            color: DSColor.onSurface35,
          ),
          const SizedBox(height: 12),
          Text(
            context.l10N.notifications_empty,
            style: const TextStyle(
              fontFamily: dsFontFamily,
              fontSize: DSFontSize.bodyLarge,
              fontWeight: DSFontWeight.medium,
              color: DSColor.onSurface60,
            ),
          ),
        ],
      ),
    );
  }
}
