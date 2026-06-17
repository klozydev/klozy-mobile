import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/core/account/account_gate.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/sell/usecase/check_sell_prerequisite_usecase.dart';
import 'package:klozy/src/domain/sell/usecase/sell_prerequisite.dart';
import 'package:klozy/src/feature/shell/presentation/widget/shell_bottom_nav_widget.dart';
import 'package:klozy/src/router/app_router.dart';

/// Root authenticated shell — hosts the four bottom-nav tabs (Home, Search,
/// Chat, Profile) and the center Sell FAB (which pushes the sell flow).
@RoutePage()
class ShellPage extends StatelessWidget {
  const ShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsScaffold(
      backgroundColor: DSColor.surface,
      routes: const <PageRouteInfo>[
        HomeRoute(),
        SearchRoute(),
        ChatRoute(),
        ProfileRoute(),
      ],
      bottomNavigationBuilder: (_, TabsRouter tabsRouter) {
        return ShellBottomNavWidget(
          activeIndex: tabsRouter.activeIndex,
          onTab: tabsRouter.setActiveIndex,
          onSell: () => locator<AccountGate>().guard(
            context,
            onAllowed: () async {
              final prerequisite =
                  await locator<CheckSellPrerequisiteUseCase>()();
              switch (prerequisite) {
                case SellPrerequisite.needsRole:
                  await context.router.push(const SellerRoleRoute());
                case SellPrerequisite.needsAddress:
                  await context.router.push(
                    AddressFormRoute(requirePhone: true),
                  );
                case SellPrerequisite.needsIban:
                  await context.router.push(const PayoutRoute());
                case SellPrerequisite.needsKyb:
                  await context.router.push(const SellerVerificationRoute());
                case SellPrerequisite.ready:
                  await context.router.push(const SellRoute());
              }
            },
          ),
        );
      },
    );
  }
}
