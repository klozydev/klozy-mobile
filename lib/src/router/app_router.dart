import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/domain/cart/entity/cart_bucket.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_category.dart';
import 'package:klozy/src/domain/me/entity/address.dart';
import 'package:klozy/src/feature/auth/presentation/screen/login_page.dart';
import 'package:klozy/src/feature/auth/presentation/screen/otp_page.dart';
import 'package:klozy/src/feature/auth/presentation/screen/phone_page.dart';
import 'package:klozy/src/feature/auth/presentation/screen/welcome_page.dart';
import 'package:klozy/src/feature/cart/presentation/screen/cart_page.dart';
import 'package:klozy/src/feature/chat/presentation/screen/chat_media_picker_page.dart';
import 'package:klozy/src/feature/chat/presentation/screen/chat_page.dart';
import 'package:klozy/src/feature/chat/presentation/screen/chat_thread_page.dart';
import 'package:klozy/src/feature/checkout/presentation/screen/checkout_page.dart';
import 'package:klozy/src/feature/home/presentation/screen/home_page.dart';
import 'package:klozy/src/feature/notifications/presentation/screen/notifications_page.dart';
import 'package:klozy/src/feature/onboarding/presentation/screen/personalize_page.dart';
import 'package:klozy/src/feature/onboarding/presentation/screen/profile_completion_page.dart';
import 'package:klozy/src/feature/onboarding/presentation/screen/seller_role_page.dart';
import 'package:klozy/src/feature/orders/presentation/screen/offers_page.dart';
import 'package:klozy/src/feature/orders/presentation/screen/order_detail_page.dart';
import 'package:klozy/src/feature/orders/presentation/screen/orders_page.dart';
import 'package:klozy/src/feature/product/presentation/screen/edit_listing_page.dart';
import 'package:klozy/src/feature/product/presentation/screen/product_page.dart';
import 'package:klozy/src/feature/profile/presentation/screen/follow_list_page.dart';
import 'package:klozy/src/feature/profile/presentation/screen/profile_page.dart';
import 'package:klozy/src/feature/profile/presentation/screen/user_profile_page.dart';
import 'package:klozy/src/feature/reels/presentation/screen/reel_composer_page.dart';
import 'package:klozy/src/feature/reels/presentation/screen/single_reel_page.dart';
import 'package:klozy/src/feature/search/presentation/screen/search_category_page.dart';
import 'package:klozy/src/feature/search/presentation/screen/search_page.dart';
import 'package:klozy/src/feature/sell/presentation/screen/sell_category_page.dart';
import 'package:klozy/src/feature/sell/presentation/screen/sell_page.dart';
import 'package:klozy/src/feature/settings/presentation/screen/address_form_page.dart';
import 'package:klozy/src/feature/settings/presentation/screen/blocked_users_page.dart';
import 'package:klozy/src/feature/settings/presentation/screen/change_email_page.dart';
import 'package:klozy/src/feature/settings/presentation/screen/change_password_page.dart';
import 'package:klozy/src/feature/settings/presentation/screen/change_phone_page.dart';
import 'package:klozy/src/feature/settings/presentation/screen/clothing_preference_page.dart';
import 'package:klozy/src/feature/settings/presentation/screen/edit_profile_page.dart';
import 'package:klozy/src/feature/settings/presentation/screen/legal_doc_page.dart';
import 'package:klozy/src/feature/settings/presentation/screen/payout_page.dart';
import 'package:klozy/src/feature/settings/presentation/screen/personal_data_page.dart';
import 'package:klozy/src/feature/settings/presentation/screen/preferred_brands_page.dart';
import 'package:klozy/src/feature/settings/presentation/screen/preferred_size_page.dart';
import 'package:klozy/src/feature/settings/presentation/screen/security_page.dart';
import 'package:klozy/src/feature/settings/presentation/screen/seller_verification_page.dart';
import 'package:klozy/src/feature/settings/presentation/screen/settings_page.dart';
import 'package:klozy/src/feature/shell/presentation/screen/shell_page.dart';
import 'package:klozy/src/router/account_guard.dart';
import 'package:klozy/src/router/onboarding_guard.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
@LazySingleton()
class AppRouter extends RootStackRouter {
  final AccountGuard _accountGuard;
  final OnboardingGuard _onboardingGuard;

