import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klozy/src/app/bloc/account/account_bloc.dart';
import 'package:klozy/src/app/bloc/account/account_state.dart';
import 'package:klozy/src/core/account/guest_tab_placeholder_widget.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/domain/account/entity/account_status.dart';
import 'package:kosmos_chat/kosmos_chat.dart';

/// The Chat tab (shell index 2): hosts the package's conversation list.
///
/// The root [ProviderScope] (in App) supplies the Riverpod scope the package
/// widgets need; navigation into a thread is driven by MobileTchatController.
///
/// When the account resolves to guest, [GuestTabPlaceholderWidget] is shown
/// instead of the chat list to prompt sign-in.
@RoutePage()
class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountBloc, AccountState>(
      buildWhen: (AccountState previous, AccountState current) =>
          previous.runtimeType != current.runtimeType ||
          (current is AccountResolved &&
              previous is AccountResolved &&
              current.status != previous.status),
      builder: (BuildContext context, AccountState state) {
        if (state is AccountResolved && state.status == AccountStatus.guest) {
          return const GuestTabPlaceholderWidget();
        }
        if (state is AccountResolved) {
          return const Scaffold(
            backgroundColor: DSColor.surface,
            body: SafeArea(child: TchatListPage()),
          );
        }
        // AccountInitial or AccountResolving — show loader while bootstrapping.
        return const Scaffold(
          backgroundColor: DSColor.surface,
          body: DSLoader(),
        );
      },
    );
  }
}
