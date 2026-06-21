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
  Timer? _autoRead;

  @override
  void initState() {
    super.initState();
    // Mirrors the prototype's read pass: after a brief beat the unread items
    // are marked read and their highlights/dots fade out together (the row
    // widget animates the transition).
    _autoRead = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) {
        context.read<NotificationsBloc>().add(const NotificationsReadAll());
      }
    });
  }

  @override
  void dispose() {
    _autoRead?.cancel();
    super.dispose();
  }

  void _open(BuildContext context, AppNotification n) {
    context.read<NotificationsBloc>().add(NotificationMarkedRead(n.id));
    if (n.conversationId != null) {
      context.router.push(ChatThreadRoute(conversationId: n.conversationId!));
    } else if (n.productId != null) {
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
      body: BlocBuilder<NotificationsBloc, NotificationsState>(
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
              state.isEmpty ? _Empty() : _list(context, state.items),
          };
        },
      ),
    );
  }

  // Flat, chronological list — the prototype shows no date-group headers.
  Widget _list(BuildContext context, List<AppNotification> items) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int i) {
        final AppNotification n = items[i];
        return NotificationRowWidget(
          notification: n,
          onTap: () => _open(context, n),
          onDelete: () =>
              context.read<NotificationsBloc>().add(NotificationRemoved(n.id)),
        );
      },
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