  AppRouter(this._accountGuard, this._onboardingGuard);

  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  List<AutoRoute> get routes => [
    // Shell + guest-allowed tabs — no guard (guests can browse)
    AutoRoute(
      path: '/',
      page: ShellRoute.page,
      initial: true,
      children: [
        AutoRoute(path: 'home', page: HomeRoute.page, initial: true),
        AutoRoute(path: 'search', page: SearchRoute.page),
        // chat + profile tabs are guest-reachable; content gating is done
        // inside each tab (R2b) so the tab remains visible with a CTA.
        AutoRoute(path: 'chat', page: ChatRoute.page),
        AutoRoute(path: 'profile', page: ProfileRoute.page),
      ],
    ),
    AutoRoute(path: '/search/category', page: SearchCategoryRoute.page),
    AutoRoute(path: '/welcome', page: WelcomeRoute.page),
    AutoRoute(path: '/login', page: LoginRoute.page),
    AutoRoute(path: '/phone', page: PhoneRoute.page),
    AutoRoute(path: '/otp', page: OtpRoute.page),
    // On-demand profile completion (no forced "personalize your feed" step).
    // Reached when an action gate needs a complete profile.
    AutoRoute(
      path: '/onboarding/profile',
      page: ProfileCompletionRoute.page,
      guards: [_onboardingGuard],
    ),
    AutoRoute(
      path: '/seller-role',
      page: SellerRoleRoute.page,
      guards: [_accountGuard],
    ),
    // Guest-allowed browse routes — no guard
    AutoRoute(path: '/product/:id', page: ProductRoute.page),
    AutoRoute(path: '/users/:id', page: UserProfileRoute.page),
    AutoRoute(path: '/reel/:id', page: SingleReelRoute.page),
    // Private routes — AccountGuard required
    AutoRoute(path: '/sell', page: SellRoute.page, guards: [_accountGuard]),
    AutoRoute(
      path: '/sell/category',
      page: SellCategoryRoute.page,
      guards: [_accountGuard],
    ),
    AutoRoute(path: '/cart', page: CartRoute.page, guards: [_accountGuard]),
    AutoRoute(
      path: '/checkout',
      page: CheckoutRoute.page,
      guards: [_accountGuard],
    ),
    AutoRoute(
      path: '/product/:id/edit',
      page: EditListingRoute.page,
      guards: [_accountGuard],
    ),
    AutoRoute(
      path: '/notifications',
      page: NotificationsRoute.page,
      guards: [_accountGuard],
    ),
    AutoRoute(
      path: '/users/:id/connections',
      page: FollowListRoute.page,
      guards: [_accountGuard],
    ),
    AutoRoute(path: '/offers', page: OffersRoute.page, guards: [_accountGuard]),
    AutoRoute(path: '/orders', page: OrdersRoute.page, guards: [_accountGuard]),
    AutoRoute(
      path: '/orders/:id',
      page: OrderDetailRoute.page,
      guards: [_accountGuard],
    ),
    AutoRoute(
      path: '/chat/:tchatId',
      page: ChatThreadRoute.page,
      guards: [_accountGuard],
    ),
    AutoRoute(
      path: '/chat/:tchatId/picker',
      page: ChatMediaPickerRoute.page,
      guards: [_accountGuard],
    ),
    AutoRoute(
      path: '/reel-composer',
      page: ReelComposerRoute.page,
      guards: [_accountGuard],
    ),
    AutoRoute(
      path: '/settings',
      page: SettingsRoute.page,
      guards: [_accountGuard],
    ),
    AutoRoute(
      path: '/settings/edit-profile',
      page: EditProfileRoute.page,
      guards: [_accountGuard],
    ),
    AutoRoute(
      path: '/settings/addresses/form',
      page: AddressFormRoute.page,
      guards: [_accountGuard],
    ),
    AutoRoute(
      path: '/settings/personal-data',
      page: PersonalDataRoute.page,
      guards: [_accountGuard],
    ),
    AutoRoute(
      path: '/settings/security',
      page: SecurityRoute.page,
      guards: [_accountGuard],
    ),
    AutoRoute(
      path: '/settings/security/email',
      page: ChangeEmailRoute.page,
      guards: [_accountGuard],
    ),
    AutoRoute(
      path: '/settings/security/password',
      page: ChangePasswordRoute.page,
      guards: [_accountGuard],
    ),
    AutoRoute(
      path: '/settings/security/phone',
      page: ChangePhoneRoute.page,
      guards: [_accountGuard],
    ),
    AutoRoute(
      path: '/settings/preferences/clothing',
      page: ClothingPreferenceRoute.page,
      guards: [_accountGuard],
    ),
    AutoRoute(
      path: '/settings/preferences/size',
      page: PreferredSizeRoute.page,
      guards: [_accountGuard],
    ),
    AutoRoute(
      path: '/settings/preferences/brands',
      page: PreferredBrandsRoute.page,
      guards: [_accountGuard],
    ),
    AutoRoute(
      path: '/settings/payout',
      page: PayoutRoute.page,
      guards: [_accountGuard],
    ),
    AutoRoute(
      path: '/settings/seller-verification',
      page: SellerVerificationRoute.page,
      guards: [_accountGuard],
    ),
    AutoRoute(
      path: '/settings/blocked',
      page: BlockedUsersRoute.page,
      guards: [_accountGuard],
    ),
    AutoRoute(
      path: '/settings/legal/:key',
      page: LegalDocRoute.page,
      guards: [_accountGuard],
    ),
    RedirectRoute(path: '*', redirectTo: '/'),
  ];
}
