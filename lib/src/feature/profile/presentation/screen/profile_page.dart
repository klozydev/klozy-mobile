import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klozy/src/app/bloc/account/account_bloc.dart';
import 'package:klozy/src/app/bloc/account/account_state.dart';
import 'package:klozy/src/core/account/guest_tab_placeholder_widget.dart';
import 'package:klozy/src/core/account/incomplete_profile_placeholder_widget.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/domain/account/entity/account_status.dart';
import 'package:klozy/src/feature/profile/presentation/widget/profile_view.dart';

/// The Profile tab — my own profile.
///
/// When the account resolves to guest, [GuestTabPlaceholderWidget] is shown
/// instead of the profile to prompt sign-in.
@RoutePage()
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
        if (state is AccountResolved &&
            state.status == AccountStatus.incompleteOnboarding) {
          // A half-set-up account has no usable profile to render — prompt the
          // user to finish setup instead of showing a blank Account tab.
          return const IncompleteProfilePlaceholderWidget();
        }
        if (state is AccountResolved) {
          return const ProfileView();
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
